use std::path::PathBuf;

use crate::Result;

/// A stable audio output exposed by the host audio system.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AudioDevice {
    /// Stable backend identifier, such as a PipeWire node name.
    pub id: String,
    /// Human-readable label when available.
    pub label: String,
    pub is_default: bool,
    /// Ephemeral backend index, useful for commands such as `wpctl set-default`.
    pub backend_index: Option<u32>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum DeviceSelector {
    Default,
    Id(String),
}

impl From<Option<String>> for DeviceSelector {
    fn from(value: Option<String>) -> Self {
        match value {
            Some(id) => Self::Id(id),
            None => Self::Default,
        }
    }
}

#[derive(Debug, Clone, Default, PartialEq)]
pub struct PlaybackOptions {
    pub volume: Option<f32>,
    pub latency: Option<String>,
}

#[derive(Debug, Clone, PartialEq)]
pub struct PlaybackRequest {
    pub file: PathBuf,
    pub device: DeviceSelector,
    pub options: PlaybackOptions,
}

impl PlaybackRequest {
    pub fn new(file: impl Into<PathBuf>, device: DeviceSelector) -> Self {
        Self {
            file: file.into(),
            device,
            options: PlaybackOptions::default(),
        }
    }
}

/// The intentionally small boundary that orchestration layers compose.
pub trait AudioSystem {
    fn devices(&self) -> Result<Vec<AudioDevice>>;
    fn play(&self, request: &PlaybackRequest) -> Result<()>;
}
