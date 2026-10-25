//! Named source tracks, discovered physical outputs, and independently stoppable voices.
use crate::{
    aliases::DeviceAliases,
    show_config::{ActionConfig, ShowConfig, SinkConfig},
    workflow::{WorkflowHub, now_ms},
};
use fx_audio::{
    audio::{DeviceSelector, PlaybackOptions, PlaybackRequest},
    bluetooth::{parse_device_info, parse_devices},
    pipewire::{PipeWire, parse_devices as parse_outputs, parse_volume},
};
use serde::Serialize;
use std::{
    collections::{BTreeMap, BTreeSet},
    path::PathBuf,
    process::Stdio,
    sync::{Arc, Mutex},
    time::{Duration, Instant},
};
use tokio::{
    io::AsyncWriteExt,
    process::Command,
    sync::{Semaphore, mpsc, oneshot, watch},
};

const RESIDENT_RATE: u32 = 48_000;
const RESIDENT_CHANNELS: usize = 2;
const RESIDENT_CHUNK_MS: u64 = 10;

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
    #[serde(skip)]
    resident: Option<Arc<ResidentClip>>,
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
    lease: Option<watch::Sender<Instant>>,
}

#[derive(Clone)]
struct ResidentClip {
    samples: Arc<[i16]>,
}

struct ResidentVoice {
    samples: Arc<[i16]>,
    cursor: usize,
    volume: f32,
    loop_range: Option<(usize, usize)>,
    done: oneshot::Sender<Result<String, String>>,
}

enum ResidentCommand {
    Play {
        id: String,
        clip: Arc<ResidentClip>,
        volume: f32,
        loop_range: Option<(usize, usize)>,
        done: oneshot::Sender<Result<String, String>>,
    },
    Stop {
        id: String,
    },
}

#[derive(Clone)]
struct ResidentChannel {
    backend: String,
    commands: mpsc::Sender<ResidentCommand>,
}
struct Inner {
    outputs: Vec<Output>,
    errors: Vec<String>,
    refreshed: Option<Instant>,
    voices: BTreeMap<String, Voice>,
    hold_keys: BTreeMap<String, String>,
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
    resident_sinks: Arc<BTreeSet<String>>,
    resident_channels: Arc<tokio::sync::Mutex<BTreeMap<String, ResidentChannel>>>,
    resident_latency_ms: u16,
}

pub struct Ticket {
    pub id: String,
    done: watch::Receiver<Option<Result<String, String>>>,
}

pub struct HoldOptions {
    pub volume: Option<f32>,
    pub loop_start_ms: u64,
    pub loop_end_ms: Option<u64>,
    pub lease_ms: u64,
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
        let mut resident_assets = BTreeSet::new();
        let mut resident_sinks = BTreeSet::new();
        for flow in show.flows.values() {
            for node in &flow.nodes {
                match &node.action {
                    ActionConfig::AudioTrigger { sink, asset, .. }
                    | ActionConfig::AudioHoldStart { sink, asset, .. } => {
                        resident_assets.insert(asset.clone());
                        resident_sinks.insert(sink.clone());
                    }
                    _ => {}
                }
            }
        }
        let tracks = show
            .assets
            .iter()
            .map(|(id, asset)| -> fx_audio::Result<_> {
                let file = asset.audio_file().to_path_buf();
                let resident = resident_assets
                    .contains(id)
                    .then(|| decode_resident_wav(&file))
                    .transpose()
                    .map_err(|error| {
                        fx_audio::FxError::ShowConfig(format!(
                            "resident audio asset `{id}` is incompatible: {error}"
                        ))
                    })?
                    .map(Arc::new);
                Ok((
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
                        resident,
                    },
                ))
            })
            .collect::<fx_audio::Result<BTreeMap<_, _>>>()?;
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
                hold_keys: BTreeMap::new(),
                stop_generation: 0,
            })),
            refresh_lock: Arc::new(tokio::sync::Mutex::new(())),
            slots,
            max_active: show.playback.max_active,
            resident_sinks: Arc::new(resident_sinks),
            resident_channels: Arc::new(tokio::sync::Mutex::new(BTreeMap::new())),
            resident_latency_ms: show.playback.resident_latency_ms,
        })
    }

    /// Keep all outputs used by `audio.trigger` warm. Discovery also stays
    /// hot, so an interaction does not wait for bluetoothctl/wpctl probes.
    pub fn start_resident_channels(&self) {
        if self.resident_sinks.is_empty() {
            return;
        }
        let runtime = self.clone();
        tokio::spawn(async move {
            loop {
                for sink in runtime.resident_sinks.iter() {
                    match runtime.output(sink).await {
                        Ok(output) if output.ready => {
                            if let Err(error) = runtime.ensure_resident_channel(&output).await {
                                crate::fx_log!(
                                    "resident audio channel `{sink}` unavailable: {error}"
                                );
                            }
                        }
                        Ok(_) => {}
                        Err(error) => {
                            crate::fx_log!("resident audio output `{sink}` unavailable: {error}")
                        }
                    }
                }
                tokio::time::sleep(Duration::from_secs(1)).await;
            }
        });
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
        self.play_in_generation(track, target, volume, log, generation, false)
            .await
    }

    pub async fn play_loop(
        &self,
        track: &str,
        target: &str,
        volume: Option<f32>,
        log: &WorkflowHub,
    ) -> Result<Ticket, String> {
        let generation = self.inner.lock().unwrap().stop_generation;
        self.play_in_generation(track, target, volume, log, generation, true)
            .await
    }

    /// Starts a predecoded clip on an already-open low-latency output stream.
    /// This is the interaction hot path; it deliberately avoids launching a
    /// process or touching the filesystem in response to the trigger.
    pub async fn trigger(
        &self,
        track: &str,
        target: &str,
        volume: Option<f32>,
        log: &WorkflowHub,
    ) -> Result<Ticket, String> {
        let generation = self.inner.lock().unwrap().stop_generation;
        let track = self.tracks.get(track).ok_or("unknown audio track")?;
        let clip = track
            .resident
            .clone()
            .ok_or("audio track was not preloaded for resident playback")?;
        let output = self.output(target).await?;
        if !output.ready {
            return Err(format!("{} is not ready for audio", output.label));
        }
        let channel = self.ensure_resident_channel(&output).await?;
        let permit = self
            .slots
            .clone()
            .try_acquire_owned()
            .map_err(|_| "all audio playback slots are active")?;
        let id = uuid::Uuid::new_v4().to_string();
        let (stop, mut stopping) = watch::channel(false);
        let (done, receiver) = watch::channel(None);
        let (resident_done, mut resident_result) = oneshot::channel();
        {
            let mut inner = self.inner.lock().unwrap();
            if inner.stop_generation != generation {
                return Err("audio start cancelled by STOP ALL".into());
            }
            channel
                .commands
                .try_send(ResidentCommand::Play {
                    id: id.clone(),
                    clip,
                    volume: volume.unwrap_or(1.0),
                    loop_range: None,
                    done: resident_done,
                })
                .map_err(|error| format!("resident audio channel unavailable: {error}"))?;
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
                    lease: None,
                    status: Playback {
                        id: id.clone(),
                        track: track.id.clone(),
                        output: output.id.clone(),
                        phase: "playing",
                        started_at_ms: now_ms(),
                        detail: format!("{} → {} (resident)", track.label, output.label),
                    },
                },
            );
        }
        log.note_kind(
            "audio",
            format!("Audio {id}: {} → {} (resident)", track.label, output.label),
        );
        let runtime = self.clone();
        let playback_id = id.clone();
        let commands = channel.commands.clone();
        let log = log.clone();
        tokio::spawn(async move {
            let _permit = permit;
            let result = tokio::select! {
                result = &mut resident_result => result
                    .unwrap_or_else(|_| Err("resident audio channel stopped".into())),
                _ = stopping.changed() => {
                    let _ = commands.send(ResidentCommand::Stop { id: playback_id.clone() }).await;
                    resident_result.await
                        .unwrap_or_else(|_| Err("resident audio channel stopped".into()))
                }
            };
            let phase = match &result {
                Ok(_) => "finished",
                Err(error) if error == "audio stopped by operator" => "stopped",
                Err(_) => "failed",
            };
            let detail = result.clone().unwrap_or_else(|error| error);
            if let Some(voice) = runtime.inner.lock().unwrap().voices.get_mut(&playback_id) {
                voice.status.phase = phase;
                voice.status.detail = detail.clone();
            }
            log.note_kind("audio", format!("Audio {playback_id}: {phase} — {detail}"));
            let _ = done.send(Some(result));
        });
        Ok(Ticket { id, done: receiver })
    }

    /// Start or renew a named press-and-hold sound. Starting is idempotent by
    /// key, so switch heartbeats only move the lease deadline; they never add
    /// overlapping copies. The resident mixer plays the attack once and then
    /// wraps the requested loop region until release or lease expiry.
    pub async fn start_hold(
        &self,
        key: &str,
        track: &str,
        target: &str,
        options: HoldOptions,
        log: &WorkflowHub,
    ) -> Result<String, String> {
        let deadline = Instant::now() + Duration::from_millis(options.lease_ms);
        {
            let inner = self.inner.lock().unwrap();
            if let Some(id) = inner.hold_keys.get(key)
                && let Some(voice) = inner.voices.get(id)
                && voice.status.phase == "playing"
                && let Some(lease) = &voice.lease
            {
                lease
                    .send(deadline)
                    .map_err(|_| "audio hold is no longer active")?;
                return Ok(format!("audio hold `{key}` renewed"));
            }
        }

        let generation = self.inner.lock().unwrap().stop_generation;
        let track = self.tracks.get(track).ok_or("unknown audio track")?;
        let clip = track
            .resident
            .clone()
            .ok_or("audio track was not preloaded for resident playback")?;
        let start = resident_sample_offset(options.loop_start_ms);
        let end = options
            .loop_end_ms
            .map_or(clip.samples.len(), resident_sample_offset);
        if start >= end || end > clip.samples.len() {
            return Err(format!(
                "audio hold loop must fit inside the {:.0}ms resident clip",
                clip.samples.len() as f64 / RESIDENT_CHANNELS as f64 / RESIDENT_RATE as f64
                    * 1000.0
            ));
        }
        let output = self.output(target).await?;
        if !output.ready {
            return Err(format!("{} is not ready for audio", output.label));
        }
        let channel = self.ensure_resident_channel(&output).await?;
        let permit = self
            .slots
            .clone()
            .try_acquire_owned()
            .map_err(|_| "all audio playback slots are active")?;
        let id = uuid::Uuid::new_v4().to_string();
        let (stop, mut stopping) = watch::channel(false);
        let (lease, mut lease_updates) = watch::channel(deadline);
        let (resident_done, mut resident_result) = oneshot::channel();
        {
            let mut inner = self.inner.lock().unwrap();
            if inner.stop_generation != generation {
                return Err("audio start cancelled by STOP ALL".into());
            }
            // Another heartbeat can finish the async output lookup first.
            if let Some(existing) = inner.hold_keys.get(key)
                && let Some(voice) = inner.voices.get(existing)
                && voice.status.phase == "playing"
                && let Some(lease) = &voice.lease
            {
                lease
                    .send(deadline)
                    .map_err(|_| "audio hold is no longer active")?;
                return Ok(format!("audio hold `{key}` renewed"));
            }
            channel
                .commands
                .try_send(ResidentCommand::Play {
                    id: id.clone(),
                    clip,
                    volume: options.volume.unwrap_or(1.0),
                    loop_range: Some((start, end)),
                    done: resident_done,
                })
                .map_err(|error| format!("resident audio channel unavailable: {error}"))?;
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
            inner.hold_keys.insert(key.to_string(), id.clone());
            inner.voices.insert(
                id.clone(),
                Voice {
                    stop,
                    lease: Some(lease),
                    status: Playback {
                        id: id.clone(),
                        track: track.id.clone(),
                        output: output.id.clone(),
                        phase: "playing",
                        started_at_ms: now_ms(),
                        detail: format!("{} → {} (held)", track.label, output.label),
                    },
                },
            );
        }
        log.note_kind(
            "audio",
            format!(
                "Audio {id}: {} → {} (held as `{key}`)",
                track.label, output.label
            ),
        );
        let runtime = self.clone();
        let playback_id = id.clone();
        let hold_key = key.to_string();
        let commands = channel.commands.clone();
        let log = log.clone();
        tokio::spawn(async move {
            let _permit = permit;
            let result = loop {
                let deadline = *lease_updates.borrow_and_update();
                let expiry = tokio::time::sleep_until(deadline.into());
                tokio::pin!(expiry);
                tokio::select! {
                    result = &mut resident_result => break result
                        .unwrap_or_else(|_| Err("resident audio channel stopped".into())),
                    _ = stopping.changed() => {
                        let _ = commands.send(ResidentCommand::Stop { id: playback_id.clone() }).await;
                        break resident_result.await
                            .unwrap_or_else(|_| Err("resident audio channel stopped".into()));
                    }
                    changed = lease_updates.changed() => {
                        if changed.is_err() {
                            let _ = commands.send(ResidentCommand::Stop { id: playback_id.clone() }).await;
                            break Err("audio hold lease closed".into());
                        }
                    }
                    _ = &mut expiry => {
                        let _ = commands.send(ResidentCommand::Stop { id: playback_id.clone() }).await;
                        let _ = resident_result.await;
                        break Err("audio hold lease expired".into());
                    }
                }
            };
            let phase = match &result {
                Ok(_) => "finished",
                Err(error)
                    if error == "audio stopped by operator"
                        || error == "audio hold lease expired" =>
                {
                    "stopped"
                }
                Err(_) => "failed",
            };
            let detail = result.clone().unwrap_or_else(|error| error);
            let mut inner = runtime.inner.lock().unwrap();
            if let Some(voice) = inner.voices.get_mut(&playback_id) {
                voice.status.phase = phase;
                voice.status.detail = detail.clone();
            }
            if inner.hold_keys.get(&hold_key) == Some(&playback_id) {
                inner.hold_keys.remove(&hold_key);
            }
            drop(inner);
            log.note_kind("audio", format!("Audio {playback_id}: {phase} — {detail}"));
        });
        Ok(format!("audio hold `{key}` started"))
    }

    pub fn stop_hold(&self, key: &str) -> Result<String, String> {
        let mut inner = self.inner.lock().unwrap();
        let Some(id) = inner.hold_keys.remove(key) else {
            return Ok(format!("audio hold `{key}` already stopped"));
        };
        let voice = inner
            .voices
            .get(&id)
            .ok_or_else(|| format!("audio hold `{key}` lost its playback"))?;
        if voice.status.phase == "playing" {
            voice
                .stop
                .send(true)
                .map_err(|_| "audio player unavailable")?;
        }
        Ok(format!("audio hold `{key}` stopped"))
    }

    async fn ensure_resident_channel(&self, output: &Output) -> Result<ResidentChannel, String> {
        let backend = output.backend.clone().ok_or("output has no audio sink")?;
        let mut channels = self.resident_channels.lock().await;
        if let Some(channel) = channels.get(&output.id)
            && channel.backend == backend
            && !channel.commands.is_closed()
        {
            return Ok(channel.clone());
        }
        let channel =
            spawn_resident_channel(output.id.clone(), backend, self.resident_latency_ms).await?;
        channels.insert(output.id.clone(), channel.clone());
        Ok(channel)
    }

    async fn play_in_generation(
        &self,
        track: &str,
        target: &str,
        volume: Option<f32>,
        log: &WorkflowHub,
        generation: u64,
        looped: bool,
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
            let child = spawn_playback(&request)?;
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
                    lease: None,
                    status: Playback {
                        id: id.clone(),
                        track: track.id.clone(),
                        output: output.id,
                        phase: "playing",
                        started_at_ms: now_ms(),
                        detail: format!(
                            "{} → {}{}",
                            track.label,
                            output.label,
                            if looped { " (looping)" } else { "" }
                        ),
                    },
                },
            );
            child
        };
        log.note_kind(
            "audio",
            format!(
                "Audio {}: {} → {}{}",
                id,
                track.label,
                output.label,
                if looped { " (looping)" } else { "" }
            ),
        );
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
            tokio::pin!(lost_output);
            let (phase, result) = loop {
                let outcome = tokio::select! {
                    biased;
                    _ = stopping.changed() => {
                        let result = child.kill().await;
                        break if let Err(error) = result { ("failed", Err(format!("could not stop audio: {error}"))) }
                        else { ("stopped", Err("audio stopped by operator".to_string())) };
                    }
                    status = child.wait() => status,
                    _ = &mut lost_output => {
                        let _ = child.kill().await;
                        break ("failed", Err("selected audio output disconnected or changed".to_string()));
                    }
                };
                match outcome {
                    Ok(status) if status.success() && looped => match spawn_playback(&request) {
                        Ok(next) => child = next,
                        Err(error) => break ("failed", Err(error)),
                    },
                    Ok(status) if status.success() => {
                        break ("finished", Ok("audio playback finished".to_string()));
                    }
                    Ok(status) => break ("failed", Err(format!("audio player exited: {status}"))),
                    Err(error) => break ("failed", Err(error.to_string())),
                }
            };
            let detail = result.clone().unwrap_or_else(|error| error);
            if let Some(voice) = runtime.inner.lock().unwrap().voices.get_mut(&playback_id) {
                voice.status.phase = phase;
                voice.status.detail = detail.clone();
            }
            log.note_kind("audio", format!("Audio {playback_id}: {phase} — {detail}"));
            let _ = done.send(Some(result));
        });
        Ok(Ticket { id, done: receiver })
    }

    pub fn stop(&self, id: &str) -> Result<(), String> {
        let mut inner = self.inner.lock().unwrap();
        inner.hold_keys.retain(|_, playback| playback != id);
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
        inner.hold_keys.clear();
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

fn spawn_playback(request: &PlaybackRequest) -> Result<tokio::process::Child, String> {
    let command = PipeWire::default()
        .playback_command(request)
        .map_err(|error| error.to_string())?;
    Command::from(command)
        .stdin(Stdio::null())
        .stdout(Stdio::null())
        .stderr(Stdio::inherit())
        .kill_on_drop(true)
        .spawn()
        .map_err(|error| error.to_string())
}

async fn spawn_resident_channel(
    output_id: String,
    backend: String,
    latency_ms: u16,
) -> Result<ResidentChannel, String> {
    let mut child = Command::new("pw-play")
        .args([
            "--target",
            &backend,
            "--properties",
            r#"{"node.dont-fallback":true,"node.dont-reconnect":true,"node.linger":false,"media.role":"Music"}"#,
            "--latency",
            &format!("{latency_ms}ms"),
            "--rate",
            &RESIDENT_RATE.to_string(),
            "--channels",
            &RESIDENT_CHANNELS.to_string(),
            "--channel-map",
            "stereo",
            "--format",
            "s16",
            "--raw",
            "-",
        ])
        .stdin(Stdio::piped())
        .stdout(Stdio::null())
        .stderr(Stdio::inherit())
        .kill_on_drop(true)
        .spawn()
        .map_err(|error| format!("could not start resident pw-play: {error}"))?;
    let stdin = child
        .stdin
        .take()
        .ok_or("resident pw-play did not expose stdin")?;
    let (commands, receiver) = mpsc::channel(32);
    let channel = ResidentChannel { backend, commands };
    tokio::spawn(run_resident_channel(output_id, child, stdin, receiver));
    Ok(channel)
}

async fn run_resident_channel(
    output_id: String,
    mut child: tokio::process::Child,
    mut stdin: tokio::process::ChildStdin,
    mut commands: mpsc::Receiver<ResidentCommand>,
) {
    let samples_per_chunk =
        (u64::from(RESIDENT_RATE) * RESIDENT_CHUNK_MS / 1000) as usize * RESIDENT_CHANNELS;
    let mut voices: BTreeMap<String, ResidentVoice> = BTreeMap::new();
    let mut interval = tokio::time::interval(Duration::from_millis(RESIDENT_CHUNK_MS));
    interval.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Skip);
    let failure = loop {
        tokio::select! {
            biased;
            command = commands.recv() => match command {
                Some(ResidentCommand::Play { id, clip, volume, loop_range, done }) => {
                    voices.insert(id, ResidentVoice {
                        samples: Arc::clone(&clip.samples),
                        cursor: 0,
                        volume,
                        loop_range,
                        done,
                    });
                }
                Some(ResidentCommand::Stop { id }) => {
                    if let Some(voice) = voices.remove(&id) {
                        let _ = voice.done.send(Err("audio stopped by operator".into()));
                    }
                }
                None => break "resident audio runtime stopped".to_string(),
            },
            _ = interval.tick() => {
                let (bytes, finished) = mix_resident_chunk(&mut voices, samples_per_chunk);
                if let Err(error) = stdin.write_all(&bytes).await {
                    break format!("resident audio output `{output_id}` failed: {error}");
                }
                for voice in finished {
                    let _ = voice.done.send(Ok("resident audio playback finished".into()));
                }
            }
        }
    };
    for (_, voice) in voices {
        let _ = voice.done.send(Err(failure.clone()));
    }
    drop(stdin);
    let _ = child.kill().await;
    let _ = child.wait().await;
    crate::fx_log!("{failure}");
}

fn mix_resident_chunk(
    voices: &mut BTreeMap<String, ResidentVoice>,
    sample_count: usize,
) -> (Vec<u8>, Vec<ResidentVoice>) {
    let mut mixed = vec![0_i32; sample_count];
    let mut finished_ids = Vec::new();
    for (id, voice) in voices.iter_mut() {
        if let Some((loop_start, loop_end)) = voice.loop_range {
            for output in &mut mixed {
                *output += (f32::from(voice.samples[voice.cursor]) * voice.volume).round() as i32;
                voice.cursor += 1;
                if voice.cursor == loop_end {
                    voice.cursor = loop_start;
                }
            }
        } else {
            let remaining = voice.samples.len().saturating_sub(voice.cursor);
            let count = remaining.min(sample_count);
            for (output, sample) in mixed[..count]
                .iter_mut()
                .zip(&voice.samples[voice.cursor..voice.cursor + count])
            {
                *output += (f32::from(*sample) * voice.volume).round() as i32;
            }
            voice.cursor += count;
            if voice.cursor == voice.samples.len() {
                finished_ids.push(id.clone());
            }
        }
    }
    let mut bytes = Vec::with_capacity(sample_count * 2);
    for sample in mixed {
        bytes.extend_from_slice(
            &(sample.clamp(i16::MIN.into(), i16::MAX.into()) as i16).to_le_bytes(),
        );
    }
    let finished = finished_ids
        .into_iter()
        .filter_map(|id| voices.remove(&id))
        .collect();
    (bytes, finished)
}

fn resident_sample_offset(milliseconds: u64) -> usize {
    milliseconds
        .saturating_mul(u64::from(RESIDENT_RATE))
        .saturating_mul(RESIDENT_CHANNELS as u64)
        .saturating_div(1000)
        .min(usize::MAX as u64) as usize
}

fn decode_resident_wav(path: &std::path::Path) -> Result<ResidentClip, String> {
    let bytes = std::fs::read(path).map_err(|error| error.to_string())?;
    if bytes.len() < 12 || &bytes[..4] != b"RIFF" || &bytes[8..12] != b"WAVE" {
        return Err("expected a RIFF/WAVE file".into());
    }
    let mut offset = 12;
    let mut format = None;
    let mut pcm = None;
    while offset + 8 <= bytes.len() {
        let name = &bytes[offset..offset + 4];
        let size = u32::from_le_bytes(bytes[offset + 4..offset + 8].try_into().unwrap()) as usize;
        offset += 8;
        if offset + size > bytes.len() {
            return Err("WAV chunk exceeds file length".into());
        }
        if name == b"fmt " && size >= 16 {
            format = Some((
                u16::from_le_bytes(bytes[offset..offset + 2].try_into().unwrap()),
                u16::from_le_bytes(bytes[offset + 2..offset + 4].try_into().unwrap()),
                u32::from_le_bytes(bytes[offset + 4..offset + 8].try_into().unwrap()),
                u16::from_le_bytes(bytes[offset + 14..offset + 16].try_into().unwrap()),
            ));
        } else if name == b"data" {
            pcm = Some(&bytes[offset..offset + size]);
        }
        offset += size + (size & 1);
    }
    let (codec, channels, rate, bits) = format.ok_or("WAV has no fmt chunk")?;
    if codec != 1 || bits != 16 || !(channels == 1 || channels == 2) || rate == 0 {
        return Err(format!(
            "expected 16-bit PCM mono/stereo; found codec={codec}, channels={channels}, rate={rate}, bits={bits}"
        ));
    }
    let pcm = pcm.ok_or("WAV has no data chunk")?;
    if pcm.len() % (usize::from(channels) * 2) != 0 {
        return Err("WAV data is not aligned to complete frames".into());
    }
    let input: Vec<i16> = pcm
        .chunks_exact(2)
        .map(|sample| i16::from_le_bytes([sample[0], sample[1]]))
        .collect();
    let input_frames = input.len() / usize::from(channels);
    let output_frames =
        ((input_frames as u64 * u64::from(RESIDENT_RATE)) / u64::from(rate)) as usize;
    let mut output = Vec::with_capacity(output_frames * RESIDENT_CHANNELS);
    for frame in 0..output_frames {
        let source = (frame as u64 * u64::from(rate) / u64::from(RESIDENT_RATE)) as usize;
        let source = source.min(input_frames.saturating_sub(1));
        let left = input[source * usize::from(channels)];
        let right = if channels == 2 {
            input[source * 2 + 1]
        } else {
            left
        };
        output.extend([left, right]);
    }
    Ok(ResidentClip {
        samples: output.into(),
    })
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
                    resident: None,
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
                hold_keys: BTreeMap::new(),
                stop_generation: 0,
            })),
            refresh_lock: Arc::new(tokio::sync::Mutex::new(())),
            slots: Arc::new(Semaphore::new(1)),
            max_active: 1,
            resident_sinks: Arc::new(BTreeSet::new()),
            resident_channels: Arc::new(tokio::sync::Mutex::new(BTreeMap::new())),
            resident_latency_ms: 20,
        };
        runtime.stop_all();
        let result = runtime
            .play_in_generation(
                "test",
                "test-output",
                None,
                &WorkflowHub::default(),
                0,
                false,
            )
            .await;
        assert!(matches!(result, Err(error) if error.contains("STOP ALL")));
        assert!(runtime.inner.lock().unwrap().voices.is_empty());
        assert_eq!(runtime.slots.available_permits(), 1);
    }
}
