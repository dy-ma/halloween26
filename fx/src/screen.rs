use std::{
    collections::BTreeMap,
    sync::{Arc, Mutex},
    time::Duration,
};

use serde::{Deserialize, Serialize};
use tokio::sync::broadcast;
use uuid::Uuid;

use fx_audio::{FxError, Result};

const COMMAND_BUFFER_CAPACITY: usize = 64;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum EyeMode {
    Sleeping,
    Idle,
    Alert,
    Tipping,
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Gaze {
    pub x: f64,
    pub y: f64,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct EyeSnapshot {
    pub mode: EyeMode,
    pub gaze: Gaze,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(tag = "type", deny_unknown_fields)]
pub enum EyeCommand {
    #[serde(rename = "eye/open")]
    Open {
        #[serde(
            rename = "durationMs",
            alias = "duration_ms",
            default,
            skip_serializing_if = "Option::is_none"
        )]
        duration_ms: Option<u64>,
    },
    #[serde(rename = "eye/close")]
    Close {
        #[serde(
            rename = "durationMs",
            alias = "duration_ms",
            default,
            skip_serializing_if = "Option::is_none"
        )]
        duration_ms: Option<u64>,
    },
    #[serde(rename = "eye/blink")]
    Blink {
        #[serde(
            rename = "durationMs",
            alias = "duration_ms",
            default,
            skip_serializing_if = "Option::is_none"
        )]
        duration_ms: Option<u64>,
    },
    #[serde(rename = "eye/wake")]
    Wake,
    #[serde(rename = "eye/look")]
    Look {
        x: f64,
        y: f64,
        #[serde(
            rename = "durationMs",
            alias = "duration_ms",
            default,
            skip_serializing_if = "Option::is_none"
        )]
        duration_ms: Option<u64>,
    },
    #[serde(rename = "eye/nudge")]
    Nudge { x: f64, y: f64 },
    #[serde(rename = "eye/mode")]
    Mode { mode: EyeMode },
    #[serde(rename = "system/reset")]
    Reset,
}

impl EyeCommand {
    pub fn validate(&self) -> Result<()> {
        match self {
            Self::Open { duration_ms }
            | Self::Close { duration_ms }
            | Self::Blink { duration_ms } => validate_duration(*duration_ms),
            Self::Look { x, y, duration_ms } => {
                validate_gaze(*x, *y)?;
                validate_duration(*duration_ms)
            }
            Self::Nudge { x, y } => validate_gaze(*x, *y),
            Self::Wake | Self::Mode { .. } | Self::Reset => Ok(()),
        }
    }
}

impl EyeSnapshot {
    pub fn validate(&self) -> Result<()> {
        validate_gaze(self.gaze.x, self.gaze.y)
    }
}

fn validate_duration(duration_ms: Option<u64>) -> Result<()> {
    if duration_ms.is_some_and(|duration| duration > 10_000) {
        Err(FxError::ShowConfig(
            "eye command duration must be between 0 and 10000ms".into(),
        ))
    } else {
        Ok(())
    }
}

fn validate_gaze(x: f64, y: f64) -> Result<()> {
    if x.is_finite() && y.is_finite() && (-1.0..=1.0).contains(&x) && (-1.0..=1.0).contains(&y) {
        Ok(())
    } else {
        Err(FxError::ShowConfig(
            "eye gaze values must be finite and between -1 and 1".into(),
        ))
    }
}

#[derive(Debug, Clone, Serialize)]
#[serde(deny_unknown_fields)]
pub struct SnapshotEnvelope {
    pub v: u8,
    #[serde(rename = "type")]
    pub kind: &'static str,
    #[serde(rename = "sessionId")]
    pub session_id: String,
    pub seq: u64,
    pub state: EyeSnapshot,
}

#[derive(Debug, Clone, Serialize)]
#[serde(deny_unknown_fields)]
pub struct CommandEnvelope {
    pub v: u8,
    #[serde(rename = "type")]
    pub kind: &'static str,
    #[serde(rename = "sessionId")]
    pub session_id: String,
    pub seq: u64,
    #[serde(rename = "expiresAtMs")]
    pub expires_at_ms: u64,
    pub command: EyeCommand,
}

struct ScreenInner {
    sequence: u64,
    state: EyeSnapshot,
    origins: BTreeMap<u64, Applied>,
}

struct Screen {
    inner: Mutex<ScreenInner>,
    commands: broadcast::Sender<CommandEnvelope>,
}

pub struct ScreenSubscription {
    pub snapshot: SnapshotEnvelope,
    pub commands: broadcast::Receiver<CommandEnvelope>,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct ScreenStatus {
    pub id: String,
    pub connected: bool,
    pub sequence: u64,
    pub state: EyeSnapshot,
    pub clients: Vec<DisplayClientStatus>,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct DisplayClientStatus {
    pub connection_id: String,
    pub client_id: String,
    pub name: String,
    pub screen_id: String,
    pub connected: bool,
    pub last_applied_sequence: Option<u64>,
    pub last_seen_at_ms: u64,
}

pub struct DisplayConnection {
    hub: ScreenHub,
    pub token: String,
}
impl Drop for DisplayConnection {
    fn drop(&mut self) {
        let mut clients = self.hub.clients.lock().expect("client mutex");
        if let Some(client) = clients.remove(&self.token) {
            self.hub
                .client_screens
                .lock()
                .expect("client screens mutex")
                .remove(&self.token);
            if let Err(error) = self
                .hub
                .devices
                .lock()
                .expect("device mutex")
                .disconnected(&client.client_id)
            {
                crate::fx_log!("could not save disconnected display: {error}");
            }
        }
    }
}

#[derive(Clone, Debug)]
pub struct Applied {
    screen_id: String,
    seq: u64,
}

#[derive(Clone)]
pub struct ScreenHub {
    session_id: Arc<str>,
    screens: Arc<BTreeMap<String, Arc<Screen>>>,
    clients: Arc<Mutex<BTreeMap<String, DisplayClientStatus>>>,
    client_screens: Arc<Mutex<BTreeMap<String, Arc<Screen>>>>,
    devices: Arc<Mutex<crate::display_registry::DisplayRegistry>>,
    applied: broadcast::Sender<Applied>,
}

impl ScreenHub {
    pub fn new(screens: impl IntoIterator<Item = (String, EyeSnapshot)>) -> Self {
        let screens = screens
            .into_iter()
            .map(|(id, state)| {
                let (commands, _) = broadcast::channel(COMMAND_BUFFER_CAPACITY);
                (
                    id,
                    Arc::new(Screen {
                        inner: Mutex::new(ScreenInner {
                            sequence: 0,
                            state,
                            origins: BTreeMap::new(),
                        }),
                        commands,
                    }),
                )
            })
            .collect();
        Self {
            session_id: Arc::from(Uuid::new_v4().to_string()),
            screens: Arc::new(screens),
            clients: Arc::new(Mutex::new(BTreeMap::new())),
            client_screens: Arc::new(Mutex::new(BTreeMap::new())),
            devices: Arc::new(Mutex::new(
                crate::display_registry::DisplayRegistry::default(),
            )),
            applied: broadcast::channel(128).0,
        }
    }

    pub fn with_registry(mut self, registry: crate::display_registry::DisplayRegistry) -> Self {
        self.devices = Arc::new(Mutex::new(registry));
        self
    }

    pub fn subscribe(&self, screen_id: &str) -> Result<ScreenSubscription> {
        let screen = self.screen(screen_id)?;
        // Publishing also holds this lock. Subscribing and capturing the
        // snapshot under the same lock prevents a command falling between the
        // snapshot and live subscription.
        let inner = screen.inner.lock().expect("screen state mutex poisoned");
        let commands = screen.commands.subscribe();
        let snapshot = SnapshotEnvelope {
            v: 1,
            kind: "snapshot",
            session_id: self.session_id.to_string(),
            seq: inner.sequence,
            state: inner.state.clone(),
        };
        drop(inner);
        Ok(ScreenSubscription { snapshot, commands })
    }

    pub fn publish(
        &self,
        screen_id: &str,
        command: EyeCommand,
        final_state: EyeSnapshot,
        expires_at_ms: u64,
    ) -> Result<CommandEnvelope> {
        // Serialize registration with group fan-out. Each connection has its own
        // state/sequence, so a private command cannot create gaps in another tab.
        let clients = self.clients.lock().expect("client mutex");
        let screen = self.screen(screen_id)?;
        let envelope = Self::publish_one(
            &screen,
            command.clone(),
            final_state.clone(),
            expires_at_ms,
            None,
            &self.session_id,
        )?;
        if self.screens.contains_key(screen_id) {
            let private = self.client_screens.lock().expect("client screens mutex");
            for (token, client) in clients
                .iter()
                .filter(|(_, client)| client.screen_id == screen_id)
            {
                if let Some(target) = private.get(token) {
                    Self::publish_one(
                        target,
                        command.clone(),
                        final_state.clone(),
                        expires_at_ms,
                        Some(Applied {
                            screen_id: client.screen_id.clone(),
                            seq: envelope.seq,
                        }),
                        &self.session_id,
                    )?;
                }
            }
        }
        Ok(envelope)
    }

    fn publish_one(
        screen: &Screen,
        command: EyeCommand,
        final_state: EyeSnapshot,
        expires_at_ms: u64,
        origin: Option<Applied>,
        session: &str,
    ) -> Result<CommandEnvelope> {
        let mut inner = screen.inner.lock().expect("screen state mutex poisoned");
        inner.sequence = inner
            .sequence
            .checked_add(1)
            .ok_or_else(|| FxError::Server("display sequence exhausted".into()))?;
        inner.state = final_state;
        let sequence = inner.sequence;
        if let Some(origin) = origin {
            inner.origins.insert(sequence, origin);
        }
        while inner.origins.len() > COMMAND_BUFFER_CAPACITY {
            inner.origins.pop_first();
        }
        let envelope = CommandEnvelope {
            v: 1,
            kind: "command",
            session_id: session.to_string(),
            seq: inner.sequence,
            expires_at_ms,
            command,
        };
        // No connected receivers is normal. Desired state and sequence still
        // advance so the next client gets the correct snapshot.
        let _ = screen.commands.send(envelope.clone());
        Ok(envelope)
    }

    pub fn statuses(&self) -> Vec<ScreenStatus> {
        let clients = self.clients.lock().expect("client mutex");
        self.screens
            .iter()
            .map(|(id, screen)| {
                let inner = screen.inner.lock().expect("screen state mutex poisoned");
                ScreenStatus {
                    id: id.clone(),
                    connected: clients.values().any(|client| client.screen_id == *id),
                    sequence: inner.sequence,
                    state: inner.state.clone(),
                    clients: clients
                        .values()
                        .filter(|c| c.screen_id == *id)
                        .cloned()
                        .collect(),
                }
            })
            .collect()
    }

    pub fn has_screen(&self, id: &str) -> bool {
        self.screens.contains_key(id)
    }

    pub fn has_client(&self, id: &str) -> bool {
        self.clients.lock().expect("client mutex").contains_key(id)
    }

    #[cfg(test)]
    pub fn register_client(
        &self,
        screen_id: &str,
        client_id: String,
        name: String,
    ) -> Result<DisplayConnection> {
        self.register_client_with_agent(screen_id, client_id, name, "")
    }

    pub fn register_client_with_agent(
        &self,
        screen_id: &str,
        client_id: String,
        name: String,
        agent: &str,
    ) -> Result<DisplayConnection> {
        let role = self
            .screens
            .get(screen_id)
            .ok_or_else(|| FxError::Server("unknown display group".into()))?;
        let mut clients = self.clients.lock().expect("client mutex");
        if clients.len() >= 128 {
            return Err(FxError::Server("display connection limit reached".into()));
        }
        let device = self
            .devices
            .lock()
            .expect("device mutex")
            .seen(&client_id, &name, agent)?;
        let token = Uuid::new_v4().to_string();
        let state = role.inner.lock().expect("screen mutex").state.clone();
        self.client_screens
            .lock()
            .expect("client screens mutex")
            .insert(
                token.clone(),
                Arc::new(Screen {
                    inner: Mutex::new(ScreenInner {
                        sequence: 0,
                        state,
                        origins: BTreeMap::new(),
                    }),
                    commands: broadcast::channel(COMMAND_BUFFER_CAPACITY).0,
                }),
            );
        clients.insert(
            token.clone(),
            DisplayClientStatus {
                connection_id: token.clone(),
                client_id,
                name: device.name,
                screen_id: screen_id.to_string(),
                connected: true,
                last_applied_sequence: None,
                last_seen_at_ms: crate::workflow::now_ms(),
            },
        );
        Ok(DisplayConnection {
            hub: self.clone(),
            token,
        })
    }

    pub fn heartbeat(&self, token: &str) {
        if let Some(client) = self.clients.lock().expect("client mutex").get_mut(token) {
            client.last_seen_at_ms = crate::workflow::now_ms();
        }
    }

    pub fn client_alive(&self, token: &str) -> bool {
        self.clients
            .lock()
            .expect("client mutex")
            .get(token)
            .is_some_and(|c| {
                c.connected && crate::workflow::now_ms().saturating_sub(c.last_seen_at_ms) < 20_000
            })
    }

    pub fn acknowledge(&self, token: &str, session: &str, seq: u64) -> bool {
        if session != self.session_id.as_ref() {
            return false;
        }
        let mut clients = self.clients.lock().expect("client mutex");
        let Some(client) = clients.get_mut(token) else {
            return false;
        };
        let Ok(screen) = self.screen(token) else {
            return false;
        };
        let mut inner = screen.inner.lock().expect("screen mutex");
        if seq == 0 || seq > inner.sequence {
            return false;
        }
        if client
            .last_applied_sequence
            .is_some_and(|previous| seq <= previous)
        {
            return true;
        }
        client.last_applied_sequence = Some(seq);
        client.last_seen_at_ms = crate::workflow::now_ms();
        let origin = inner.origins.remove(&seq);
        drop(clients);
        let _ = self.applied.send(Applied {
            screen_id: token.to_string(),
            seq,
        });
        if let Some(origin) = origin {
            let _ = self.applied.send(origin);
        }
        true
    }

    pub fn subscribe_applied(&self) -> broadcast::Receiver<Applied> {
        self.applied.subscribe()
    }

    pub async fn wait_applied(
        &self,
        mut events: broadcast::Receiver<Applied>,
        id: &str,
        seq: u64,
        timeout_ms: u64,
    ) -> std::result::Result<String, String> {
        tokio::time::timeout(Duration::from_millis(timeout_ms), async {
            loop {
                let event = events.recv().await.map_err(|e| e.to_string())?;
                if event.screen_id == id && event.seq == seq {
                    return Ok(
                        "display client accepted command (animation completion not asserted)"
                            .into(),
                    );
                }
            }
        })
        .await
        .map_err(|_| format!("display {id} did not acknowledge command {seq}"))?
    }

    fn screen(&self, screen_id: &str) -> Result<Arc<Screen>> {
        self.screens
            .get(screen_id)
            .cloned()
            .or_else(|| {
                self.client_screens
                    .lock()
                    .expect("client screens mutex")
                    .get(screen_id)
                    .cloned()
            })
            .ok_or_else(|| FxError::Server(format!("unknown screen `{screen_id}`")))
    }

    pub fn device_statuses(&self) -> Vec<DisplayDeviceStatus> {
        let clients = self.clients.lock().expect("client mutex");
        let screens = self.client_screens.lock().expect("client screens mutex");
        self.devices
            .lock()
            .expect("device mutex")
            .devices()
            .into_iter()
            .map(|device| {
                let connections = clients
                    .values()
                    .filter(|client| client.client_id == device.id)
                    .filter_map(|client| {
                        let inner = screens
                            .get(&client.connection_id)?
                            .inner
                            .lock()
                            .expect("screen mutex");
                        Some(LiveDisplayStatus {
                            client: client.clone(),
                            sequence: inner.sequence,
                            state: inner.state.clone(),
                        })
                    })
                    .collect();
                DisplayDeviceStatus {
                    device,
                    connections,
                }
            })
            .collect()
    }

    pub fn forget_device(&self, id: &str) -> Result<()> {
        let clients = self.clients.lock().expect("client mutex");
        if clients.values().any(|client| client.client_id == id) {
            return Err(FxError::Server(
                "close this display's tabs before forgetting it".into(),
            ));
        }
        self.devices.lock().expect("device mutex").forget(id)
    }
}

#[derive(Serialize)]
pub struct DisplayDeviceStatus {
    #[serde(flatten)]
    device: crate::display_registry::DisplayDevice,
    connections: Vec<LiveDisplayStatus>,
}

#[derive(Serialize)]
struct LiveDisplayStatus {
    #[serde(flatten)]
    client: DisplayClientStatus,
    sequence: u64,
    state: EyeSnapshot,
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sleeping() -> EyeSnapshot {
        EyeSnapshot {
            mode: EyeMode::Sleeping,
            gaze: Gaze { x: 0.0, y: 0.0 },
        }
    }

    fn tipping() -> EyeSnapshot {
        EyeSnapshot {
            mode: EyeMode::Tipping,
            gaze: Gaze { x: -0.25, y: -0.65 },
        }
    }

    #[test]
    fn disconnected_sessions_do_not_accumulate_or_remove_other_live_tabs() {
        let hub = ScreenHub::new([("eye".into(), sleeping())]);
        let live = hub
            .register_client("eye", "ipad".into(), "iPad".into())
            .unwrap();
        let mirror = hub
            .register_client("eye", "ipad".into(), "iPad".into())
            .unwrap();
        assert_eq!(hub.statuses()[0].clients.len(), 2);
        drop(mirror);
        assert_eq!(hub.statuses()[0].clients[0].connection_id, live.token);
        for index in 0..200 {
            drop(
                hub.register_client("eye", format!("test-{index}"), "Test".into())
                    .unwrap(),
            );
        }
        assert_eq!(hub.statuses()[0].clients.len(), 1);
        drop(live);
        assert!(hub.statuses()[0].clients.is_empty());
    }

    #[tokio::test]
    async fn individual_connections_are_independent_and_group_ack_survives_private_sequences() {
        let hub = ScreenHub::new([("eye".into(), sleeping())]);
        let left = hub
            .register_client("eye", "same-browser".into(), "Browser".into())
            .unwrap();
        let right = hub
            .register_client("eye", "same-browser".into(), "Browser".into())
            .unwrap();
        let mut a = hub.subscribe(&left.token).unwrap();
        let mut b = hub.subscribe(&right.token).unwrap();
        hub.publish(&left.token, EyeCommand::Wake, tipping(), u64::MAX)
            .unwrap();
        assert_eq!(a.commands.recv().await.unwrap().seq, 1);
        assert!(b.commands.try_recv().is_err());
        assert!(!hub.acknowledge(&right.token, &hub.session_id, 1));
        let pending = hub.subscribe_applied();
        assert!(hub.acknowledge(&left.token, &hub.session_id, 1));
        assert!(hub.wait_applied(pending, &left.token, 1, 100).await.is_ok());
        let role = hub
            .publish("eye", EyeCommand::Reset, sleeping(), u64::MAX)
            .unwrap();
        assert_eq!(a.commands.recv().await.unwrap().seq, 2);
        assert_eq!(b.commands.recv().await.unwrap().seq, 1);
        let pending = hub.subscribe_applied();
        assert!(hub.acknowledge(&left.token, &hub.session_id, 2));
        assert!(
            hub.wait_applied(pending, "eye", role.seq, 100)
                .await
                .is_ok()
        );
        assert_eq!(hub.device_statuses().len(), 1);
        assert_eq!(hub.device_statuses()[0].connections.len(), 2);
        assert!(hub.forget_device("same-browser").is_err());
        drop(left);
        drop(right);
        assert!(hub.device_statuses()[0].connections.is_empty());
        hub.forget_device("same-browser").unwrap();
        assert!(hub.device_statuses().is_empty());
    }

    #[tokio::test]
    async fn routes_roles_independently_and_requires_ack_from_the_correct_role_and_session() {
        let hub = ScreenHub::new([("left".into(), sleeping()), ("right".into(), sleeping())]);
        let left = hub
            .register_client("left", "pi".into(), "Pi display".into())
            .unwrap();
        let right = hub
            .register_client("right", "ipad".into(), "iPad".into())
            .unwrap();
        let mut left_stream = hub.subscribe("left").unwrap();
        let mut right_stream = hub.subscribe("right").unwrap();
        hub.publish("left", EyeCommand::Wake, tipping(), u64::MAX)
            .unwrap();
        assert_eq!(left_stream.commands.recv().await.unwrap().seq, 1);
        assert!(right_stream.commands.try_recv().is_err());
        assert!(!hub.acknowledge(&left.token, "old-server", 1));
        assert!(!hub.acknowledge(&left.token, hub.session_id.as_ref(), 2));
        hub.publish("right", EyeCommand::Wake, tipping(), u64::MAX)
            .unwrap();
        let pending = hub.subscribe_applied();
        assert!(hub.acknowledge(&right.token, hub.session_id.as_ref(), 1));
        assert!(hub.wait_applied(pending, "left", 1, 1).await.is_err());
        let pending = hub.subscribe_applied();
        assert!(hub.acknowledge(&left.token, hub.session_id.as_ref(), 1));
        assert!(hub.wait_applied(pending, "left", 1, 100).await.is_ok());
        drop(left);
        let states = hub.statuses();
        assert!(states[0].clients.is_empty());
        assert!(states[1].clients[0].connected);
    }

    #[tokio::test]
    async fn publishes_ordered_commands_after_an_atomic_snapshot() {
        let hub = ScreenHub::new([("tractor-eye".into(), sleeping())]);
        let mut subscription = hub.subscribe("tractor-eye").unwrap();
        assert_eq!(subscription.snapshot.seq, 0);
        assert_eq!(subscription.snapshot.state, sleeping());

        let sent = hub
            .publish("tractor-eye", EyeCommand::Wake, tipping(), 1234)
            .unwrap();
        let received = subscription.commands.recv().await.unwrap();
        assert_eq!(sent.seq, 1);
        assert_eq!(received.seq, 1);
        assert_eq!(received.command, EyeCommand::Wake);
    }

    #[test]
    fn disconnected_screen_recovers_final_state_without_replaying_command() {
        let hub = ScreenHub::new([("tractor-eye".into(), sleeping())]);
        hub.publish("tractor-eye", EyeCommand::Wake, tipping(), 1234)
            .unwrap();
        let subscription = hub.subscribe("tractor-eye").unwrap();
        assert_eq!(subscription.snapshot.seq, 1);
        assert_eq!(subscription.snapshot.state, tipping());
        assert!(subscription.commands.is_empty());
    }

    #[test]
    fn serializes_the_browser_contract() {
        let command = CommandEnvelope {
            v: 1,
            kind: "command",
            session_id: "boot-1".into(),
            seq: 7,
            expires_at_ms: 1000,
            command: EyeCommand::Wake,
        };
        assert_eq!(
            serde_json::to_value(command).unwrap(),
            serde_json::json!({
                "v": 1,
                "type": "command",
                "sessionId": "boot-1",
                "seq": 7,
                "expiresAtMs": 1000,
                "command": { "type": "eye/wake" }
            })
        );
    }
}
