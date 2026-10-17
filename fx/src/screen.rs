use std::{
    collections::BTreeMap,
    sync::{Arc, Mutex},
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
}

struct Screen {
    inner: Mutex<ScreenInner>,
    commands: broadcast::Sender<CommandEnvelope>,
}

pub struct ScreenSubscription {
    pub snapshot: SnapshotEnvelope,
    pub commands: broadcast::Receiver<CommandEnvelope>,
}

#[derive(Clone)]
pub struct ScreenHub {
    session_id: Arc<str>,
    screens: Arc<BTreeMap<String, Arc<Screen>>>,
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
                        inner: Mutex::new(ScreenInner { sequence: 0, state }),
                        commands,
                    }),
                )
            })
            .collect();
        Self {
            session_id: Arc::from(Uuid::new_v4().to_string()),
            screens: Arc::new(screens),
        }
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
        let screen = self.screen(screen_id)?;
        let mut inner = screen.inner.lock().expect("screen state mutex poisoned");
        inner.sequence = inner.sequence.checked_add(1).ok_or_else(|| {
            FxError::Server(format!(
                "screen `{screen_id}` exhausted its sequence counter"
            ))
        })?;
        inner.state = final_state;
        let envelope = CommandEnvelope {
            v: 1,
            kind: "command",
            session_id: self.session_id.to_string(),
            seq: inner.sequence,
            expires_at_ms,
            command,
        };
        // No connected receivers is normal. Desired state and sequence still
        // advance so the next client gets the correct snapshot.
        let _ = screen.commands.send(envelope.clone());
        Ok(envelope)
    }

    fn screen(&self, screen_id: &str) -> Result<Arc<Screen>> {
        self.screens
            .get(screen_id)
            .cloned()
            .ok_or_else(|| FxError::Server(format!("unknown screen `{screen_id}`")))
    }
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
