//! Named source tracks, discovered physical outputs, and independently stoppable voices.
use crate::{
    aliases::DeviceAliases,
    show_config::{ShowConfig, SinkConfig},
    workflow::{WorkflowHub, now_ms},
};
use fx_audio::{
    audio::{DeviceSelector, PlaybackOptions, PlaybackRequest},
    bluetooth::{parse_device_info, parse_devices},
    pipewire::{PipeWire, parse_devices as parse_outputs, parse_volume},
};
use serde::Serialize;
use std::{
    collections::BTreeMap,
    path::PathBuf,
    process::Stdio,
    sync::{Arc, Mutex},
    time::{Duration, Instant},
};
use tokio::{
    process::Command,
    sync::{Semaphore, watch},
};

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Track {
    pub id: String,
    pub label: String,
    pub file_name: String,
    pub format: String,
    pub available: bool,
    pub duration_ms: Option<u64>,
    #[serde(skip)]
    file: PathBuf,
}

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Output {
    pub id: String,
    pub label: String,
    pub kind: &'static str,
    pub aliases: Vec<String>,
    pub paired: bool,
    pub connected: bool,
    pub ready: bool,
    pub percent: Option<u8>,
    pub muted: bool,
    #[serde(skip)]
    backend: Option<String>,
    #[serde(skip)]
    backend_index: Option<u32>,
    #[serde(skip)]
    address: Option<String>,
}

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Playback {
    pub id: String,
    pub track: String,
    pub output: String,
    pub phase: &'static str,
    pub started_at_ms: u64,
    pub detail: String,
}

struct Voice {
    status: Playback,
    stop: watch::Sender<bool>,
}
struct Inner {
    outputs: Vec<Output>,
    errors: Vec<String>,
    refreshed: Option<Instant>,
    voices: BTreeMap<String, Voice>,
    stop_generation: u64,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Snapshot {
    pub host: String,
    pub tracks: Vec<Track>,
    pub outputs: Vec<Output>,
    pub playbacks: Vec<Playback>,
    pub errors: Vec<String>,
    pub max_active: usize,
}

#[derive(Clone)]
pub struct AudioRuntime {
    tracks: Arc<BTreeMap<String, Track>>,
    bindings: Arc<BTreeMap<String, String>>,
    inner: Arc<Mutex<Inner>>,
    refresh_lock: Arc<tokio::sync::Mutex<()>>,
    slots: Arc<Semaphore>,
    max_active: usize,
}

pub struct Ticket {
    pub id: String,
    done: watch::Receiver<Option<Result<String, String>>>,
}
impl Ticket {
    pub async fn wait(mut self) -> Result<String, String> {
        loop {
            if let Some(result) = self.done.borrow_and_update().clone() {
                return result;
            }
            self.done
                .changed()
                .await
                .map_err(|_| "audio player stopped unexpectedly".to_string())?;
        }
    }
}

impl AudioRuntime {
    pub fn new(show: &ShowConfig, slots: Arc<Semaphore>) -> fx_audio::Result<Self> {
        let aliases = DeviceAliases::load_default()?;
        let tracks = show
            .assets
            .iter()
            .map(|(id, asset)| {
                let file = asset.audio_file().to_path_buf();
                (
                    id.clone(),
                    Track {
                        id: id.clone(),
                        label: id.replace(['_', '-'], " "),
                        file_name: file
                            .file_name()
                            .unwrap_or_default()
                            .to_string_lossy()
                            .into_owned(),
                        format: file
                            .extension()
                            .unwrap_or_default()
                            .to_string_lossy()
                            .to_uppercase(),
                        available: file.is_file(),
                        duration_ms: std::fs::File::open(&file).ok().and_then(wav_duration),
                        file,
                    },
                )
            })
            .collect();
        let bindings = show
            .sinks
            .iter()
            .filter_map(|(id, sink)| match sink {
                SinkConfig::Audio { device, .. } => {
                    Some((id.clone(), aliases.resolve(Some(device.clone())).unwrap()))
                }
                _ => None,
            })
            .collect();
        Ok(Self {
            tracks: Arc::new(tracks),
            bindings: Arc::new(bindings),
            inner: Arc::new(Mutex::new(Inner {
                outputs: Vec::new(),
                errors: Vec::new(),
                refreshed: None,
                voices: BTreeMap::new(),
                stop_generation: 0,
            })),
            refresh_lock: Arc::new(tokio::sync::Mutex::new(())),
            slots,
            max_active: show.playback.max_active,
        })
    }

    async fn refresh(&self) {
        let _guard = self.refresh_lock.lock().await;
        if self
            .inner
            .lock()
            .unwrap()
            .refreshed
            .is_some_and(|time| time.elapsed() < Duration::from_secs(2))
        {
            return;
        }
        let result = tokio::time::timeout(Duration::from_secs(6), self.discover()).await;
        let mut inner = self.inner.lock().unwrap();
        match result {
            Ok((outputs, errors)) => {
                inner.outputs = outputs;
                inner.errors = errors;
            }
            Err(_) => {
                for output in &mut inner.outputs {
                    output.ready = false;
                }
                inner.errors = vec!["Audio discovery timed out".into()];
            }
        }
        inner.refreshed = Some(Instant::now());
    }

    async fn discover(&self) -> (Vec<Output>, Vec<String>) {
        let (pipewire, bluetooth) = tokio::join!(
            run("wpctl", &["status", "--name"], 2),
            run("bluetoothctl", &["devices", "Paired"], 2)
        );
        let mut errors = Vec::new();
        let nodes = match pipewire {
            Ok(text) => parse_outputs(&text),
            Err(error) => {
                errors.push(error);
                Vec::new()
            }
        };
        let mut outputs: BTreeMap<String, Output> = nodes
            .iter()
            .map(|node| {
                let (id, address) = output_id(&node.id);
                let label = if node.id.contains("hdmi") {
                    "HDMI output"
                } else if node.id.contains("mailbox") {
                    "Pi analog output"
                } else {
                    &node.label
                };
                (
                    id.clone(),
                    Output {
                        id,
                        label: label.into(),
                        kind: if address.is_some() {
                            "bluetooth"
                        } else {
                            "local"
                        },
                        aliases: Vec::new(),
                        paired: false,
                        connected: true,
                        ready: true,
                        percent: None,
                        muted: false,
                        backend: Some(node.id.clone()),
                        backend_index: node.backend_index,
                        address,
                    },
                )
            })
            .collect();
        match bluetooth {
            Ok(text) => {
                for device in parse_devices(&text).into_iter().take(32) {
                    if let Ok(info) = run("bluetoothctl", &["info", &device.address], 2).await
                        && (info.contains("0000110b-") || info.contains("Icon: audio-card"))
                        && let Some(status) = parse_device_info(&info)
                    {
                        let id = format!("bluetooth:{}", device.address);
                        let output = outputs.entry(id.clone()).or_insert(Output {
                            id,
                            label: status.name.clone(),
                            kind: "bluetooth",
                            aliases: Vec::new(),
                            paired: true,
                            connected: false,
                            ready: false,
                            percent: None,
                            muted: false,
                            backend: None,
                            backend_index: None,
                            address: Some(device.address),
                        });
                        output.label = status.name;
                        output.paired = status.paired;
                        output.connected = status.connected;
                        output.ready &= status.connected;
                    }
                }
            }
            Err(error) => errors.push(error),
        }
        for (alias, backend) in self.bindings.iter() {
            let (id, address) = output_id(backend);
            let output = outputs.entry(id.clone()).or_insert(Output {
                id,
                label: alias.clone(),
                kind: "configured",
                aliases: Vec::new(),
                paired: false,
                connected: false,
                ready: false,
                percent: None,
                muted: false,
                backend: None,
                backend_index: None,
                address,
            });
            output.aliases.push(alias.clone());
        }
        for output in outputs.values_mut().filter(|output| output.ready) {
            if let Some(node) = nodes
                .iter()
                .find(|node| Some(&node.id) == output.backend.as_ref())
                && let Some(index) = node.backend_index
                && let Ok(text) = run("wpctl", &["get-volume", &index.to_string()], 2).await
                && let Some(volume) = parse_volume(&text)
            {
                output.percent = Some((volume.level * 100.0).round().clamp(0.0, 100.0) as u8);
                output.muted = volume.muted;
            }
        }
        (outputs.into_values().collect(), errors)
    }

    pub async fn snapshot(&self) -> Snapshot {
        self.refresh().await;
        let inner = self.inner.lock().unwrap();
        let mut playbacks: Vec<_> = inner
            .voices
            .values()
            .map(|voice| voice.status.clone())
            .collect();
        playbacks.sort_by_key(|playback| std::cmp::Reverse(playback.started_at_ms));
        Snapshot {
            host: std::env::var("HOSTNAME")
                .ok()
                .or_else(|| {
                    std::fs::read_to_string("/etc/hostname")
                        .ok()
                        .map(|name| name.trim().to_string())
                })
                .unwrap_or_else(|| "FX host".into()),
            tracks: self
                .tracks
                .values()
                .map(|track| {
                    let mut track = track.clone();
                    track.available = track.file.is_file();
                    track
                })
                .collect(),
            outputs: inner.outputs.clone(),
            playbacks,
            errors: inner.errors.clone(),
            max_active: self.max_active,
        }
    }

    async fn output(&self, id: &str) -> Result<Output, String> {
        self.refresh().await;
        self.inner
            .lock()
            .unwrap()
            .outputs
            .iter()
            .find(|output| output.id == id || output.aliases.iter().any(|alias| alias == id))
            .cloned()
            .ok_or_else(|| "unknown audio output".into())
    }

    pub async fn play(
        &self,
        track: &str,
        target: &str,
        volume: Option<f32>,
        log: &WorkflowHub,
    ) -> Result<Ticket, String> {
        let generation = self.inner.lock().unwrap().stop_generation;
        self.play_in_generation(track, target, volume, log, generation)
            .await
    }

    async fn play_in_generation(
        &self,
        track: &str,
        target: &str,
        volume: Option<f32>,
        log: &WorkflowHub,
        generation: u64,
    ) -> Result<Ticket, String> {
        let track = self.tracks.get(track).ok_or("unknown audio track")?;
        if !track.file.is_file() {
            return Err("audio file is unavailable".into());
        }
        let output = self.output(target).await?;
        if !output.ready {
            return Err(format!("{} is not ready for audio", output.label));
        }
        let permit = self
            .slots
            .clone()
            .try_acquire_owned()
            .map_err(|_| "all audio playback slots are active")?;
        let request = PlaybackRequest {
            file: track.file.clone(),
            device: DeviceSelector::Id(output.backend.clone().ok_or("output has no audio sink")?),
            options: PlaybackOptions {
                volume,
                latency: None,
            },
        };
        let command = PipeWire::default()
            .playback_command(&request)
            .map_err(|error| error.to_string())?;
        let id = uuid::Uuid::new_v4().to_string();
        let watched_output = output.id.clone();
        let watched_backend = output.backend.clone();
        let (stop, mut stopping) = watch::channel(false);
        let (done, receiver) = watch::channel(None);
        let mut child = {
            let mut inner = self.inner.lock().unwrap();
            // STOP ALL also cancels a play request still awaiting discovery.
            // Check, spawn, and registration are atomic with respect to stop_all.
            if inner.stop_generation != generation {
                return Err("audio start cancelled by STOP ALL".into());
            }
            let child = Command::from(command)
                .stdin(Stdio::null())
                .stdout(Stdio::null())
                .stderr(Stdio::inherit())
                .kill_on_drop(true)
                .spawn()
                .map_err(|error| error.to_string())?;
            while inner.voices.len() >= 128 {
                let oldest = inner
                    .voices
                    .iter()
                    .filter(|(_, voice)| voice.status.phase != "playing")
                    .min_by_key(|(_, voice)| voice.status.started_at_ms)
                    .map(|(id, _)| id.clone());
                if let Some(oldest) = oldest {
                    inner.voices.remove(&oldest);
                } else {
                    break;
                }
            }
            inner.voices.insert(
                id.clone(),
                Voice {
                    stop,
                    status: Playback {
                        id: id.clone(),
                        track: track.id.clone(),
                        output: output.id,
                        phase: "playing",
                        started_at_ms: now_ms(),
                        detail: format!("{} → {}", track.label, output.label),
                    },
                },
            );
            child
        };
        log.note(format!("Audio {}: {} → {}", id, track.label, output.label));
        let runtime = self.clone();
        let playback_id = id.clone();
        let log = log.clone();
        tokio::spawn(async move {
            let _permit = permit;
            let lost_output = async {
                loop {
                    tokio::time::sleep(Duration::from_secs(2)).await;
                    match runtime.output(&watched_output).await {
                        Ok(output) if output.ready && output.backend == watched_backend => {}
                        _ => break,
                    }
                }
            };
            let (phase, result) = tokio::select! {
                biased;
                _ = stopping.changed() => {
                    let result = child.kill().await;
                    if let Err(error) = result { ("failed", Err(format!("could not stop audio: {error}"))) }
                    else { ("stopped", Err("audio stopped by operator".to_string())) }
                }
                status = child.wait() => match status {
                    Ok(status) if status.success() => ("finished", Ok("audio playback finished".to_string())),
                    Ok(status) => ("failed", Err(format!("audio player exited: {status}"))),
                    Err(error) => ("failed", Err(error.to_string())),
                },
                _ = lost_output => {
                    let _ = child.kill().await;
                    ("failed", Err("selected audio output disconnected or changed".to_string()))
                }
            };
            let detail = result.clone().unwrap_or_else(|error| error);
            if let Some(voice) = runtime.inner.lock().unwrap().voices.get_mut(&playback_id) {
                voice.status.phase = phase;
                voice.status.detail = detail.clone();
            }
            log.note(format!("Audio {playback_id}: {phase} — {detail}"));
            let _ = done.send(Some(result));
        });
        Ok(Ticket { id, done: receiver })
    }

    pub fn stop(&self, id: &str) -> Result<(), String> {
        let inner = self.inner.lock().unwrap();
        let voice = inner.voices.get(id).ok_or("unknown playback")?;
        if voice.status.phase == "playing" {
            voice
                .stop
                .send(true)
                .map_err(|_| "audio player unavailable")?;
        }
        Ok(())
    }

    pub fn stop_all(&self) {
        let mut inner = self.inner.lock().unwrap();
        inner.stop_generation = inner.stop_generation.wrapping_add(1);
        for voice in inner
            .voices
            .values()
            .filter(|voice| voice.status.phase == "playing")
        {
            let _ = voice.stop.send(true);
        }
    }

    pub async fn set_volume(&self, id: &str, percent: u8) -> Result<(), String> {
        if percent > 100 {
            return Err("volume must be 0–100".into());
        }
        self.inner.lock().unwrap().refreshed = None;
        let output = self.output(id).await?;
        let backend = output
            .backend_index
            .filter(|_| output.ready)
            .ok_or("output is not ready")?
            .to_string();
        run(
            "wpctl",
            &[
                "set-volume",
                "--limit",
                "1.0",
                &backend,
                &format!("{percent}%"),
            ],
            2,
        )
        .await?;
        if percent > 0 {
            run("wpctl", &["set-mute", &backend, "0"], 2).await?;
        }
        self.inner.lock().unwrap().refreshed = None;
        Ok(())
    }

    pub async fn bluetooth(&self, id: &str, connect: bool) -> Result<(), String> {
        let output = self.output(id).await?;
        if !output.paired {
            return Err("pair this speaker with the Pi first".into());
        }
        let address = output.address.ok_or("not a Bluetooth speaker")?;
        if !connect {
            for voice in
                self.inner.lock().unwrap().voices.values().filter(|voice| {
                    voice.status.output == output.id && voice.status.phase == "playing"
                })
            {
                let _ = voice.stop.send(true);
            }
        }
        let result = run(
            "bluetoothctl",
            &[
                "--timeout",
                "12",
                if connect { "connect" } else { "disconnect" },
                &address,
            ],
            14,
        )
        .await;
        self.inner.lock().unwrap().refreshed = None;
        let text = result?;
        if text.contains("Failed to ") || text.contains("not available") {
            return Err(text);
        }
        Ok(())
    }
}

fn output_id(backend: &str) -> (String, Option<String>) {
    if let Some(address) = backend
        .strip_prefix("bluez_output.")
        .and_then(|rest| rest.get(..17))
    {
        let address = address.replace('_', ":").to_uppercase();
        if address.split(':').count() == 6
            && address
                .split(':')
                .all(|byte| byte.len() == 2 && u8::from_str_radix(byte, 16).is_ok())
        {
            return (format!("bluetooth:{address}"), Some(address));
        }
    }
    (format!("pipewire:{backend}"), None)
}

fn wav_duration(mut file: impl std::io::Read + std::io::Seek) -> Option<u64> {
    use std::io::SeekFrom;
    let mut header = [0; 12];
    file.read_exact(&mut header).ok()?;
    if &header[..4] != b"RIFF" || &header[8..] != b"WAVE" {
        return None;
    }
    let mut byte_rate = None;
    for _ in 0..128 {
        let mut chunk = [0; 8];
        file.read_exact(&mut chunk).ok()?;
        let size = u32::from_le_bytes(chunk[4..].try_into().ok()?);
        if &chunk[..4] == b"fmt " && size >= 16 {
            let mut format = [0; 16];
            file.read_exact(&mut format).ok()?;
            let codec = u16::from_le_bytes(format[..2].try_into().ok()?);
            if codec != 1 && codec != 3 {
                return None;
            }
            byte_rate = Some(u32::from_le_bytes(format[8..12].try_into().ok()?));
            file.seek(SeekFrom::Current(
                i64::from(size - 16) + i64::from(size & 1),
            ))
            .ok()?;
        } else if &chunk[..4] == b"data" {
            return byte_rate
                .filter(|rate| *rate > 0)
                .map(|rate| u64::from(size) * 1000 / u64::from(rate));
        } else {
            file.seek(SeekFrom::Current(i64::from(size) + i64::from(size & 1)))
                .ok()?;
        }
    }
    None
}

async fn run(program: &str, args: &[&str], seconds: u64) -> Result<String, String> {
    let output = tokio::time::timeout(
        Duration::from_secs(seconds),
        Command::new(program).args(args).kill_on_drop(true).output(),
    )
    .await
    .map_err(|_| format!("{program} timed out"))?
    .map_err(|error| format!("{program}: {error}"))?;
    if !output.status.success() {
        return Err(format!(
            "{program}: {}{}",
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr)
        ));
    }
    Ok(String::from_utf8_lossy(&output.stdout).into_owned())
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn bluetooth_identity_survives_profile_node_name_changes() {
        assert_eq!(
            output_id("bluez_output.AA_BB_CC_DD_EE_FF.1"),
            output_id("bluez_output.AA_BB_CC_DD_EE_FF.a2dp-sink")
        );
        assert_eq!(output_id("alsa_output.hdmi").0, "pipewire:alsa_output.hdmi");
    }

    #[test]
    fn reads_pcm_wav_duration_without_loading_audio_samples() {
        let mut bytes = Vec::from(&b"RIFF\0\0\0\0WAVEfmt "[..]);
        bytes.extend(16u32.to_le_bytes());
        bytes.extend(1u16.to_le_bytes());
        bytes.extend(2u16.to_le_bytes());
        bytes.extend(48000u32.to_le_bytes());
        bytes.extend(192000u32.to_le_bytes());
        bytes.extend(4u16.to_le_bytes());
        bytes.extend(16u16.to_le_bytes());
        bytes.extend(b"data");
        bytes.extend(192000u32.to_le_bytes());
        assert_eq!(wav_duration(std::io::Cursor::new(bytes)), Some(1000));
        assert_eq!(
            wav_duration(std::io::Cursor::new(b"not an audio file")),
            None
        );
    }

    #[tokio::test]
    async fn stop_all_rejects_an_older_in_flight_start_before_spawning_a_player() {
        let runtime = AudioRuntime {
            tracks: Arc::new(BTreeMap::from([(
                "test".into(),
                Track {
                    id: "test".into(),
                    label: "Test".into(),
                    file_name: "test.wav".into(),
                    format: "WAV".into(),
                    available: true,
                    duration_ms: None,
                    file: std::env::current_exe().unwrap(),
                },
            )])),
            bindings: Arc::new(BTreeMap::new()),
            inner: Arc::new(Mutex::new(Inner {
                outputs: vec![Output {
                    id: "test-output".into(),
                    label: "Test".into(),
                    kind: "local",
                    aliases: vec![],
                    paired: false,
                    connected: true,
                    ready: true,
                    percent: Some(0),
                    muted: false,
                    backend: Some("test-output".into()),
                    backend_index: None,
                    address: None,
                }],
                errors: vec![],
                refreshed: Some(Instant::now()),
                voices: BTreeMap::new(),
                stop_generation: 0,
            })),
            refresh_lock: Arc::new(tokio::sync::Mutex::new(())),
            slots: Arc::new(Semaphore::new(1)),
            max_active: 1,
        };
        runtime.stop_all();
        let result = runtime
            .play_in_generation("test", "test-output", None, &WorkflowHub::default(), 0)
            .await;
        assert!(matches!(result, Err(error) if error.contains("STOP ALL")));
        assert!(runtime.inner.lock().unwrap().voices.is_empty());
        assert_eq!(runtime.slots.available_permits(), 1);
    }
}
