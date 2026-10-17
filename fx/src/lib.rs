//! Play an audio file on a selected system audio device.

pub mod audio;
pub mod bluetooth;
pub mod pipewire;

pub use audio::{AudioDevice, AudioSystem, DeviceSelector, PlaybackOptions, PlaybackRequest};
pub use pipewire::PipeWire;

use std::process::ExitStatus;

use thiserror::Error;

pub type Result<T> = std::result::Result<T, FxError>;

#[derive(Debug, Error)]
pub enum FxError {
    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),

    #[error("invalid playback request: {0}")]
    InvalidPlayback(String),

    #[error("invalid Bluetooth response: {0}")]
    InvalidBluetooth(String),

    #[error("invalid device alias: {0}")]
    InvalidAlias(String),

    #[error("serial error: {0}")]
    Serial(String),

    #[error("show configuration error: {0}")]
    ShowConfig(String),

    #[error("show server error: {0}")]
    Server(String),

    #[error("command `{program}` failed with {status}: {stderr}")]
    CommandFailed {
        program: String,
        status: ExitStatus,
        stderr: String,
    },
}
