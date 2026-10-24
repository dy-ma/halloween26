use std::{path::PathBuf, process::Command};

use crate::{
    FxError, Result,
    audio::{AudioDevice, AudioSystem, DeviceSelector, PlaybackRequest},
};

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct SinkVolume {
    pub level: f32,
    pub muted: bool,
}

#[derive(Debug, Clone)]
pub struct PipeWire {
    wpctl_program: PathBuf,
    play_program: PathBuf,
}

impl Default for PipeWire {
    fn default() -> Self {
        Self {
            wpctl_program: "wpctl".into(),
            play_program: "pw-play".into(),
        }
    }
}

impl PipeWire {
    pub fn playback_command(&self, request: &PlaybackRequest) -> Result<Command> {
        if request
            .options
            .volume
            .is_some_and(|volume| !(0.0..=1.0).contains(&volume))
        {
            return Err(FxError::InvalidPlayback(
                "volume must be between 0 and 1".into(),
            ));
        }
        let mut command = Command::new(&self.play_program);
        if let DeviceSelector::Id(id) = &request.device {
            command.arg("--target").arg(id);
            // A missing/disconnected show output must not migrate to a different speaker.
            command.arg("--properties").arg(
                r#"{"node.dont-fallback":true,"node.dont-reconnect":true,"node.linger":false}"#,
            );
        }
        if let Some(volume) = request.options.volume {
            command.arg("--volume").arg(volume.to_string());
        }
        if let Some(latency) = &request.options.latency {
            command.arg("--latency").arg(latency);
        }
        command.arg(&request.file);
        Ok(command)
    }

    pub fn with_programs(wpctl: impl Into<PathBuf>, pw_play: impl Into<PathBuf>) -> Self {
        Self {
            wpctl_program: wpctl.into(),
            play_program: pw_play.into(),
        }
    }

    pub fn status(&self) -> Result<String> {
        self.run_wpctl(&["status", "--name"])
    }

    pub fn set_default(&self, backend_index: u32) -> Result<()> {
        self.run_wpctl(&["set-default", &backend_index.to_string()])?;
        Ok(())
    }

    pub fn volume(&self, target: &str) -> Result<SinkVolume> {
        let output = self.run_wpctl(&["get-volume", target])?;
        parse_volume(&output).ok_or_else(|| {
            FxError::InvalidPlayback(format!("could not parse PipeWire volume: {output:?}"))
        })
    }

    pub fn set_volume_percent(&self, target: &str, percent: u8) -> Result<()> {
        self.run_wpctl(&[
            "set-volume",
            "--limit",
            "1.0",
            target,
            &format!("{percent}%"),
        ])?;
        Ok(())
    }

    pub fn change_volume_percent(&self, target: &str, percent: u8, increase: bool) -> Result<()> {
        let direction = if increase { '+' } else { '-' };
        self.run_wpctl(&[
            "set-volume",
            "--limit",
            "1.0",
            target,
            &format!("{percent}%{direction}"),
        ])?;
        Ok(())
    }

    pub fn set_muted(&self, target: &str, value: &str) -> Result<()> {
        self.run_wpctl(&["set-mute", target, value])?;
        Ok(())
    }

    fn run_wpctl(&self, args: &[&str]) -> Result<String> {
        let output = Command::new(&self.wpctl_program).args(args).output()?;
        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            Err(FxError::CommandFailed {
                program: self.wpctl_program.display().to_string(),
                status: output.status,
                stderr: String::from_utf8_lossy(&output.stderr).trim().to_string(),
            })
        }
    }
}

pub fn parse_volume(output: &str) -> Option<SinkVolume> {
    let mut fields = output.split_whitespace();
    if fields.next()? != "Volume:" {
        return None;
    }
    let level = fields.next()?.parse::<f32>().ok()?;
    Some(SinkVolume {
        level,
        muted: output.contains("[MUTED]"),
    })
}

impl AudioSystem for PipeWire {
    fn devices(&self) -> Result<Vec<AudioDevice>> {
        Ok(parse_devices(&self.status()?))
    }

    fn play(&self, request: &PlaybackRequest) -> Result<()> {
        let output = self.playback_command(request)?.output()?;
        if output.status.success() {
            Ok(())
        } else {
            Err(FxError::CommandFailed {
                program: self.play_program.display().to_string(),
                status: output.status,
                stderr: String::from_utf8_lossy(&output.stderr).trim().to_string(),
            })
        }
    }
}

pub fn parse_devices(status: &str) -> Vec<AudioDevice> {
    let mut in_audio = false;
    let mut in_sinks = false;
    let mut devices = Vec::new();

    for line in status.lines() {
        let trimmed = line.trim();
        if trimmed == "Audio" {
            in_audio = true;
            continue;
        }
        if in_audio && trimmed == "Video" {
            break;
        }
        if !in_audio {
            continue;
        }
        if trimmed.contains("Sinks:") {
            in_sinks = true;
            continue;
        }
        if in_sinks && (trimmed.contains("Sources:") || trimmed.contains("Filters:")) {
            break;
        }
        if !in_sinks || !trimmed.contains('.') {
            continue;
        }

        let is_default = trimmed.contains('*');
        let cleaned = trimmed
            .trim_start_matches(['│', '├', '└', '─', ' ', '*'])
            .trim();
        let Some((index_text, remainder)) = cleaned.split_once('.') else {
            continue;
        };
        let Ok(backend_index) = index_text.trim().parse::<u32>() else {
            continue;
        };
        let id = remainder
            .split_once(" [")
            .map(|(name, _)| name)
            .unwrap_or(remainder)
            .trim();
        if !id.is_empty() {
            devices.push(AudioDevice {
                id: id.to_string(),
                label: id.to_string(),
                is_default,
                backend_index: Some(backend_index),
            });
        }
    }

    devices
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn explicit_playback_target_disables_automatic_output_fallback() {
        let request = PlaybackRequest::new(
            "/tmp/test.wav",
            DeviceSelector::Id("bluez_output.test".into()),
        );
        let command = PipeWire::default().playback_command(&request).unwrap();
        let arguments: Vec<_> = command
            .get_args()
            .map(|argument| argument.to_string_lossy().into_owned())
            .collect();
        assert!(
            arguments
                .windows(2)
                .any(|pair| pair == ["--target", "bluez_output.test"])
        );
        assert!(
            arguments
                .iter()
                .any(|argument| argument.contains("node.dont-fallback"))
        );
        let mut invalid = request;
        invalid.options.volume = Some(1.1);
        assert!(PipeWire::default().playback_command(&invalid).is_err());
    }

    #[test]
    fn parses_audio_devices_from_wpctl_status() {
        let status = "\
Audio
 ├─ Devices:
 │      48. alsa_card.platform.mailbox [alsa]
 ├─ Sinks:
 │      35. alsa_output.hdmi [vol: 0.40]
 │  *   88. bluez_output.74_68_59_F0_F2_F4.1 [vol: 0.44]
 ├─ Sources:
Video
";

        assert_eq!(
            parse_devices(status),
            vec![
                AudioDevice {
                    id: "alsa_output.hdmi".into(),
                    label: "alsa_output.hdmi".into(),
                    is_default: false,
                    backend_index: Some(35),
                },
                AudioDevice {
                    id: "bluez_output.74_68_59_F0_F2_F4.1".into(),
                    label: "bluez_output.74_68_59_F0_F2_F4.1".into(),
                    is_default: true,
                    backend_index: Some(88),
                },
            ]
        );
    }

    #[test]
    fn parses_sink_volume_and_mute_state() {
        assert_eq!(
            parse_volume("Volume: 0.72\n"),
            Some(SinkVolume {
                level: 0.72,
                muted: false,
            })
        );
        assert_eq!(
            parse_volume("Volume: 0.40 [MUTED]\n"),
            Some(SinkVolume {
                level: 0.40,
                muted: true,
            })
        );
        assert_eq!(parse_volume("not volume"), None);
    }
}
