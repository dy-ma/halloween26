//! Bounded run history and application status. Transport ACKs never enter this bus.
use crate::{
    RuntimeNode,
    cue_link::EventMessage,
    screen::ScreenHub,
    show_config::FlowRole,
    state::{StateHub, StateSnapshot, SystemMode},
};
use serde::Serialize;
use std::{
    collections::{BTreeMap, VecDeque},
    sync::{
        Arc, Mutex,
        atomic::{AtomicU32, Ordering},
    },
    time::{Duration, SystemTime, UNIX_EPOCH},
};
use tokio::sync::{Semaphore, broadcast, watch};

#[derive(Clone, Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct DeviceStatus {
    pub link: String,
    pub node: String,
    pub event: String,
    pub command_id: Option<String>,
    pub received_at_ms: u64,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize)]
#[serde(rename_all = "lowercase")]
pub enum Phase {
    Pending,
    Scheduled,
    Running,
    Complete,
    Failed,
    Skipped,
}

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct NodeStatus {
    pub id: String,
    pub phase: Phase,
    pub detail: String,
    pub offset_ms: u64,
    pub after: Vec<String>,
    pub transition: Option<String>,
    pub execute_at_ms: Option<u64>,
    pub started_at_ms: Option<u64>,
    pub finished_at_ms: Option<u64>,
}

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct RunStatus {
    pub id: String,
    pub reason: String,
    pub started_at_ms: u64,
    pub role: FlowRole,
    pub nodes: Vec<NodeStatus>,
}

struct RunRecord {
    status: RunStatus,
    cancelled: watch::Sender<bool>,
    finished: bool,
}

#[derive(Serialize)]
pub struct Snapshot {
    pub state: StateSnapshot,
    pub devices: Vec<DeviceStatus>,
    pub runs: Vec<RunStatus>,
    pub timings: Vec<TimingStatus>,
    pub log: Vec<LogEntry>,
}

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct TimingStatus {
    pub node_id: String,
    pub flow: String,
    pub node: String,
    pub role: FlowRole,
    pub default_at_ms: u64,
    pub at_ms: u64,
    pub after: Vec<String>,
    pub transition: Option<String>,
}

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct LogEntry {
    pub id: u64,
    pub timestamp_ms: u64,
    pub level: &'static str,
    pub kind: &'static str,
    pub message: String,
    pub run_id: Option<String>,
}

struct Inner {
    devices: BTreeMap<(String, String), DeviceStatus>,
    runs: VecDeque<RunRecord>,
    log: VecDeque<LogEntry>,
    next_log_id: u64,
}

impl Inner {
    fn log(
        &mut self,
        level: &'static str,
        kind: &'static str,
        message: String,
        run_id: Option<&str>,
    ) {
        self.next_log_id += 1;
        self.log.push_back(LogEntry {
            id: self.next_log_id,
            timestamp_ms: now_ms(),
            level,
            kind,
            message,
            run_id: run_id.map(str::to_owned),
        });
        while self.log.len() > 500 {
            self.log.pop_front();
        }
    }
}

#[derive(Clone)]
pub struct WorkflowHub {
    inner: Arc<Mutex<Inner>>,
    events: broadcast::Sender<DeviceStatus>,
    audio: Arc<Mutex<Option<crate::audio_runtime::AudioRuntime>>>,
    generation: Arc<AtomicU32>,
    state: StateHub,
    timings: Arc<Mutex<BTreeMap<String, TimingStatus>>>,
}

impl Default for WorkflowHub {
    fn default() -> Self {
        Self::new(StateHub::default())
    }
}

impl WorkflowHub {
    pub fn new(state: StateHub) -> Self {
        let (events, _) = broadcast::channel(256);
        // A wall-clock seed keeps a restarted controller newer than work a
        // board may still remember from the previous process lifetime.
        let generation = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs() as u32;
        Self {
            inner: Arc::new(Mutex::new(Inner {
                devices: BTreeMap::new(),
                runs: VecDeque::new(),
                log: VecDeque::new(),
                next_log_id: 0,
            })),
            events,
            audio: Arc::new(Mutex::new(None)),
            generation: Arc::new(AtomicU32::new(generation.max(1))),
            state,
            timings: Arc::new(Mutex::new(BTreeMap::new())),
        }
    }
}

pub fn now_ms() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis()
        .min(u64::MAX as u128) as u64
}

impl WorkflowHub {
    pub fn set_audio(&self, audio: crate::audio_runtime::AudioRuntime) {
        *self.audio.lock().expect("audio mutex") = Some(audio);
    }

    pub fn audio(&self) -> Result<crate::audio_runtime::AudioRuntime, String> {
        self.audio
            .lock()
            .expect("audio mutex")
            .clone()
            .ok_or_else(|| "audio runtime unavailable".into())
    }

    pub fn note(&self, message: String) {
        self.note_kind("system", message);
    }

    pub fn note_kind(&self, kind: &'static str, message: String) {
        self.inner
            .lock()
            .expect("workflow mutex")
            .log("info", kind, message, None);
    }

    pub fn register_timing(
        &self,
        flow: &str,
        role: FlowRole,
        node: &str,
        node_id: &str,
        at_ms: u64,
        after: Vec<String>,
        transition: Option<String>,
    ) {
        self.timings.lock().expect("timing mutex").insert(
            node_id.into(),
            TimingStatus {
                node_id: node_id.into(),
                flow: flow.into(),
                node: node.into(),
                role,
                default_at_ms: at_ms,
                at_ms,
                after,
                transition,
            },
        );
    }

    pub fn set_timing(&self, node_id: &str, at_ms: u64) -> Result<(), String> {
        if at_ms > 60_000 {
            return Err("execution offset must be between 0 and 60000ms".into());
        }
        let mut timings = self.timings.lock().expect("timing mutex");
        let timing = timings
            .get_mut(node_id)
            .ok_or_else(|| format!("unknown flow node `{node_id}`"))?;
        timing.at_ms = at_ms;
        drop(timings);
        self.note_kind("timing", format!("Timing {node_id} set to {at_ms}ms"));
        Ok(())
    }

    fn timing_for(&self, node_id: &str, fallback: u64) -> u64 {
        self.timings
            .lock()
            .expect("timing mutex")
            .get(node_id)
            .map_or(fallback, |timing| timing.at_ms)
    }

    pub fn record(&self, message: &EventMessage) {
        let (Some(link), Some(node)) = (&message.link, &message.source) else {
            return;
        };
        let (event, command_id) = match message.event.rsplit_once(':') {
            Some((event, suffix))
                if suffix.len() == 16 && suffix.bytes().all(|b| b.is_ascii_hexdigit()) =>
            {
                (event.to_string(), Some(suffix.to_ascii_uppercase()))
            }
            _ => (message.event.clone(), None),
        };
        let status = DeviceStatus {
            link: link.clone(),
            node: node.to_ascii_uppercase(),
            event,
            command_id,
            received_at_ms: now_ms(),
        };
        let mut inner = self.inner.lock().expect("workflow mutex");
        if inner.devices.len() >= 256
            && !inner
                .devices
                .contains_key(&(status.link.clone(), status.node.clone()))
        {
            return;
        }
        let changed = inner
            .devices
            .get(&(status.link.clone(), status.node.clone()))
            .is_none_or(|previous| {
                previous.event != status.event || previous.command_id != status.command_id
            });
        if changed {
            inner.log(
                "info",
                "device",
                format!(
                    "{} / {}: {}{}",
                    status.link,
                    status.node,
                    status.event,
                    status
                        .command_id
                        .as_ref()
                        .map(|id| format!(" [command {id}]"))
                        .unwrap_or_default()
                ),
                None,
            );
        }
        inner
            .devices
            .insert((status.link.clone(), status.node.clone()), status.clone());
        drop(inner);
        let _ = self.events.send(status);
    }

    pub fn subscribe(&self) -> broadcast::Receiver<DeviceStatus> {
        self.events.subscribe()
    }

    pub fn snapshot(&self) -> Snapshot {
        let inner = self.inner.lock().expect("workflow mutex");
        Snapshot {
            state: self.state.snapshot(),
            devices: inner.devices.values().cloned().collect(),
            runs: inner.runs.iter().rev().map(|r| r.status.clone()).collect(),
            timings: self
                .timings
                .lock()
                .expect("timing mutex")
                .values()
                .cloned()
                .collect(),
            log: inner.log.iter().cloned().collect(),
        }
    }

    pub fn cancel_pending(&self) {
        // Holding a jog button repeats its request. Once the managed system is
        // already halted those repeats and the matching release/stop command
        // stay in the same generation instead of consuming a new epoch each
        // time.
        if self.state.snapshot().mode != SystemMode::Halted {
            let _ = self
                .generation
                .fetch_update(Ordering::AcqRel, Ordering::Acquire, |value| {
                    Some(value.wrapping_add(1).max(1))
                });
        }
        for run in &self.inner.lock().expect("workflow mutex").runs {
            let _ = run.cancelled.send(true);
        }
        self.state.halt();
    }

    pub fn generation(&self) -> u32 {
        self.generation.load(Ordering::Acquire)
    }

    fn update(&self, run: &str, node: &str, phase: Phase, detail: String) {
        let mut inner = self.inner.lock().expect("workflow mutex");
        let mut finished = None;
        if let Some(record) = inner.runs.iter_mut().find(|r| r.status.id == run)
            && let Some(status) = record.status.nodes.iter_mut().find(|n| n.id == node)
        {
            status.phase = phase;
            status.detail = detail.clone();
            let timestamp = now_ms();
            if phase == Phase::Running && status.started_at_ms.is_none() {
                status.started_at_ms = Some(timestamp);
            }
            if matches!(phase, Phase::Complete | Phase::Failed | Phase::Skipped) {
                status.finished_at_ms = Some(timestamp);
            }
            let reason = record.status.reason.clone();
            if !record.finished
                && record.status.nodes.iter().all(|node| {
                    matches!(node.phase, Phase::Complete | Phase::Failed | Phase::Skipped)
                })
            {
                record.finished = true;
                finished = Some((
                    record.status.role,
                    record
                        .status
                        .nodes
                        .iter()
                        .all(|node| node.phase == Phase::Complete),
                ));
            }
            inner.log(
                match phase {
                    Phase::Failed => "error",
                    Phase::Skipped => "warning",
                    _ => "info",
                },
                "workflow",
                format!("{reason} / {node}: {phase:?} — {detail}"),
                Some(run),
            );
        }
        drop(inner);
        if let Some((role, success)) = finished {
            self.state.finish_flow(role, success);
        }
    }

    fn set_execute_at(&self, run: &str, node: &str, execute_at_ms: u64) {
        let mut inner = self.inner.lock().expect("workflow mutex");
        if let Some(status) = inner
            .runs
            .iter_mut()
            .find(|record| record.status.id == run)
            .and_then(|record| {
                record
                    .status
                    .nodes
                    .iter_mut()
                    .find(|status| status.id == node)
            })
        {
            status.execute_at_ms = Some(execute_at_ms);
        }
    }

    pub fn start(
        &self,
        nodes: &[RuntimeNode],
        role: FlowRole,
        screen: &ScreenHub,
        slots: Arc<Semaphore>,
        reason: &str,
    ) -> Result<(), String> {
        if nodes.is_empty() {
            return Ok(());
        }
        let id = uuid::Uuid::new_v4().to_string();
        let (cancelled, cancel_receiver) = watch::channel(false);
        let mut inner = self.inner.lock().expect("workflow mutex");
        // Never evict an active run: its dependent tasks still need their state.
        while inner.runs.len() >= 64 {
            if let Some(index) = inner.runs.iter().position(|r| {
                r.status
                    .nodes
                    .iter()
                    .all(|n| !matches!(n.phase, Phase::Pending | Phase::Scheduled | Phase::Running))
            }) {
                inner.runs.remove(index);
            } else {
                return Err("all 64 workflow slots are active".into());
            }
        }
        self.state.begin_flow(role)?;
        let started_at_ms = now_ms();
        let generation = self.generation();
        inner.runs.push_back(RunRecord {
            cancelled,
            finished: false,
            status: RunStatus {
                id: id.clone(),
                reason: reason.to_string(),
                started_at_ms,
                role,
                nodes: nodes
                    .iter()
                    .map(|n| NodeStatus {
                        id: n.id.clone(),
                        phase: Phase::Pending,
                        detail: "waiting for dependencies".into(),
                        offset_ms: self.timing_for(&n.id, n.at_ms),
                        after: n.after.clone(),
                        transition: n.transition.as_ref().map(|transition| {
                            format!("{}.{}", transition.prop, transition.transition)
                        }),
                        execute_at_ms: None,
                        started_at_ms: None,
                        finished_at_ms: None,
                    })
                    .collect(),
            },
        });
        inner.log(
            "info",
            "workflow",
            format!("Started {reason} ({} actions)", nodes.len()),
            Some(&id),
        );
        drop(inner);
        let states: BTreeMap<_, _> = nodes
            .iter()
            .map(|n| (n.id.clone(), watch::channel(Phase::Pending)))
            .collect();
        for node in nodes {
            let node = node.clone();
            let dependencies: Vec<_> = node.after.iter().map(|id| states[id].1.clone()).collect();
            let state = states[&node.id].0.clone();
            let hub = self.clone();
            let screen = screen.clone();
            let slots = slots.clone();
            let run = id.clone();
            let mut cancelled = cancel_receiver.clone();
            let transition = node.transition.clone();
            tokio::spawn(async move {
                let has_dependencies = !dependencies.is_empty();
                let ready = async {
                    for mut dependency in dependencies {
                        loop {
                            let phase = *dependency.borrow_and_update();
                            match phase {
                                Phase::Complete => break,
                                Phase::Failed | Phase::Skipped => {
                                    return Err("dependency did not complete".to_string());
                                }
                                _ => {}
                            }
                            dependency
                                .changed()
                                .await
                                .map_err(|_| "dependency stopped".to_string())?;
                        }
                    }
                    Ok(())
                };
                let ready = if *cancelled.borrow() {
                    Err("cancelled before dispatch".into())
                } else {
                    tokio::select! {
                        result = ready => result,
                        _ = cancelled.changed() => Err("cancelled before dispatch".into()),
                    }
                };
                if let Err(detail) = ready {
                    hub.update(&run, &node.id, Phase::Skipped, detail);
                    let _ = state.send(Phase::Skipped);
                    return;
                }
                if *cancelled.borrow() {
                    hub.update(
                        &run,
                        &node.id,
                        Phase::Skipped,
                        "cancelled before dispatch".into(),
                    );
                    let _ = state.send(Phase::Skipped);
                    return;
                }
                let offset_ms = hub.timing_for(&node.id, node.at_ms);
                let target_ms = if has_dependencies {
                    now_ms().saturating_add(offset_ms)
                } else {
                    started_at_ms.saturating_add(offset_ms)
                };
                hub.set_execute_at(&run, &node.id, target_ms);
                let remote_schedule = matches!(
                    &node.action,
                    crate::RuntimeAction::Cue {
                        schedule_at_board: true,
                        ..
                    }
                ) && target_ms > now_ms();
                if let Some(transition) = &transition
                    && let Err(error) = hub.state.reserve(
                        transition,
                        &run,
                        &node.id,
                        (target_ms > now_ms()).then_some(target_ms),
                    )
                {
                    hub.update(&run, &node.id, Phase::Failed, error);
                    let _ = state.send(Phase::Failed);
                    return;
                }
                if !remote_schedule {
                    let wait_ms = target_ms.saturating_sub(now_ms());
                    if wait_ms != 0 {
                        let delay = tokio::time::sleep(Duration::from_millis(wait_ms));
                        tokio::pin!(delay);
                        let delayed = tokio::select! {
                            _ = &mut delay => true,
                            _ = cancelled.changed() => false,
                        };
                        if !delayed || *cancelled.borrow() {
                            hub.update(
                                &run,
                                &node.id,
                                Phase::Skipped,
                                "cancelled before execution".into(),
                            );
                            let _ = state.send(Phase::Skipped);
                            return;
                        }
                    }
                    hub.update(&run, &node.id, Phase::Running, "executing".into());
                    let _ = state.send(Phase::Running);
                    if let Some(transition) = &transition {
                        hub.state.begin_transition(transition, &run, &node.id);
                    }
                } else {
                    hub.update(
                        &run,
                        &node.id,
                        Phase::Scheduled,
                        format!("accepted for execution at {target_ms}"),
                    );
                    let _ = state.send(Phase::Scheduled);
                }
                let execution = crate::execute_node(
                    node.clone(),
                    &screen,
                    slots,
                    &hub,
                    remote_schedule.then_some(target_ms),
                    generation,
                );
                tokio::pin!(execution);
                let result = if remote_schedule {
                    let start = tokio::time::sleep(Duration::from_millis(
                        target_ms.saturating_sub(now_ms()),
                    ));
                    tokio::pin!(start);
                    tokio::select! {
                        result = &mut execution => result,
                        _ = &mut start => {
                            hub.update(&run, &node.id, Phase::Running, "scheduled execution time reached".into());
                            let _ = state.send(Phase::Running);
                            if let Some(transition) = &transition {
                                hub.state.begin_transition(transition, &run, &node.id);
                            }
                            tokio::select! {
                                result = &mut execution => result,
                                _ = cancelled.changed() => Err("cancelled during execution".into()),
                            }
                        }
                        _ = cancelled.changed() => Err("cancelled before execution".into()),
                    }
                } else {
                    tokio::select! {
                        result = &mut execution => result,
                        _ = cancelled.changed() => Err("cancelled during execution".into()),
                    }
                };
                let (phase, detail) = match result {
                    Ok(detail) => (Phase::Complete, detail),
                    Err(error) if error.starts_with("cancelled ") => (Phase::Skipped, error),
                    Err(error) => (Phase::Failed, error),
                };
                if let Some(transition) = &transition {
                    match phase {
                        Phase::Complete => {
                            hub.state.complete_transition(transition, &run, &node.id)
                        }
                        Phase::Failed => hub.state.fail_transition(transition, &run, &node.id),
                        _ => {}
                    }
                }
                crate::fx_log!("run {run} node {}: {phase:?}: {detail}", node.id);
                hub.update(&run, &node.id, phase, detail);
                let _ = state.send(phase);
            });
        }
        Ok(())
    }
}

pub async fn wait_for_status(
    mut receiver: broadcast::Receiver<DeviceStatus>,
    link: &str,
    node: &str,
    command: u64,
    events: &[String],
    timeout_ms: u64,
) -> Result<String, String> {
    let command_id = format!("{command:016X}");
    let expected = events.join(" or ");
    tokio::time::timeout(Duration::from_millis(timeout_ms), async {
        loop {
            let status = receiver
                .recv()
                .await
                .map_err(|e| format!("status stream lost: {e}"))?;
            if status.link != link
                || !status.node.eq_ignore_ascii_case(node)
                || status.command_id.as_ref() != Some(&command_id)
            {
                continue;
            }
            if events.iter().any(|event| status.event == *event) {
                return Ok(format!("assembly reported {}", status.event));
            }
            // A different terminal outcome for this command must not release dependents.
            if [
                ":invalid",
                ":stopped",
                ":complete",
                ":superseded",
                ":replaced",
                ":expired",
                ":fault",
            ]
            .iter()
            .any(|s| status.event.ends_with(s))
                || status.event.contains(":limit:")
            {
                return Err(format!(
                    "expected {expected}, assembly reported {}",
                    status.event
                ));
            }
        }
    })
    .await
    .map_err(|_| format!("timed out waiting for {expected} from {node}"))?
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn activity_log_is_bounded_chronological_and_ignores_unchanged_reports() {
        let hub = WorkflowHub::default();
        let message = |event: String| EventMessage {
            link: Some("radio".into()),
            source: Some("AABBCCDDEEFF".into()),
            event,
            sequence: None,
            rssi: None,
            service: None,
            transport: None,
        };
        for _ in 0..10 {
            hub.record(&message("dc:limits:10".into()));
        }
        assert_eq!(hub.snapshot().log.len(), 1);
        for index in 0..502 {
            hub.record(&message(format!("status-{index}")));
        }
        let log = hub.snapshot().log;
        assert_eq!(log.len(), 500);
        assert_eq!(log.first().unwrap().id, 4);
        assert_eq!(log.last().unwrap().id, 503);
        assert!(log.windows(2).all(|pair| pair[0].id < pair[1].id));
    }

    #[tokio::test]
    async fn completion_requires_matching_device_link_and_command_and_preserves_early_status() {
        let hub = WorkflowHub::default();
        let rx = hub.subscribe();
        for (link, node, command) in [
            ("radio", "AABBCCDDEEFF", 9),
            ("other", "AABBCCDDEEFF", 10),
            ("radio", "112233445566", 10),
            ("radio", "AABBCCDDEEFF", 10),
        ] {
            hub.record(&EventMessage {
                link: Some(link.into()),
                source: Some(node.into()),
                event: format!("dc:limit:fwd:{command:016X}"),
                sequence: Some(command),
                rssi: None,
                service: None,
                transport: None,
            });
        }
        assert!(
            wait_for_status(
                rx,
                "radio",
                "AABBCCDDEEFF",
                10,
                &["dc:limit:fwd".into(), "dc:complete".into()],
                100,
            )
            .await
            .is_ok()
        );
        assert!(
            wait_for_status(
                hub.subscribe(),
                "radio",
                "AABBCCDDEEFF",
                11,
                &["dc:complete".into()],
                1
            )
            .await
            .is_err()
        );
    }

    fn cue_node(
        id: &str,
        after: &[&str],
        sender: crate::cue_link::CueLinkSender,
        wait: bool,
    ) -> RuntimeNode {
        RuntimeNode {
            id: id.into(),
            at_ms: 0,
            after: after.iter().map(|s| s.to_string()).collect(),
            transition: None,
            action: crate::RuntimeAction::Cue {
                sink: "motor".into(),
                link: "radio".into(),
                sender,
                target: "AABBCCDDEEFF".into(),
                cue: "dc:fwd:70:100".into(),
                schedule_at_board: true,
                expires_after_ms: 500,
                wait_for: wait.then(|| vec!["dc:complete".into()]),
                timeout_ms: 100,
            },
        }
    }

    async fn next_outgoing(
        rx: &std::sync::mpsc::Receiver<crate::cue_link::OutgoingCue>,
    ) -> crate::cue_link::OutgoingCue {
        tokio::time::timeout(Duration::from_secs(1), async {
            loop {
                if let Ok(cue) = rx.try_recv() {
                    return cue;
                }
                tokio::task::yield_now().await;
            }
        })
        .await
        .unwrap()
    }

    fn screens() -> ScreenHub {
        ScreenHub::new(std::iter::empty())
    }

    #[tokio::test]
    async fn dag_waits_for_correlated_completion_before_dispatching_child() {
        let hub = WorkflowHub::default();
        let (sender, rx) = crate::cue_link::CueLinkSender::channel(8);
        let nodes = vec![
            cue_node("move", &[], sender.clone(), true),
            cue_node("sound", &["move"], sender, false),
        ];
        hub.start(
            &nodes,
            FlowRole::Utility,
            &screens(),
            Arc::new(Semaphore::new(1)),
            "test",
        )
        .unwrap();
        let first = next_outgoing(&rx).await;
        let event = |id| EventMessage {
            link: Some("radio".into()),
            source: Some("AABBCCDDEEFF".into()),
            event: format!("dc:complete:{id:016X}"),
            sequence: Some(id),
            rssi: None,
            service: None,
            transport: None,
        };
        hub.record(&event(first.id.wrapping_add(1)));
        tokio::task::yield_now().await;
        assert!(
            rx.try_recv().is_err(),
            "a stale completion must not release the child"
        );
        hub.record(&event(first.id));
        assert_ne!(next_outgoing(&rx).await.id, first.id);
    }

    #[tokio::test]
    async fn timed_out_parent_skips_child_but_keeps_independent_branch() {
        let hub = WorkflowHub::default();
        let (sender, rx) = crate::cue_link::CueLinkSender::channel(8);
        let nodes = vec![
            cue_node("move", &[], sender.clone(), true),
            cue_node("child", &["move"], sender.clone(), false),
            cue_node("independent", &[], sender, false),
        ];
        hub.start(
            &nodes,
            FlowRole::Utility,
            &screens(),
            Arc::new(Semaphore::new(1)),
            "test",
        )
        .unwrap();
        let _ = next_outgoing(&rx).await;
        let _ = next_outgoing(&rx).await;
        tokio::time::timeout(Duration::from_secs(1), async {
            loop {
                if hub.snapshot().runs[0].nodes[1].phase == Phase::Skipped {
                    break;
                }
                tokio::task::yield_now().await;
            }
        })
        .await
        .unwrap();
        assert_eq!(hub.snapshot().runs[0].nodes[0].phase, Phase::Failed);
        assert!(rx.try_recv().is_err());
    }

    #[tokio::test]
    async fn stop_cancels_delayed_actions_before_they_can_dispatch() {
        let hub = WorkflowHub::default();
        let (sender, rx) = crate::cue_link::CueLinkSender::channel(8);
        let mut node = cue_node("delayed", &[], sender, false);
        node.at_ms = 10_000;
        if let crate::RuntimeAction::Cue {
            schedule_at_board, ..
        } = &mut node.action
        {
            *schedule_at_board = false;
        }
        hub.start(
            &[node],
            FlowRole::Utility,
            &screens(),
            Arc::new(Semaphore::new(1)),
            "test",
        )
        .unwrap();
        hub.cancel_pending();
        tokio::time::timeout(Duration::from_secs(1), async {
            loop {
                if hub.snapshot().runs[0].nodes[0].phase == Phase::Skipped {
                    break;
                }
                tokio::task::yield_now().await;
            }
        })
        .await
        .unwrap();
        assert!(rx.try_recv().is_err());
    }

    #[tokio::test]
    async fn mqtt_cue_is_dispatched_early_with_absolute_execution_time() {
        let hub = WorkflowHub::default();
        let (sender, rx) = crate::cue_link::CueLinkSender::channel(8);
        let mut node = cue_node("scheduled", &[], sender, false);
        node.at_ms = 10_000;
        let before = now_ms();
        hub.start(
            &[node],
            FlowRole::Utility,
            &screens(),
            Arc::new(Semaphore::new(1)),
            "test",
        )
        .unwrap();
        let outgoing = next_outgoing(&rx).await;
        assert!(outgoing.execute_at_ms >= before + 9_900);
        assert_eq!(outgoing.expires_after_ms, 500);
        assert_eq!(outgoing.generation, hub.generation());
        assert_eq!(hub.snapshot().runs[0].nodes[0].phase, Phase::Scheduled);
        hub.cancel_pending();
    }

    #[tokio::test]
    async fn operator_timing_override_changes_the_next_dispatched_show_cue() {
        let hub = WorkflowHub::default();
        let (sender, rx) = crate::cue_link::CueLinkSender::channel(8);
        let mut node = cue_node("integration/lift-a", &[], sender, false);
        node.at_ms = 10_000;
        hub.register_timing(
            "integration",
            FlowRole::Show,
            "lift-a",
            &node.id,
            node.at_ms,
            Vec::new(),
            Some("lift_a.raise".into()),
        );
        hub.set_timing(&node.id, 650).unwrap();

        let before = now_ms();
        hub.start(
            &[node],
            FlowRole::Show,
            &screens(),
            Arc::new(Semaphore::new(1)),
            "dashboard show",
        )
        .unwrap();

        let outgoing = next_outgoing(&rx).await;
        assert!(outgoing.execute_at_ms >= before + 600);
        assert!(outgoing.execute_at_ms <= before + 1_000);
        let snapshot = hub.snapshot();
        assert_eq!(snapshot.runs[0].nodes[0].offset_ms, 650);
        assert_eq!(snapshot.timings[0].default_at_ms, 10_000);
        assert_eq!(snapshot.timings[0].at_ms, 650);
        hub.cancel_pending();
    }
}
