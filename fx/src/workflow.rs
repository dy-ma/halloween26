//! Bounded run history and application status. Transport ACKs never enter this bus.
use crate::{RuntimeNode, cue_link::EventMessage, screen::ScreenHub};
use serde::Serialize;
use std::{
    collections::{BTreeMap, VecDeque},
    sync::{Arc, Mutex},
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
    Running,
    Complete,
    Failed,
    Skipped,
}

#[derive(Clone, Serialize)]
pub struct NodeStatus {
    pub id: String,
    pub phase: Phase,
    pub detail: String,
}

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct RunStatus {
    pub id: String,
    pub reason: String,
    pub started_at_ms: u64,
    pub nodes: Vec<NodeStatus>,
}

struct RunRecord {
    status: RunStatus,
    cancelled: watch::Sender<bool>,
}

#[derive(Serialize)]
pub struct Snapshot {
    pub devices: Vec<DeviceStatus>,
    pub runs: Vec<RunStatus>,
    pub log: Vec<LogEntry>,
}

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct LogEntry {
    pub id: u64,
    pub timestamp_ms: u64,
    pub level: &'static str,
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
    fn log(&mut self, level: &'static str, message: String, run_id: Option<&str>) {
        self.next_log_id += 1;
        self.log.push_back(LogEntry {
            id: self.next_log_id,
            timestamp_ms: now_ms(),
            level,
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
}

impl Default for WorkflowHub {
    fn default() -> Self {
        let (events, _) = broadcast::channel(256);
        Self {
            inner: Arc::new(Mutex::new(Inner {
                devices: BTreeMap::new(),
                runs: VecDeque::new(),
                log: VecDeque::new(),
                next_log_id: 0,
            })),
            events,
            audio: Arc::new(Mutex::new(None)),
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
        self.inner
            .lock()
            .expect("workflow mutex")
            .log("info", message, None);
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
            devices: inner.devices.values().cloned().collect(),
            runs: inner.runs.iter().rev().map(|r| r.status.clone()).collect(),
            log: inner.log.iter().cloned().collect(),
        }
    }

    pub fn cancel_pending(&self) {
        for run in &self.inner.lock().expect("workflow mutex").runs {
            let _ = run.cancelled.send(true);
        }
    }

    fn update(&self, run: &str, node: &str, phase: Phase, detail: String) {
        let mut inner = self.inner.lock().expect("workflow mutex");
        if let Some(record) = inner.runs.iter_mut().find(|r| r.status.id == run)
            && let Some(status) = record.status.nodes.iter_mut().find(|n| n.id == node)
        {
            status.phase = phase;
            status.detail = detail.clone();
            let reason = record.status.reason.clone();
            inner.log(
                match phase {
                    Phase::Failed => "error",
                    Phase::Skipped => "warning",
                    _ => "info",
                },
                format!("{reason} / {node}: {phase:?} — {detail}"),
                Some(run),
            );
        }
    }

    pub fn start(
        &self,
        nodes: &[RuntimeNode],
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
                    .all(|n| !matches!(n.phase, Phase::Pending | Phase::Running))
            }) {
                inner.runs.remove(index);
            } else {
                return Err("all 64 workflow slots are active".into());
            }
        }
        inner.runs.push_back(RunRecord {
            cancelled,
            status: RunStatus {
                id: id.clone(),
                reason: reason.to_string(),
                started_at_ms: now_ms(),
                nodes: nodes
                    .iter()
                    .map(|n| NodeStatus {
                        id: n.id.clone(),
                        phase: Phase::Pending,
                        detail: "waiting for dependencies".into(),
                    })
                    .collect(),
            },
        });
        inner.log(
            "info",
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
            tokio::spawn(async move {
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
                    tokio::time::sleep(Duration::from_millis(node.at_ms)).await;
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
                hub.update(&run, &node.id, Phase::Running, "executing".into());
                let _ = state.send(Phase::Running);
                let result = crate::execute_node(node.clone(), &screen, slots, &hub).await;
                let (phase, detail) = match result {
                    Ok(detail) => (Phase::Complete, detail),
                    Err(error) => (Phase::Failed, error),
                };
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
    event: &str,
    timeout_ms: u64,
) -> Result<String, String> {
    let command_id = format!("{command:016X}");
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
            if status.event == event {
                return Ok(format!("assembly reported {event}"));
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
                    "expected {event}, assembly reported {}",
                    status.event
                ));
            }
        }
    })
    .await
    .map_err(|_| format!("timed out waiting for {event} from {node}"))?
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
            wait_for_status(rx, "radio", "AABBCCDDEEFF", 10, "dc:limit:fwd", 100)
                .await
                .is_ok()
        );
        assert!(
            wait_for_status(
                hub.subscribe(),
                "radio",
                "AABBCCDDEEFF",
                11,
                "dc:complete",
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
            action: crate::RuntimeAction::Cue {
                sink: "motor".into(),
                link: "radio".into(),
                sender,
                target: "AABBCCDDEEFF".into(),
                cue: "dc:fwd:70:100".into(),
                expires_after_ms: 500,
                wait_for: wait.then(|| "dc:complete".into()),
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
        hub.start(&nodes, &screens(), Arc::new(Semaphore::new(1)), "test")
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
        hub.start(&nodes, &screens(), Arc::new(Semaphore::new(1)), "test")
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
        hub.start(&[node], &screens(), Arc::new(Semaphore::new(1)), "test")
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
}
