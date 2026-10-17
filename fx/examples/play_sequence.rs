use std::{path::PathBuf, time::Duration};

use fx_audio::{AudioSystem, DeviceSelector, PipeWire, PlaybackRequest, Result};

fn main() -> Result<()> {
    let audio = PipeWire::default();
    let device = DeviceSelector::Default;

    // Higher-level sequencing is ordinary composition of the play primitive.
    for file in ["first.wav", "second.wav"] {
        audio.play(&PlaybackRequest::new(PathBuf::from(file), device.clone()))?;
        std::thread::sleep(Duration::from_millis(250));
    }

    Ok(())
}
