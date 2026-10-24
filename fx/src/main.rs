use std::{
    collections::BTreeMap, path::PathBuf, process::ExitCode, str::FromStr, sync::Arc,
    thread::JoinHandle, time::Duration,
};

macro_rules! fx_log {
    ($($argument:tt)*) => {
        crate::logging::line(format_args!($($argument)*))
    };
}
pub(crate) use fx_log;

mod aliases;
mod audio_runtime;
mod cue_link;
mod display_registry;
mod kiosk;
mod logging;
mod mqtt_input;
mod screen;
mod serial_input;
mod show_config;
mod state;
mod web;
mod workflow;

use aliases::DeviceAliases;
use clap::{Args, CommandFactory, Parser, Subcommand, ValueEnum, ValueHint};
use clap_complete::CompleteEnv;
use fx_audio::{
    AudioSystem, DeviceSelector, PipeWire, PlaybackOptions, PlaybackRequest, Result,
    bluetooth::{BluezCli, DeviceFilter},
};
use screen::ScreenHub;
use tokio::sync::Semaphore;

#[derive(Debug, Parser)]
#[command(version, about)]
struct Cli {
    #[command(subcommand)]
    command: Command,
}

#[derive(Debug, Subcommand)]
enum Command {
    /// List and select PipeWire audio devices.
    Outputs {
        #[command(subcommand)]
        command: OutputCommand,
    },
    /// Read or change the system output volume.
    Volume {
        #[command(subcommand)]
        command: VolumeCommand,
    },
    /// Discover, pair, and connect Bluetooth devices.
    Bluetooth {
        #[command(subcommand)]
        command: BluetoothCommand,
    },
    /// Play one audio file on one device and wait for it to finish.
    Play(PlayArgs),
    /// CLI-level composition: play files sequentially on one device.
    Sequence(SequenceArgs),
    /// Generate shell completion definitions.
    Completions { shell: CompletionShell },
    /// Inspect serial inputs or compose one serial event with one playback.
    Serial {
        #[command(subcommand)]
        command: SerialCommand,
    },
    /// Validate and select show configurations.
    Show {
        #[command(subcommand)]
        command: ShowCommand,
    },
    /// Start, stop, or inspect the Chromium kiosk independently.
    Kiosk {
        #[command(subcommand)]
        command: KioskCommand,
    },
    /// Run a show configuration, or the enabled show when CONFIG is omitted.
    Run(RunArgs),
}

#[derive(Debug, Args)]
struct RunArgs {
    /// Show file (legacy positional form; `--config` is preferred).
    #[arg(value_name = "CONFIG", value_hint = ValueHint::FilePath)]
    config: Option<PathBuf>,
    /// Show file to run without changing the enabled show.
    #[arg(long = "config", value_name = "CONFIG", value_hint = ValueHint::FilePath, conflicts_with = "config")]
    config_file: Option<PathBuf>,
    /// Launch the configured kiosk even when kiosk.enabled is false.
    #[arg(long, conflicts_with = "no_kiosk")]
    kiosk: bool,
    /// Run audio, serial, and the eye server without launching Chromium.
    #[arg(long)]
    no_kiosk: bool,
    /// Append fx runtime messages here while retaining terminal output.
    #[arg(long, default_value = "/tmp/fx-run.log", value_hint = ValueHint::FilePath)]
    log_file: PathBuf,
}

impl RunArgs {
    fn into_options(self) -> (Option<PathBuf>, Option<bool>, PathBuf) {
        let kiosk = if self.kiosk {
            Some(true)
        } else if self.no_kiosk {
            Some(false)
        } else {
            None
        };
        (self.config_file.or(self.config), kiosk, self.log_file)
    }
}

#[derive(Debug, Clone, Args)]
struct KioskShowArgs {
    /// Show file; omit to use the currently enabled show.
    #[arg(long, value_name = "CONFIG", value_hint = ValueHint::FilePath)]
    config: Option<PathBuf>,
}

#[derive(Debug, Subcommand)]
enum KioskCommand {
    Start(KioskShowArgs),
    Stop(KioskShowArgs),
    Restart(KioskShowArgs),
    Status(KioskShowArgs),
}

#[derive(Debug, Subcommand)]
enum VolumeCommand {
    /// Print the current volume.
    Get {
        #[arg(long)]
        device: Option<String>,
    },
    /// Set an absolute volume from 0 to 100 percent.
    Set {
        percent: u8,
        #[arg(long)]
        device: Option<String>,
    },
    /// Increase volume by a percentage (default: 5).
    Up {
        #[arg(default_value_t = 5)]
        percent: u8,
        #[arg(long)]
        device: Option<String>,
    },
    /// Decrease volume by a percentage (default: 5).
    Down {
        #[arg(default_value_t = 5)]
        percent: u8,
        #[arg(long)]
        device: Option<String>,
    },
    Mute {
        #[arg(long)]
        device: Option<String>,
    },
    Unmute {
        #[arg(long)]
        device: Option<String>,
    },
    Toggle {
        #[arg(long)]
        device: Option<String>,
    },
}

#[derive(Debug, Subcommand)]
enum ShowCommand {
    /// Validate a configuration and all referenced audio files.
    Check {
        #[arg(value_hint = ValueHint::FilePath)]
        config: PathBuf,
    },
    /// Validate a configuration and select it as the default for `fx run`.
    Enable {
        #[arg(value_hint = ValueHint::FilePath)]
        config: PathBuf,
    },
    /// Print the currently enabled show.
    Current,
}

#[derive(Debug, Subcommand)]
enum OutputCommand {
    List,
    Status,
    SetDefault {
        backend_index: u32,
    },
    /// Assign a short name to a stable audio device ID.
    Alias {
        name: String,
        device_id: String,
    },
    /// Remove a device alias.
    Unalias {
        name: String,
    },
    /// List configured device aliases, including devices that are offline.
    Aliases,
}

#[derive(Debug, Clone, Copy, ValueEnum)]
enum FilterArg {
    All,
    Paired,
    Bonded,
    Trusted,
    Connected,
}

#[derive(Debug, Clone, Copy, ValueEnum)]
enum CompletionShell {
    Bash,
}

impl From<FilterArg> for DeviceFilter {
    fn from(value: FilterArg) -> Self {
        match value {
            FilterArg::All => Self::All,
            FilterArg::Paired => Self::Paired,
            FilterArg::Bonded => Self::Bonded,
            FilterArg::Trusted => Self::Trusted,
            FilterArg::Connected => Self::Connected,
        }
    }
}

#[derive(Debug, Subcommand)]
enum BluetoothCommand {
    /// List devices known to BlueZ and show their current connection state.
    Devices {
        #[arg(long, value_enum, default_value_t = FilterArg::All)]
        filter: FilterArg,
    },
    Scan {
        #[arg(long, default_value_t = 10)]
        seconds: u64,
    },
    Info {
        address: String,
    },
    Pair {
        address: String,
    },
    Trust {
        address: String,
    },
    Connect {
        address: String,
    },
    Disconnect {
        address: String,
    },
    Remove {
        address: String,
    },
}

#[derive(Debug, Subcommand)]
enum SerialCommand {
    /// List stable serial device paths.
    List,
    /// Print newline-delimited serial messages until interrupted.
    Monitor(SerialConnectionArgs),
    /// Wait for one matching JSON event, play one file, then exit.
    PlayOnce {
        event: String,
        #[arg(value_hint = ValueHint::FilePath)]
        file: PathBuf,
        /// Device alias or stable PipeWire ID; omit for the default.
        #[arg(long)]
        device: Option<String>,
        #[command(flatten)]
        connection: SerialConnectionArgs,
    },
    /// Continuously map unique JSON events to concurrently mixed audio files.
    Mux {
        /// Repeatable EVENT=FILE mapping; multiple files may use the same event.
        #[arg(long = "map", required = true, value_name = "EVENT=FILE")]
        mappings: Vec<EventMapping>,
        /// Device alias or stable PipeWire ID; omit for the default.
        #[arg(long)]
        device: Option<String>,
        /// Per-stream volume from 0.0 to 1.0.
        #[arg(long)]
        volume: Option<f32>,
        /// Maximum simultaneous playback streams.
        #[arg(long, default_value_t = 16)]
        max_active: usize,
        /// Stop after starting this many matched events; useful for testing.
        #[arg(long)]
        max_events: Option<usize>,
        /// Number of recent (event, sequence) pairs remembered for deduplication.
        #[arg(long, default_value_t = 4096)]
        dedupe_capacity: usize,
        #[command(flatten)]
        connection: SerialConnectionArgs,
    },
}

#[derive(Debug, Clone)]
struct EventMapping {
    event: String,
    file: PathBuf,
}

#[derive(Clone)]
struct RuntimeNode {
    id: String,
    at_ms: u64,
    after: Vec<String>,
    transition: Option<state::TransitionRef>,
    action: RuntimeAction,
}

#[derive(Clone)]
enum RuntimeAction {
    Audio {
        track: String,
        sink: String,
        volume: Option<f32>,
    },
    Screen {
        screen_id: String,
        command: screen::EyeCommand,
        final_state: screen::EyeSnapshot,
        expires_after_ms: u64,
    },
    Cue {
        sink: String,
        link: String,
        sender: cue_link::CueLinkSender,
        target: String,
        cue: String,
        schedule_at_board: bool,
        expires_after_ms: u64,
        wait_for: Option<String>,
        timeout_ms: u64,
    },
}

#[derive(Clone)]
struct RuntimeControl {
    role: show_config::FlowRole,
    press: Vec<RuntimeNode>,
    release: Vec<RuntimeNode>,
}

#[derive(Clone)]
struct DcProfileTarget {
    sink: String,
    link: String,
    sender: cue_link::CueLinkSender,
    target: String,
    schedule_at_board: bool,
}

const MIN_TUNABLE_STEPPER_RPM: u16 = 10;
const MAX_TUNABLE_STEPPER_RPM: u16 = 120;

fn pwm_percent_to_duty(percent: u8) -> u8 {
    ((u16::from(percent) * 255 + 50) / 100) as u8
}

fn dc_profile_nodes(
    profile: &web::DcProfileInput,
    target: &DcProfileTarget,
    screen_hub: &ScreenHub,
) -> std::result::Result<Vec<RuntimeNode>, String> {
    if !profile.motor_enabled
        && profile.audio.is_none()
        && profile.eye.is_none()
        && profile.stepper.is_none()
    {
        return Err("select at least one playback component".into());
    }
    if profile.motor_enabled
        && (profile.peak_pwm_percent == 0
            || profile.peak_pwm_percent > 100
            || profile.minimum_pwm_percent > profile.peak_pwm_percent
            || !(50..=9999).contains(&profile.ramp_ms)
            || profile.hold_ms > 9999
            || !(50..=9999).contains(&profile.fade_ms))
    {
        return Err("invalid DC profile: PWM must be 1–100%, minimum must not exceed peak, and ramp/fade must be 50–9999 ms".into());
    }
    let duration_ms =
        u64::from(profile.ramp_ms) + u64::from(profile.hold_ms) + u64::from(profile.fade_ms);
    if profile.motor_enabled && duration_ms > 20_000 {
        return Err("DC profile duration must not exceed 20 seconds".into());
    }
    let (direction, direction_name) = match profile.direction {
        web::DcDirection::Forward => ('f', "forward"),
        web::DcDirection::Reverse => ('r', "reverse"),
    };
    let cue = format!(
        "dc:c:{direction}:{}:{}:{}:{}:{}",
        pwm_percent_to_duty(profile.peak_pwm_percent),
        pwm_percent_to_duty(profile.minimum_pwm_percent),
        profile.ramp_ms,
        profile.hold_ms,
        profile.fade_ms,
    );
    if profile.motor_enabled && cue.len() > 31 {
        return Err("DC profile does not fit the Cue packet".into());
    }
    // The common Play timeline does not shift when audio is unchecked. Keep
    // accepting the old audio-nested offset for already-open dashboard clients.
    let motor_delay_ms = profile.motor_delay_ms.unwrap_or_else(|| {
        profile
            .audio
            .as_ref()
            .map_or(0, |audio| audio.motor_delay_ms)
    });
    if profile.motor_enabled && motor_delay_ms > 10_000 {
        return Err("motor audio offset must not exceed 10 seconds".into());
    }
    let mut nodes = Vec::with_capacity(if profile.audio.is_some() { 2 } else { 1 });
    if let Some(audio) = &profile.audio {
        if audio.track.is_empty()
            || audio.track.len() > 128
            || audio.output.is_empty()
            || audio.output.len() > 128
        {
            return Err("audio track and output must be valid bounded identifiers".into());
        }
        nodes.push(RuntimeNode {
            id: format!("tune/{}/audio", target.sink),
            at_ms: 0,
            after: Vec::new(),
            transition: None,
            action: RuntimeAction::Audio {
                track: audio.track.clone(),
                sink: audio.output.clone(),
                volume: None,
            },
        });
    }
    if profile.motor_enabled {
        nodes.push(RuntimeNode {
            id: format!("tune/{}/motor", target.sink),
            at_ms: u64::from(motor_delay_ms),
            after: Vec::new(),
            transition: None,
            action: RuntimeAction::Cue {
                sink: target.sink.clone(),
                link: target.link.clone(),
                sender: target.sender.clone(),
                target: target.target.clone(),
                cue,
                schedule_at_board: target.schedule_at_board,
                expires_after_ms: 1000,
                wait_for: None,
                timeout_ms: duration_ms + 2000,
            },
        });
    }
    if let Some(eye) = &profile.eye {
        if eye.device_id.is_empty() || eye.device_id.len() > 128 || eye.wake_delay_ms > 10_000 {
            return Err(
                "eye device must be a saved display ID and wake delay must be 0–10000 ms".into(),
            );
        }
        // Resolve a saved identity against current connections on every run.
        // A reconnect does not change the user's selected display, and unrelated
        // displays must never receive this private Wake.
        let clients: Vec<_> = screen_hub
            .statuses()
            .into_iter()
            .flat_map(|screen| screen.clients)
            .filter(|client| {
                client.client_id == eye.device_id && screen_hub.client_alive(&client.connection_id)
            })
            .collect();
        if clients.is_empty() {
            return Err("selected eye display is offline; no part of the run was scheduled".into());
        }
        for client in clients {
            let id = format!("client/{}/wake", client.connection_id);
            let mut control = live_display_control(&id, screen_hub)
                .ok_or_else(|| "selected eye disconnected before scheduling".to_string())?;
            let mut node = control.press.remove(0);
            node.id = format!("tune/{}/eye/{}", target.sink, client.connection_id);
            node.at_ms = u64::from(eye.wake_delay_ms);
            nodes.push(node);
        }
    }
    fx_log!(
        "prepared DC {direction_name} profile for `{}`: peak={}%, minimum={}%, ramp={}ms, hold={}ms, fade={}ms, motor delay={}ms",
        target.sink,
        profile.peak_pwm_percent,
        profile.minimum_pwm_percent,
        profile.ramp_ms,
        profile.hold_ms,
        profile.fade_ms,
        motor_delay_ms,
    );
    Ok(nodes)
}

fn playback_nodes(
    profile: &web::DcProfileInput,
    target: &DcProfileTarget,
    screen_hub: &ScreenHub,
    controls: &BTreeMap<String, RuntimeControl>,
) -> std::result::Result<Vec<RuntimeNode>, String> {
    let mut nodes = dc_profile_nodes(profile, target, screen_hub)?;
    if let Some(stepper) = &profile.stepper {
        if stepper.delay_ms > 10_000 {
            return Err("stepper delay must be 0–10000 ms".into());
        }
        let control = controls
            .get(&stepper.control)
            .filter(|control| control.rpm().is_some())
            .ok_or_else(|| "select a configured finite stepper stroke".to_string())?;
        // Reuse the configured stroke, including direction, pulse count, target,
        // transport and expiry. Only peak RPM and start offset are tunable here.
        let mut stroke = control.nodes_for(web::ControlPhase::Press, None, Some(stepper.rpm))?;
        stroke[0].id = format!("tune/{}/stepper", stepper.control);
        stroke[0].at_ms = u64::from(stepper.delay_ms);
        nodes.extend(stroke);
    }
    Ok(nodes)
}

/// Only the existing, leased DC jog protocol may receive a PWM override.
fn dc_jog_pwm(cue: &str) -> Option<u8> {
    let rest = cue.strip_prefix("dc:jog:")?;
    let (direction, duty) = rest.split_once(':')?;
    if !matches!(direction, "fwd" | "rev") || !duty.bytes().all(|b| b.is_ascii_digit()) {
        return None;
    }
    duty.parse::<u8>().ok().filter(|value| *value > 0)
}

/// Return the configured RPM only for an exact finite stepper cue.
fn finite_stepper_rpm(cue: &str) -> Option<u16> {
    let mut parts = cue.split(':');
    if parts.next()? != "step" || !matches!(parts.next()?, "fwd" | "rev") {
        return None;
    }
    let steps = parts.next()?;
    let rpm = parts.next()?;
    if parts.next().is_some()
        || !steps.bytes().all(|byte| byte.is_ascii_digit())
        || !rpm.bytes().all(|byte| byte.is_ascii_digit())
        || steps.parse::<u32>().ok()? == 0
    {
        return None;
    }
    rpm.parse::<u16>().ok().filter(|value| *value > 0)
}

impl RuntimeControl {
    fn pwm(&self) -> Option<u8> {
        let [press] = self.press.as_slice() else {
            return None;
        };
        let [release] = self.release.as_slice() else {
            return None;
        };
        if !matches!(&release.action, RuntimeAction::Cue { cue, .. } if cue == "dc:stop") {
            return None;
        }
        match &press.action {
            RuntimeAction::Cue { cue, .. } => dc_jog_pwm(cue),
            _ => None,
        }
    }

    fn rpm(&self) -> Option<u16> {
        let [press] = self.press.as_slice() else {
            return None;
        };
        if !self.release.is_empty() {
            return None;
        }
        match &press.action {
            RuntimeAction::Cue { cue, .. } => finite_stepper_rpm(cue),
            _ => None,
        }
    }

    fn stroke_steps(&self) -> Option<u32> {
        self.rpm()?;
        match &self.press[0].action {
            RuntimeAction::Cue { cue, .. } => cue.split(':').nth(2)?.parse().ok(),
            _ => None,
        }
    }

    fn nodes_for(
        &self,
        phase: web::ControlPhase,
        pwm: Option<u8>,
        rpm: Option<u16>,
    ) -> std::result::Result<Vec<RuntimeNode>, String> {
        let nodes = match phase {
            web::ControlPhase::Press => &self.press,
            web::ControlPhase::Release => &self.release,
        };
        if nodes.is_empty() {
            return Err("control does not support this phase".into());
        }
        let mut nodes = nodes.clone();
        if pwm.is_some() && rpm.is_some() {
            return Err("a control request cannot override both PWM and RPM".into());
        }
        if let Some(pwm) = pwm {
            if pwm == 0 || self.pwm().is_none() || !matches!(phase, web::ControlPhase::Press) {
                return Err("PWM must be 1–255 and is only supported on DC jog presses".into());
            }
            if let RuntimeAction::Cue { cue, .. } = &mut nodes[0].action {
                let (prefix, _) = cue.rsplit_once(':').expect("validated DC jog cue");
                *cue = format!("{prefix}:{pwm}");
            }
        }
        if let Some(rpm) = rpm {
            if !(MIN_TUNABLE_STEPPER_RPM..=MAX_TUNABLE_STEPPER_RPM).contains(&rpm)
                || self.rpm().is_none()
                || !matches!(phase, web::ControlPhase::Press)
            {
                return Err(format!(
                    "RPM must be {MIN_TUNABLE_STEPPER_RPM}–{MAX_TUNABLE_STEPPER_RPM} and is only supported on finite stepper presses"
                ));
            }
            if let RuntimeAction::Cue { cue, .. } = &mut nodes[0].action {
                let (prefix, _) = cue.rsplit_once(':').expect("validated finite stepper cue");
                *cue = format!("{prefix}:{rpm}");
            }
        }
        Ok(nodes)
    }
}

#[derive(Clone)]
struct RuntimeFlow {
    role: show_config::FlowRole,
    nodes: Vec<RuntimeNode>,
}

struct CompiledFlows {
    by_trigger: BTreeMap<(String, String), Vec<RuntimeFlow>>,
    by_name: BTreeMap<String, RuntimeFlow>,
}

#[derive(Debug, Clone)]
struct RuntimeRoute {
    file: PathBuf,
    output_name: String,
    device: DeviceSelector,
    volume: Option<f32>,
    delay_ms: u64,
}

impl FromStr for EventMapping {
    type Err = String;

    fn from_str(value: &str) -> std::result::Result<Self, Self::Err> {
        let (event, file) = value
            .split_once('=')
            .ok_or_else(|| "expected EVENT=FILE".to_string())?;
        if event.is_empty() || file.is_empty() {
            return Err("both EVENT and FILE must be non-empty".into());
        }
        Ok(Self {
            event: event.to_string(),
            file: PathBuf::from(file),
        })
    }
}

#[derive(Debug, Clone, Args)]
struct SerialConnectionArgs {
    /// Serial device; auto-selected when exactly one /dev/serial/by-id entry exists.
    #[arg(long, value_hint = ValueHint::FilePath)]
    port: Option<PathBuf>,
    #[arg(long, default_value_t = 115_200)]
    baud: u32,
}

#[derive(Debug, Args)]
struct PlayArgs {
    #[arg(value_hint = ValueHint::FilePath)]
    file: PathBuf,
    /// Device alias or stable ID from `fx outputs list`; omit for the default.
    #[arg(long, alias = "target")]
    device: Option<String>,
    #[arg(long)]
    volume: Option<f32>,
    #[arg(long)]
    latency: Option<String>,
}

#[derive(Debug, Args)]
struct SequenceArgs {
    #[arg(required = true, value_hint = ValueHint::FilePath)]
    files: Vec<PathBuf>,
    #[arg(long, alias = "target")]
    device: Option<String>,
    #[arg(long)]
    volume: Option<f32>,
    #[arg(long, default_value_t = 0)]
    gap_ms: u64,
}

#[tokio::main]
async fn main() -> ExitCode {
    CompleteEnv::with_factory(Cli::command).bin("fx").complete();
    match run(Cli::parse()).await {
        Ok(()) => ExitCode::SUCCESS,
        Err(error) => {
            fx_log!("error: {error}");
            ExitCode::FAILURE
        }
    }
}

async fn run(cli: Cli) -> Result<()> {
    match cli.command {
        Command::Outputs { command } => run_outputs(command),
        Command::Volume { command } => run_volume(command),
        Command::Bluetooth { command } => run_bluetooth(command),
        Command::Serial { command } => run_serial(command),
        Command::Show { command } => run_show_command(command),
        Command::Kiosk { command } => run_kiosk(command),
        Command::Run(args) => {
            let (config, kiosk, log_file) = args.into_options();
            run_show(config, kiosk, log_file).await
        }
        Command::Play(args) => PipeWire::default().play(&PlaybackRequest {
            file: args.file,
            device: DeviceAliases::load_default()?.resolve(args.device).into(),
            options: PlaybackOptions {
                volume: args.volume,
                latency: args.latency,
            },
        }),
        Command::Sequence(args) => {
            let audio = PipeWire::default();
            let device = DeviceSelector::from(DeviceAliases::load_default()?.resolve(args.device));
            for (index, file) in args.files.into_iter().enumerate() {
                if index > 0 && args.gap_ms > 0 {
                    std::thread::sleep(Duration::from_millis(args.gap_ms));
                }
                audio.play(&PlaybackRequest {
                    file,
                    device: device.clone(),
                    options: PlaybackOptions {
                        volume: args.volume,
                        latency: None,
                    },
                })?;
            }
            Ok(())
        }
        Command::Completions { shell } => {
            match shell {
                CompletionShell::Bash => println!("source <(COMPLETE=bash fx)"),
            }
            Ok(())
        }
    }
}

fn run_show_command(command: ShowCommand) -> Result<()> {
    match command {
        ShowCommand::Check { config } => {
            let show = show_config::load(&config)?;
            show_config::validate_files(&show)?;
            print_show_summary(&config, &show);
            println!("configuration is valid");
            Ok(())
        }
        ShowCommand::Enable { config } => {
            let (path, show) = show_config::enable(&config)?;
            print_show_summary(&path, &show);
            println!("enabled `{}`; run it with `fx run`", show.name);
            Ok(())
        }
        ShowCommand::Current => {
            let (path, show) = show_config::load_active()?;
            print_show_summary(&path, &show);
            Ok(())
        }
    }
}

fn print_show_summary(path: &std::path::Path, show: &show_config::ShowConfig) {
    println!("show: {}", show.name);
    println!("config: {}", path.display());
    println!("links:");
    for (name, link) in &show.links {
        match link {
            show_config::LinkConfig::SerialCue { port, baud } => println!(
                "  {name}: serial-cue {} at {baud} baud",
                port.as_ref()
                    .map(|port| port.display().to_string())
                    .unwrap_or_else(|| "(auto)".into())
            ),
            show_config::LinkConfig::MqttCue {
                host,
                port,
                node,
                topic_prefix,
                ..
            } => println!("  {name}: mqtt-cue {host}:{port} as {node} under `{topic_prefix}`"),
            show_config::LinkConfig::SimulatedCue => {
                println!("  {name}: simulated-cue")
            }
        }
    }
    println!("sources:");
    for (name, source) in &show.sources {
        println!("  {name} <- {}", source.link());
    }
    println!("assets:");
    for (name, asset) in &show.assets {
        println!("  {name}: {}", asset.audio_file().display());
    }
    println!("sinks:");
    for (name, sink) in &show.sinks {
        match sink {
            show_config::SinkConfig::Audio { device, volume } => {
                let volume = volume
                    .map(|volume| format!(" at {:.0}%", volume * 100.0))
                    .unwrap_or_default();
                println!("  {name}: audio -> {device}{volume}");
            }
            show_config::SinkConfig::Screen { screen_id, .. } => {
                println!("  {name}: screen -> {screen_id}");
            }
            show_config::SinkConfig::Cue {
                link,
                target,
                namespace,
            } => {
                println!("  {name}: cue -> {target} via {link} namespace `{namespace}`");
            }
        }
    }
    if let Some(server) = &show.server {
        println!(
            "server: http://{}/ serving {} for `{}`",
            server.bind,
            server.static_dir.display(),
            server.screen_id
        );
    }
    println!(
        "kiosk: {}{}",
        if show.kiosk.enabled {
            "enabled"
        } else {
            "disabled"
        },
        show.kiosk
            .url
            .as_ref()
            .map(|url| format!(" at {url}"))
            .unwrap_or_default()
    );
    println!("flows:");
    for (name, flow) in &show.flows {
        println!(
            "  {name}: {}:{} -> {} node(s)",
            flow.trigger.source,
            flow.trigger.cue,
            flow.nodes.len()
        );
        for node in &flow.nodes {
            println!("    {} at {}ms", node.id, node.at_ms);
        }
    }
}

fn load_show(config_path: Option<PathBuf>) -> Result<(PathBuf, show_config::ShowConfig)> {
    if let Some(path) = config_path {
        let show = show_config::load(&path)?;
        Ok((path, show))
    } else {
        show_config::load_active()
    }
}

fn kiosk_options(show: &show_config::ShowConfig) -> Result<kiosk::KioskOptions> {
    let url = if let Some(url) = &show.kiosk.url {
        url.clone()
    } else if let Some(server) = &show.server {
        let address = server.socket_addr()?;
        if address.is_ipv6() {
            format!("http://[::1]:{}/", address.port())
        } else {
            format!("http://127.0.0.1:{}/", address.port())
        }
    } else {
        return Err(fx_audio::FxError::ShowConfig(
            "kiosk requires kiosk.url or a [server] section".into(),
        ));
    };
    Ok(kiosk::KioskOptions {
        browser: show.kiosk.browser.clone(),
        url,
        log_file: show.kiosk.log_file.clone(),
        pid_file: show.kiosk.pid_file.clone(),
    })
}

fn run_kiosk(command: KioskCommand) -> Result<()> {
    enum Action {
        Start,
        Stop,
        Restart,
        Status,
    }

    let (action, selection) = match command {
        KioskCommand::Start(selection) => (Action::Start, selection),
        KioskCommand::Stop(selection) => (Action::Stop, selection),
        KioskCommand::Restart(selection) => (Action::Restart, selection),
        KioskCommand::Status(selection) => (Action::Status, selection),
    };
    let (_, show) = load_show(selection.config)?;
    let options = kiosk_options(&show)?;

    match action {
        Action::Start => {
            let process = kiosk::ManagedKiosk::start(&options)?;
            println!(
                "kiosk started as PID {} at {}; logs: {}",
                process.pid(),
                options.url,
                options.log_file.display()
            );
            process.detach();
        }
        Action::Stop => {
            if kiosk::stop(&options)? {
                println!("kiosk stopped");
            } else {
                println!("kiosk is not running");
            }
        }
        Action::Restart => {
            let _ = kiosk::stop(&options)?;
            let process = kiosk::ManagedKiosk::start(&options)?;
            println!(
                "kiosk restarted as PID {} at {}; logs: {}",
                process.pid(),
                options.url,
                options.log_file.display()
            );
            process.detach();
        }
        Action::Status => match kiosk::running_pid(&options.pid_file)? {
            Some(pid) => {
                let owner = kiosk::managed_owner(pid)
                    .map(|owner| format!(" (managed by fx run PID {owner})"))
                    .unwrap_or_default();
                println!(
                    "kiosk is running as PID {pid}{owner} at {}; logs: {}",
                    options.url,
                    options.log_file.display()
                );
            }
            None => println!("kiosk is not running"),
        },
    }
    Ok(())
}

async fn run_show(
    config_path: Option<PathBuf>,
    kiosk_override: Option<bool>,
    log_file: PathBuf,
) -> Result<()> {
    let (path, show) = load_show(config_path)?;
    show_config::validate_files(&show)?;
    logging::init(&log_file)?;

    let (event_sender, mut events) = tokio::sync::mpsc::channel(128);
    let boards = web::BoardRegistry::default();
    let workflows = workflow::WorkflowHub::new(state::StateHub::new(&show.props));
    let audio_slots = Arc::new(Semaphore::new(show.playback.max_active));
    let audio_runtime = audio_runtime::AudioRuntime::new(&show, Arc::clone(&audio_slots))?;
    workflows.set_audio(audio_runtime.clone());
    let mut cue_senders = BTreeMap::new();
    for (link_name, link) in &show.links {
        let incoming_and_outgoing = match link {
            show_config::LinkConfig::SerialCue { port, baud } => Some(
                serial_input::spawn_reconnecting_link(link_name.clone(), port.clone(), *baud, 128),
            ),
            show_config::LinkConfig::MqttCue {
                host,
                port,
                node,
                client_id,
                topic_prefix,
                username,
                password_env,
            } => Some(mqtt_input::spawn_reconnecting_link(
                link_name.clone(),
                mqtt_input::MqttLinkConfig {
                    host: host.clone(),
                    port: *port,
                    node: node.clone(),
                    client_id: client_id.clone(),
                    topic_prefix: topic_prefix.clone(),
                    username: username.clone(),
                    password_env: password_env.clone(),
                },
                128,
            )),
            show_config::LinkConfig::SimulatedCue => {
                cue_senders.insert(
                    link_name.clone(),
                    cue_link::spawn_simulated_link(link_name.clone(), 128),
                );
                None
            }
        };
        if let Some((mut incoming, outgoing)) = incoming_and_outgoing {
            cue_senders.insert(link_name.clone(), outgoing);
            let event_sender = event_sender.clone();
            tokio::spawn(async move {
                while let Some(event) = incoming.recv().await {
                    if event_sender.send(event).await.is_err() {
                        break;
                    }
                }
            });
        }
    }
    for (sink_name, sink) in &show.sinks {
        if let show_config::SinkConfig::Cue { link, target, .. } = sink
            && show.links[link].is_simulated()
        {
            boards.record(link, target, sink_name, "simulated", None);
        }
    }

    let flows = compile_flows(&show, &cue_senders)?;
    let mut controls = compile_controls(&show, &cue_senders, &flows.by_name)?;
    let mut dc_profile_targets = BTreeMap::new();
    for (id, control) in &show.controls {
        if controls.get(id).and_then(RuntimeControl::pwm).is_none() {
            continue;
        }
        let show_config::ControlConfig::Cue { sink, .. } = control else {
            continue;
        };
        let show_config::SinkConfig::Cue { link, target, .. } = &show.sinks[sink] else {
            continue;
        };
        dc_profile_targets
            .entry(sink.clone())
            .or_insert_with(|| DcProfileTarget {
                sink: sink.clone(),
                link: link.clone(),
                sender: cue_senders[link].clone(),
                target: target.clone(),
                schedule_at_board: matches!(
                    show.links[link],
                    show_config::LinkConfig::MqttCue { .. }
                ),
            });
    }
    let (control_sender, mut control_requests) = tokio::sync::mpsc::channel(64);
    let volume_devices: BTreeMap<String, String> = show
        .sinks
        .iter()
        .filter_map(|(id, sink)| match sink {
            show_config::SinkConfig::Audio { device, .. } => Some((id.clone(), device.clone())),
            _ => None,
        })
        .collect();
    let (volume_sender, mut volume_requests) = tokio::sync::mpsc::channel(16);
    let reload_available = std::env::var_os("INVOCATION_ID").is_some();
    let (reload_sender, mut reload_requests) = tokio::sync::mpsc::channel(1);
    let volume_audio = PipeWire::default();
    let mut control_manifest = web::ControlManifest {
        show: show.name.clone(),
        runtime_instance: std::process::id(),
        reload_available,
        controls: show
            .controls
            .iter()
            .map(|(id, control)| match control {
                show_config::ControlConfig::Flow {
                    label,
                    key,
                    panel,
                    section,
                    ..
                } => web::ControlDefinition {
                    id: id.clone(),
                    label: label.clone(),
                    kind: "flow",
                    repeat_ms: None,
                    pwm: None,
                    rpm: None,
                    stroke_steps: None,
                    stroke_profile: None,
                    key: key.clone(),
                    group: None,
                    panel: panel.clone().unwrap_or_else(|| "show".into()),
                    target: None,
                    section: section.map_or("show", show_config::ControlSection::as_str),
                },
                show_config::ControlConfig::Cue {
                    label,
                    sink,
                    repeat_ms,
                    key,
                    panel,
                    section,
                    ..
                } => {
                    let target = match &show.sinks[sink] {
                        show_config::SinkConfig::Cue { target, .. } => Some(target.clone()),
                        _ => None,
                    };
                    web::ControlDefinition {
                        id: id.clone(),
                        label: label.clone(),
                        kind: if repeat_ms.is_some() { "hold" } else { "cue" },
                        repeat_ms: *repeat_ms,
                        pwm: repeat_ms.and_then(|_| controls[id].pwm()),
                        rpm: repeat_ms.is_none().then(|| controls[id].rpm()).flatten(),
                        stroke_steps: controls[id].stroke_steps(),
                        stroke_profile: controls[id].rpm().and_then(|_| match &show.sinks[sink] {
                            show_config::SinkConfig::Cue { link, .. }
                                if matches!(
                                    show.links[link],
                                    show_config::LinkConfig::MqttCue { .. }
                                        | show_config::LinkConfig::SimulatedCue
                                ) =>
                            {
                                Some("quintic")
                            }
                            _ => None,
                        }),
                        key: key.clone(),
                        group: Some(sink.clone()),
                        panel: panel.clone().unwrap_or_else(|| sink.clone()),
                        target,
                        section: section.map_or("bench", show_config::ControlSection::as_str),
                    }
                }
            })
            .collect(),
        audio_outputs: show
            .sinks
            .iter()
            .filter_map(|(id, sink)| match sink {
                show_config::SinkConfig::Audio { .. } => {
                    Some(web::AudioOutputDefinition { id: id.clone() })
                }
                _ => None,
            })
            .collect(),
    };
    for sink in show.sinks.values() {
        let show_config::SinkConfig::Screen { screen_id, .. } = sink else {
            continue;
        };
        for (operation, command, final_state) in [
            (
                "wake",
                screen::EyeCommand::Wake,
                screen::EyeSnapshot {
                    mode: screen::EyeMode::Tipping,
                    gaze: screen::Gaze { x: -0.25, y: -0.65 },
                },
            ),
            (
                "reset",
                screen::EyeCommand::Reset,
                screen::EyeSnapshot {
                    mode: screen::EyeMode::Sleeping,
                    gaze: screen::Gaze { x: 0.0, y: 0.0 },
                },
            ),
        ] {
            let id = format!("display/{screen_id}/{operation}");
            // Keep legacy control IDs callable, but show only the canonical pair.
            // Only collapse a pure, immediate bench action for this exact role;
            // custom sequences and remote-triggered flows remain untouched.
            let aliases: Vec<_> = control_manifest
                .controls
                .iter()
                .filter(|definition| {
                    definition.section == "bench"
                        && definition.panel == *screen_id
                        && controls.get(&definition.id).is_some_and(|control| {
                            is_display_alias(control, screen_id, &command, &final_state)
                        })
                })
                .map(|definition| (definition.id.clone(), definition.key.clone()))
                .collect();
            let key = aliases.iter().find_map(|(_, key)| key.clone());
            control_manifest
                .controls
                .retain(|definition| !aliases.iter().any(|(id, _)| *id == definition.id));
            if controls.contains_key(&id) {
                return Err(fx_audio::FxError::ShowConfig(format!(
                    "reserved display control: {id}"
                )));
            }
            controls.insert(
                id.clone(),
                RuntimeControl {
                    role: show_config::FlowRole::Utility,
                    press: vec![RuntimeNode {
                        id: id.clone(),
                        after: Vec::new(),
                        transition: None,
                        at_ms: 0,
                        action: RuntimeAction::Screen {
                            screen_id: screen_id.clone(),
                            command,
                            final_state,
                            expires_after_ms: 2000,
                        },
                    }],
                    release: Vec::new(),
                },
            );
            control_manifest.controls.push(web::ControlDefinition {
                id,
                label: if operation == "wake" { "Wake" } else { "Reset" }.into(),
                kind: "flow",
                repeat_ms: None,
                pwm: None,
                rpm: None,
                stroke_steps: None,
                stroke_profile: None,
                key,
                group: None,
                panel: screen_id.clone(),
                target: None,
                section: "bench",
            });
        }
    }
    let screen_hub = ScreenHub::new(show.sinks.values().filter_map(|sink| match sink {
        show_config::SinkConfig::Screen {
            screen_id,
            initial_state,
        } => Some((screen_id.clone(), initial_state.clone())),
        _ => None,
    }))
    .with_registry(display_registry::DisplayRegistry::load_default()?);
    let (server_result_tx, mut server_result_rx) = tokio::sync::mpsc::channel(1);
    let server_started = show.server.is_some();
    if let Some(server) = show.server.clone() {
        let bind = server.socket_addr()?;
        let hub = screen_hub.clone();
        let control = web::ControlState {
            manifest: control_manifest,
            sender: control_sender,
            volume_sender,
            reload_sender: reload_available.then_some(reload_sender),
            boards: boards.clone(),
            workflows: workflows.clone(),
        };
        tokio::spawn(async move {
            let result = web::serve(bind, server.static_dir, server.screen_id, hub, control).await;
            let _ = server_result_tx.send(result).await;
        });
    }

    let start_kiosk = kiosk_override.unwrap_or(show.kiosk.enabled);
    let mut kiosk = if start_kiosk {
        if let Some(server) = &show.server {
            wait_for_server(server.socket_addr()?).await?;
        }
        let options = kiosk_options(&show)?;
        let process = kiosk::ManagedKiosk::start(&options)?;
        fx_log!(
            "kiosk started as PID {} at {}; Chromium logs: {}",
            process.pid(),
            options.url,
            options.log_file.display()
        );
        Some(process)
    } else {
        None
    };
    let mut kiosk_check = tokio::time::interval(Duration::from_secs(1));

    let mut deduper = cue_link::EventDeduper::new(show.playback.dedupe_capacity);

    fx_log!(
        "running show `{}` from {}; fx logs: {}",
        show.name,
        path.display(),
        log_file.display()
    );
    loop {
        tokio::select! {
            message = events.recv() => {
                let Some(message) = message else {
                    return Err(fx_audio::FxError::Serial("serial owner stopped".into()));
                };
                if message.event == "system:peer" {
                    if let (Some(link), Some(node), Some(service), Some(transport)) = (
                        message.link.as_deref(),
                        message.source.as_deref(),
                        message.service.as_deref(),
                        message.transport.as_deref(),
                    ) {
                        boards.record(link, node, service, transport, message.rssi);
                    }
                    continue;
                }
                if deduper.is_duplicate(&message) {
                    fx_log!("deduped event `{}` sequence {:?}", message.event, message.sequence);
                    continue;
                }
                workflows.record(&message);
                dispatch_show_event(
                    &message,
                    &flows.by_trigger,
                    &screen_hub,
                    Arc::clone(&audio_slots),
                    &workflows,
                    &audio_runtime,
                );
            }
            request = control_requests.recv() => {
                let Some(request) = request else { continue };
                let result = if let Some(profile) = request.dc_profile.as_ref() {
                    if !matches!(request.phase, web::ControlPhase::Press)
                        || request.pwm.is_some()
                        || request.rpm.is_some()
                    {
                        Err("DC profiles only support a parameterized press".into())
                    } else {
                        dc_profile_targets.get(&request.id).ok_or_else(|| {
                            format!("unknown tunable DC sink `{}`", request.id)
                        }).and_then(|target| {
                            let nodes = playback_nodes(profile, target, &screen_hub, &controls)?;
                            workflows.cancel_pending();
                            audio_runtime.stop_all();
                            schedule_nodes(
                                &nodes,
                                show_config::FlowRole::Utility,
                                &screen_hub,
                                Arc::clone(&audio_slots),
                                &format!("DC profile `{}`", request.id),
                                &workflows,
                            )
                        })
                    }
                } else {
                    let live_control = live_display_control(&request.id, &screen_hub);
                    controls.get(&request.id).or(live_control.as_ref()).ok_or_else(|| {
                        format!("unknown control `{}`", request.id)
                    }).and_then(|control| {
                        let nodes = control.nodes_for(request.phase, request.pwm, request.rpm)?;
                        if matches!(control.role, show_config::FlowRole::Reset | show_config::FlowRole::Stop) {
                            workflows.cancel_pending();
                            audio_runtime.stop_all();
                        } else if control.role == show_config::FlowRole::Utility
                            && nodes.iter().any(|node| matches!(node.action, RuntimeAction::Cue { .. }))
                        {
                            // Direct motion/bench commands deliberately invalidate
                            // the controller's position assumptions. A reset/home is
                            // required before a show request is accepted again.
                            workflows.cancel_pending();
                        }
                        schedule_nodes(
                            &nodes,
                            control.role,
                            &screen_hub,
                            Arc::clone(&audio_slots),
                            &format!("control `{}`", request.id),
                            &workflows,
                        )
                    })
                };
                let _ = request.response.send(result);
            }
            request = volume_requests.recv() => {
                let Some(request) = request else { continue };
                let result = volume_devices.get(&request.id).ok_or_else(|| {
                    format!("unknown audio output `{}`", request.id)
                }).and_then(|device| {
                    let target = resolve_volume_target(&volume_audio, Some(device.clone()))
                        .map_err(|error| error.to_string())?;
                    if let Some(percent) = request.percent {
                        volume_audio
                            .set_volume_percent(&target, percent)
                            .map_err(|error| error.to_string())?;
                        if percent > 0 {
                            volume_audio
                                .set_muted(&target, "0")
                                .map_err(|error| error.to_string())?;
                        }
                    }
                    let volume = volume_audio.volume(&target).map_err(|error| error.to_string())?;
                    Ok(web::VolumeStatus {
                        id: request.id.clone(),
                        percent: (volume.level * 100.0).round().clamp(0.0, 100.0) as u8,
                        muted: volume.muted,
                    })
                });
                let _ = request.response.send(result);
            }
            request = reload_requests.recv(), if reload_available => {
                let Some(()) = request else { continue };
                fx_log!("dashboard requested show configuration reload");
                workflows.cancel_pending();
                audio_runtime.stop_all();
                if let Some(control) = controls.get("stop_all") {
                    match control.nodes_for(web::ControlPhase::Press, None, None)
                        .and_then(|nodes| schedule_nodes(
                            &nodes,
                            control.role,
                            &screen_hub,
                            Arc::clone(&audio_slots),
                            "show reload safety stop",
                            &workflows,
                        )) {
                        Ok(()) => {}
                        Err(error) => fx_log!("show reload safety stop failed: {error}"),
                    }
                }
                // Give the accepted HTTP response and safety-stop cues time to
                // leave this process before its systemd supervisor restarts it.
                tokio::time::sleep(Duration::from_millis(500)).await;
                return Err(fx_audio::FxError::Server(
                    "show configuration reload requested".into(),
                ));
            }
            server_result = server_result_rx.recv(), if server_started => {
                return match server_result {
                    Some(Ok(())) => Err(fx_audio::FxError::Server("HTTP server stopped unexpectedly".into())),
                    Some(Err(error)) => Err(fx_audio::FxError::Server(error.to_string())),
                    None => Err(fx_audio::FxError::Server("HTTP server task stopped".into())),
                };
            }
            _ = kiosk_check.tick(), if kiosk.is_some() => {
                if let Some(status) = kiosk.as_mut().expect("guarded by is_some").try_wait()? {
                    return Err(fx_audio::FxError::Server(format!(
                        "kiosk exited with {status}; see {}",
                        show.kiosk.log_file.display()
                    )));
                }
            }
            signal = tokio::signal::ctrl_c() => {
                signal.map_err(fx_audio::FxError::Io)?;
                fx_log!("stopping show");
                return Ok(());
            }
        }
    }
}

fn compile_flows(
    show: &show_config::ShowConfig,
    cue_senders: &BTreeMap<String, cue_link::CueLinkSender>,
) -> Result<CompiledFlows> {
    let mut compiled = BTreeMap::new();
    let mut named = BTreeMap::new();
    for (flow_name, flow) in &show.flows {
        let source_link = show.sources[&flow.trigger.source].link().to_string();
        let mut nodes = Vec::new();
        for node in &flow.nodes {
            let action = match &node.action {
                show_config::ActionConfig::AudioPlay {
                    sink,
                    asset,
                    volume,
                } => {
                    let show_config::SinkConfig::Audio {
                        volume: sink_volume,
                        ..
                    } = &show.sinks[sink]
                    else {
                        unreachable!("validated audio sink")
                    };
                    RuntimeAction::Audio {
                        track: asset.clone(),
                        sink: sink.clone(),
                        volume: volume.or(*sink_volume),
                    }
                }
                show_config::ActionConfig::ScreenCommand {
                    sink,
                    command,
                    final_state,
                    expires_after_ms,
                } => {
                    let show_config::SinkConfig::Screen { screen_id, .. } = &show.sinks[sink]
                    else {
                        unreachable!("validated screen sink")
                    };
                    RuntimeAction::Screen {
                        screen_id: screen_id.clone(),
                        command: command.clone(),
                        final_state: final_state.clone(),
                        expires_after_ms: *expires_after_ms,
                    }
                }
                show_config::ActionConfig::CueEmit {
                    sink,
                    cue,
                    expires_after_ms,
                    wait_for,
                    timeout_ms,
                } => {
                    let show_config::SinkConfig::Cue {
                        link,
                        target,
                        namespace,
                    } = &show.sinks[sink]
                    else {
                        unreachable!("validated cue sink")
                    };
                    RuntimeAction::Cue {
                        sink: sink.clone(),
                        link: link.clone(),
                        sender: cue_senders[link].clone(),
                        target: target.clone(),
                        cue: show_config::qualified_cue(namespace, cue),
                        schedule_at_board: matches!(
                            show.links[link],
                            show_config::LinkConfig::MqttCue { .. }
                        ),
                        expires_after_ms: *expires_after_ms,
                        wait_for: wait_for.clone(),
                        timeout_ms: *timeout_ms,
                    }
                }
            };
            nodes.push(RuntimeNode {
                id: format!("{flow_name}/{}", node.id),
                at_ms: node.at_ms,
                after: node
                    .after
                    .iter()
                    .map(|id| format!("{flow_name}/{id}"))
                    .collect(),
                transition: node
                    .transition
                    .as_deref()
                    .and_then(state::TransitionRef::parse),
                action,
            });
        }
        let runtime = RuntimeFlow {
            role: flow.role,
            nodes,
        };
        compiled
            .entry((source_link, flow.trigger.cue.clone()))
            .or_insert_with(Vec::new)
            .push(runtime.clone());
        named.insert(flow_name.clone(), runtime);
    }
    Ok(CompiledFlows {
        by_trigger: compiled,
        by_name: named,
    })
}

fn is_display_alias(
    control: &RuntimeControl,
    screen_id: &str,
    command: &screen::EyeCommand,
    final_state: &screen::EyeSnapshot,
) -> bool {
    control.release.is_empty()
        && control.press.len() == 1
        && control.press[0].at_ms == 0
        && control.press[0].after.is_empty()
        && matches!(&control.press[0].action, RuntimeAction::Screen {
            screen_id: target, command: action, final_state: state, ..
        } if target == screen_id && action == command && state == final_state)
}

fn live_display_control(id: &str, hub: &screen::ScreenHub) -> Option<RuntimeControl> {
    let (target, operation) = id.strip_prefix("client/")?.rsplit_once('/')?;
    if !hub.has_client(target) {
        return None;
    }
    let (command, final_state) = match operation {
        "wake" => (
            screen::EyeCommand::Wake,
            screen::EyeSnapshot {
                mode: screen::EyeMode::Tipping,
                gaze: screen::Gaze { x: -0.25, y: -0.65 },
            },
        ),
        "reset" => (
            screen::EyeCommand::Reset,
            screen::EyeSnapshot {
                mode: screen::EyeMode::Sleeping,
                gaze: screen::Gaze { x: 0.0, y: 0.0 },
            },
        ),
        _ => return None,
    };
    Some(RuntimeControl {
        role: show_config::FlowRole::Utility,
        press: vec![RuntimeNode {
            id: id.into(),
            at_ms: 0,
            after: Vec::new(),
            transition: None,
            action: RuntimeAction::Screen {
                screen_id: target.into(),
                command,
                final_state,
                expires_after_ms: 2000,
            },
        }],
        release: Vec::new(),
    })
}

fn compile_controls(
    show: &show_config::ShowConfig,
    cue_senders: &BTreeMap<String, cue_link::CueLinkSender>,
    flows: &BTreeMap<String, RuntimeFlow>,
) -> Result<BTreeMap<String, RuntimeControl>> {
    let mut compiled = BTreeMap::new();
    for (id, control) in &show.controls {
        let runtime = match control {
            show_config::ControlConfig::Flow { flow, .. } => RuntimeControl {
                role: flows[flow].role,
                press: flows[flow].nodes.clone(),
                release: Vec::new(),
            },
            show_config::ControlConfig::Cue {
                sink,
                cue,
                release_cue,
                expires_after_ms,
                ..
            } => {
                let show_config::SinkConfig::Cue {
                    link,
                    target,
                    namespace,
                } = &show.sinks[sink]
                else {
                    unreachable!("validated cue control")
                };
                let make_node = |suffix: &str, cue: &str| RuntimeNode {
                    id: format!("control/{id}/{suffix}"),
                    at_ms: 0,
                    after: Vec::new(),
                    transition: None,
                    action: RuntimeAction::Cue {
                        sink: sink.clone(),
                        link: link.clone(),
                        sender: cue_senders[link].clone(),
                        target: target.clone(),
                        cue: show_config::qualified_cue(namespace, cue),
                        schedule_at_board: matches!(
                            show.links[link],
                            show_config::LinkConfig::MqttCue { .. }
                        ),
                        expires_after_ms: *expires_after_ms,
                        wait_for: None,
                        timeout_ms: 10_000,
                    },
                };
                RuntimeControl {
                    role: show_config::FlowRole::Utility,
                    press: vec![make_node("press", cue)],
                    release: release_cue
                        .as_deref()
                        .map(|cue| vec![make_node("release", cue)])
                        .unwrap_or_default(),
                }
            }
        };
        compiled.insert(id.clone(), runtime);
    }
    Ok(compiled)
}

async fn wait_for_server(address: std::net::SocketAddr) -> Result<()> {
    for _ in 0..50 {
        if tokio::net::TcpStream::connect(address).await.is_ok() {
            return Ok(());
        }
        tokio::time::sleep(Duration::from_millis(100)).await;
    }
    Err(fx_audio::FxError::Server(format!(
        "timed out waiting for eye server at {address}"
    )))
}

fn dispatch_show_event(
    message: &cue_link::EventMessage,
    flows: &BTreeMap<(String, String), Vec<RuntimeFlow>>,
    screen_hub: &ScreenHub,
    audio_slots: Arc<Semaphore>,
    workflows: &workflow::WorkflowHub,
    audio: &audio_runtime::AudioRuntime,
) {
    let link = message.link.as_deref().unwrap_or("unknown");
    let matching = flows
        .get(&(link.to_string(), message.event.clone()))
        .map(Vec::as_slice)
        .unwrap_or_default();
    let source = message.source.as_deref().unwrap_or("unknown");
    let rssi = message
        .rssi
        .map(|value| format!(" at {value} dBm"))
        .unwrap_or_default();
    fx_log!(
        "cue `{}` sequence {:?} from {source}{rssi} via `{link}`: matched {} flow(s)",
        message.event,
        message.sequence,
        matching.len()
    );
    for flow in matching {
        if matches!(
            flow.role,
            show_config::FlowRole::Reset | show_config::FlowRole::Stop
        ) {
            workflows.cancel_pending();
            audio.stop_all();
        }
        if let Err(error) = schedule_nodes(
            &flow.nodes,
            flow.role,
            screen_hub,
            Arc::clone(&audio_slots),
            &format!("cue `{}`", message.event),
            workflows,
        ) {
            fx_log!("could not schedule cue: {error}");
        }
    }
}

fn schedule_nodes(
    nodes: &[RuntimeNode],
    role: show_config::FlowRole,
    screen_hub: &ScreenHub,
    audio_slots: Arc<Semaphore>,
    reason: &str,
    workflows: &workflow::WorkflowHub,
) -> std::result::Result<(), String> {
    fx_log!("{reason}: scheduling {} node(s)", nodes.len());
    workflows.start(nodes, role, screen_hub, audio_slots, reason)
}

async fn execute_node(
    node: RuntimeNode,
    screen_hub: &ScreenHub,
    _audio_slots: Arc<Semaphore>,
    workflows: &workflow::WorkflowHub,
    execute_at_ms: Option<u64>,
    generation: u32,
) -> std::result::Result<String, String> {
    match node.action {
        RuntimeAction::Audio {
            track,
            sink,
            volume,
        } => {
            let audio = workflows.audio()?;
            audio
                .play(&track, &sink, volume, workflows)
                .await?
                .wait()
                .await
        }
        RuntimeAction::Screen {
            screen_id,
            command,
            final_state,
            expires_after_ms,
        } => {
            let receiver = screen_hub.subscribe_applied();
            let envelope = screen_hub
                .publish(
                    &screen_id,
                    command,
                    final_state,
                    workflow::now_ms().saturating_add(expires_after_ms),
                )
                .map_err(|e| e.to_string())?;
            screen_hub
                .wait_applied(receiver, &screen_id, envelope.seq, expires_after_ms)
                .await
        }
        RuntimeAction::Cue {
            sink,
            link,
            sender,
            target,
            cue,
            schedule_at_board: _,
            expires_after_ms,
            wait_for,
            timeout_ms,
        } => {
            // Subscribe before dispatch: a fast assembly can report immediately.
            let receiver = workflows.subscribe();
            let scheduled_for = execute_at_ms.unwrap_or(0);
            let command_id = sender
                .try_emit_tracked_scheduled(
                    target.clone(),
                    cue.clone(),
                    scheduled_for,
                    Duration::from_millis(expires_after_ms),
                    generation,
                )
                .map_err(|e| e.to_string())?;
            fx_log!(
                "node `{}` queued cue `{cue}` for `{target}` on `{sink}` as {command_id:016X}{} generation {generation}",
                node.id,
                execute_at_ms
                    .map(|at| format!(" for {at}"))
                    .unwrap_or_default(),
            );
            match wait_for {
                Some(event) => {
                    let timeout_ms = timeout_ms.saturating_add(
                        execute_at_ms
                            .unwrap_or(0)
                            .saturating_sub(workflow::now_ms()),
                    );
                    workflow::wait_for_status(
                        receiver, &link, &target, command_id, &event, timeout_ms,
                    )
                    .await
                }
                None => {
                    if let Some(at) = execute_at_ms {
                        tokio::time::sleep(Duration::from_millis(
                            at.saturating_sub(workflow::now_ms()),
                        ))
                        .await;
                        Ok(format!("cue scheduled for {at}"))
                    } else {
                        Ok("cue queued".into())
                    }
                }
            }
        }
    }
}

fn run_serial(command: SerialCommand) -> Result<()> {
    match command {
        SerialCommand::List => {
            let devices = serial_input::devices()?;
            if devices.is_empty() {
                println!("no serial devices found");
            } else {
                for device in devices {
                    println!("{}", device.display());
                }
            }
            Ok(())
        }
        SerialCommand::Monitor(connection) => {
            let port = serial_input::select(connection.port)?;
            fx_log!("monitoring {} at {} baud", port.display(), connection.baud);
            let mut lines = serial_input::SerialLines::open(&port, connection.baud)?;
            while let Some(line) = lines.next_line()? {
                println!("{line}");
            }
            Ok(())
        }
        SerialCommand::PlayOnce {
            event,
            file,
            device,
            connection,
        } => {
            let port = serial_input::select(connection.port)?;
            fx_log!(
                "waiting for event `{event}` on {} at {} baud",
                port.display(),
                connection.baud
            );
            let mut lines = serial_input::SerialLines::open(&port, connection.baud)?;
            while let Some(line) = lines.next_line()? {
                if serial_input::event_name(&line).as_deref() == Some(event.as_str()) {
                    fx_log!("received `{event}`; playing {}", file.display());
                    return PipeWire::default().play(&PlaybackRequest {
                        file,
                        device: DeviceAliases::load_default()?.resolve(device).into(),
                        options: PlaybackOptions::default(),
                    });
                }
            }
            Err(fx_audio::FxError::Serial(format!(
                "serial device closed before event `{event}` arrived"
            )))
        }
        SerialCommand::Mux {
            mappings,
            device,
            volume,
            max_active,
            max_events,
            dedupe_capacity,
            connection,
        } => run_serial_mux(
            mappings,
            device,
            volume,
            max_active,
            max_events,
            dedupe_capacity,
            connection,
        ),
    }
}

#[allow(clippy::too_many_arguments)]
fn run_serial_mux(
    mappings: Vec<EventMapping>,
    device: Option<String>,
    volume: Option<f32>,
    max_active: usize,
    max_events: Option<usize>,
    dedupe_capacity: usize,
    connection: SerialConnectionArgs,
) -> Result<()> {
    let aliases = DeviceAliases::load_default()?;
    let device = DeviceSelector::from(aliases.resolve(device));
    let mut routes: BTreeMap<String, Vec<RuntimeRoute>> = BTreeMap::new();
    for mapping in mappings {
        routes.entry(mapping.event).or_default().push(RuntimeRoute {
            file: mapping.file,
            output_name: "cli".into(),
            device: device.clone(),
            volume,
            delay_ms: 0,
        });
    }

    run_mux_loop(routes, max_active, max_events, dedupe_capacity, connection)
}

fn run_mux_loop(
    routes: BTreeMap<String, Vec<RuntimeRoute>>,
    max_active: usize,
    max_events: Option<usize>,
    dedupe_capacity: usize,
    connection: SerialConnectionArgs,
) -> Result<()> {
    if max_active == 0 {
        return Err(fx_audio::FxError::Serial(
            "max-active must be greater than zero".into(),
        ));
    }
    if dedupe_capacity == 0 {
        return Err(fx_audio::FxError::Serial(
            "dedupe-capacity must be greater than zero".into(),
        ));
    }

    let port = serial_input::select(connection.port)?;
    let mut lines = serial_input::SerialLines::open(&port, connection.baud)?;
    let mut deduper = cue_link::EventDeduper::new(dedupe_capacity);
    let mut playbacks: Vec<JoinHandle<()>> = Vec::new();
    let mut matched_events = 0usize;

    fx_log!(
        "muxing {} event route(s) from {} at {} baud",
        routes.len(),
        port.display(),
        connection.baud
    );

    while let Some(line) = lines.next_line()? {
        reap_finished(&mut playbacks);
        let Some(message) = serial_input::event_message(&line) else {
            fx_log!("ignoring non-event serial line: {line}");
            continue;
        };
        if deduper.is_duplicate(&message) {
            fx_log!(
                "deduped event `{}` sequence {:?}",
                message.event,
                message.sequence
            );
            continue;
        }
        let Some(files) = routes.get(&message.event) else {
            fx_log!("ignoring unmapped event `{}`", message.event);
            continue;
        };

        let source = message
            .source
            .as_deref()
            .map(|source| format!(" from {source}"))
            .unwrap_or_default();
        let rssi = message
            .rssi
            .map(|rssi| format!(" at {rssi} dBm"))
            .unwrap_or_default();
        fx_log!(
            "event `{}` sequence {:?}{source}{rssi}: starting {} sound(s)",
            message.event,
            message.sequence,
            files.len()
        );
        for route in files {
            reap_finished(&mut playbacks);
            if playbacks.len() >= max_active {
                fx_log!(
                    "dropping sound {}: {max_active} streams already active",
                    route.file.display()
                );
                continue;
            }

            fx_log!(
                "  playing {} on `{}`{}",
                route.file.display(),
                route.output_name,
                if route.delay_ms == 0 {
                    String::new()
                } else {
                    format!(" after {}ms", route.delay_ms)
                }
            );
            let request = PlaybackRequest {
                file: route.file.clone(),
                device: route.device.clone(),
                options: PlaybackOptions {
                    volume: route.volume,
                    latency: None,
                },
            };
            let delay_ms = route.delay_ms;
            playbacks.push(std::thread::spawn(move || {
                if delay_ms > 0 {
                    std::thread::sleep(Duration::from_millis(delay_ms));
                }
                if let Err(error) = PipeWire::default().play(&request) {
                    fx_log!("playback failed: {error}");
                }
            }));
        }

        matched_events += 1;
        if max_events.is_some_and(|limit| matched_events >= limit) {
            break;
        }
    }

    for playback in playbacks {
        let _ = playback.join();
    }
    Ok(())
}

fn reap_finished(playbacks: &mut Vec<JoinHandle<()>>) {
    let mut index = 0;
    while index < playbacks.len() {
        if playbacks[index].is_finished() {
            let playback = playbacks.swap_remove(index);
            let _ = playback.join();
        } else {
            index += 1;
        }
    }
}

fn run_volume(command: VolumeCommand) -> Result<()> {
    let audio = PipeWire::default();
    let (device, operation) = match command {
        VolumeCommand::Get { device } => (device, ("get", 0)),
        VolumeCommand::Set { percent, device } => (device, ("set", percent)),
        VolumeCommand::Up { percent, device } => (device, ("up", percent)),
        VolumeCommand::Down { percent, device } => (device, ("down", percent)),
        VolumeCommand::Mute { device } => (device, ("mute", 0)),
        VolumeCommand::Unmute { device } => (device, ("unmute", 0)),
        VolumeCommand::Toggle { device } => (device, ("toggle", 0)),
    };
    let target = resolve_volume_target(&audio, device)?;
    let (name, percent) = operation;
    if percent > 100 {
        return Err(fx_audio::FxError::InvalidPlayback(format!(
            "volume percentage {percent} is outside 0..=100"
        )));
    }
    match name {
        "get" => {}
        "set" => audio.set_volume_percent(&target, percent)?,
        "up" => audio.change_volume_percent(&target, percent, true)?,
        "down" => audio.change_volume_percent(&target, percent, false)?,
        "mute" => audio.set_muted(&target, "1")?,
        "unmute" => audio.set_muted(&target, "0")?,
        "toggle" => audio.set_muted(&target, "toggle")?,
        _ => unreachable!(),
    }
    let volume = audio.volume(&target)?;
    println!(
        "{:.0}%{}",
        volume.level * 100.0,
        if volume.muted { " (muted)" } else { "" }
    );
    Ok(())
}

fn resolve_volume_target(audio: &PipeWire, device: Option<String>) -> Result<String> {
    let Some(device) = DeviceAliases::load_default()?.resolve(device) else {
        return Ok("@DEFAULT_AUDIO_SINK@".into());
    };
    let output = audio
        .devices()?
        .into_iter()
        .find(|output| output.id == device)
        .ok_or_else(|| {
            fx_audio::FxError::InvalidPlayback(format!(
                "audio device `{device}` is not currently available"
            ))
        })?;
    output
        .backend_index
        .map(|index| index.to_string())
        .ok_or_else(|| {
            fx_audio::FxError::InvalidPlayback(format!(
                "audio device `{device}` has no PipeWire index"
            ))
        })
}

fn run_outputs(command: OutputCommand) -> Result<()> {
    let audio = PipeWire::default();
    match command {
        OutputCommand::List => {
            let aliases = DeviceAliases::load_default()?;
            for device in audio.devices()? {
                let marker = if device.is_default { '*' } else { ' ' };
                let index = device
                    .backend_index
                    .map(|index| index.to_string())
                    .unwrap_or_else(|| "-".into());
                let names = aliases.names_for(&device.id).collect::<Vec<_>>();
                let suffix = if names.is_empty() {
                    String::new()
                } else {
                    format!("  [{}]", names.join(", "))
                };
                println!("{marker} {index:>3}  {}{suffix}", device.id);
            }
            Ok(())
        }
        OutputCommand::Status => {
            print!("{}", audio.status()?);
            Ok(())
        }
        OutputCommand::SetDefault { backend_index } => audio.set_default(backend_index),
        OutputCommand::Alias { name, device_id } => {
            let mut aliases = DeviceAliases::load_default()?;
            aliases.set(name.clone(), device_id)?;
            println!("saved alias `{name}`");
            Ok(())
        }
        OutputCommand::Unalias { name } => {
            let mut aliases = DeviceAliases::load_default()?;
            if aliases.remove(&name)? {
                println!("removed alias `{name}`");
            } else {
                println!("alias `{name}` was not configured");
            }
            Ok(())
        }
        OutputCommand::Aliases => {
            let aliases = DeviceAliases::load_default()?;
            if aliases.iter().next().is_none() {
                println!("no device aliases configured");
            } else {
                for (alias, device_id) in aliases.iter() {
                    println!("{alias}\t{device_id}");
                }
            }
            Ok(())
        }
    }
}

fn run_bluetooth(command: BluetoothCommand) -> Result<()> {
    let bluez = BluezCli::default();
    match command {
        BluetoothCommand::Devices { filter } => {
            print_devices_with_state(&bluez, bluez.devices(filter.into())?)?;
            Ok(())
        }
        BluetoothCommand::Scan { seconds } => {
            println!("scanning for {seconds}s; put the speaker in pairing mode...");
            print_devices(bluez.scan(Duration::from_secs(seconds))?);
            Ok(())
        }
        BluetoothCommand::Info { address } => print_command_result(bluez.info(&address)?),
        BluetoothCommand::Pair { address } => print_command_result(bluez.pair(&address)?),
        BluetoothCommand::Trust { address } => print_command_result(bluez.trust(&address)?),
        BluetoothCommand::Connect { address } => print_command_result(bluez.connect(&address)?),
        BluetoothCommand::Disconnect { address } => {
            print_command_result(bluez.disconnect(&address)?)
        }
        BluetoothCommand::Remove { address } => print_command_result(bluez.remove(&address)?),
    }
}

fn print_devices(devices: Vec<fx_audio::bluetooth::BluetoothDevice>) {
    if devices.is_empty() {
        println!("no devices found");
    } else {
        for device in devices {
            println!("{}  {}", device.address, device.name);
        }
    }
}

fn print_devices_with_state(
    bluez: &BluezCli,
    devices: Vec<fx_audio::bluetooth::BluetoothDevice>,
) -> Result<()> {
    if devices.is_empty() {
        println!("no devices found");
        return Ok(());
    }

    for device in devices {
        let info = bluez.device_info(&device.address)?;
        let state = if info.connected {
            "connected"
        } else if info.paired {
            "paired, disconnected"
        } else {
            "not paired"
        };
        println!("{}  {}  [{state}]", info.address, info.name);
    }
    Ok(())
}

fn print_command_result(output: String) -> Result<()> {
    print!("{output}");
    Ok(())
}

#[cfg(test)]
mod cli_tests {
    use super::*;

    fn dc_profile_target() -> DcProfileTarget {
        let (sender, _receiver) = cue_link::CueLinkSender::channel(8);
        DcProfileTarget {
            sink: "dc_a".into(),
            link: "simulated".into(),
            sender,
            target: "00000000000A".into(),
            schedule_at_board: false,
        }
    }

    fn dc_control(cue: &str) -> RuntimeControl {
        let (sender, _receiver) = cue_link::CueLinkSender::channel(8);
        let node = |cue: &str| RuntimeNode {
            id: "test".into(),
            at_ms: 0,
            after: Vec::new(),
            transition: None,
            action: RuntimeAction::Cue {
                sink: "dc_a".into(),
                link: "simulated".into(),
                sender: sender.clone(),
                target: "00000000000A".into(),
                cue: cue.into(),
                schedule_at_board: false,
                expires_after_ms: 500,
                wait_for: None,
                timeout_ms: 1000,
            },
        };
        RuntimeControl {
            role: show_config::FlowRole::Utility,
            press: vec![node(cue)],
            release: vec![node("dc:stop")],
        }
    }

    #[test]
    fn pwm_only_changes_dc_jog_duty_preserving_target_direction_and_lease() {
        for direction in ["fwd", "rev"] {
            let original = format!("dc:jog:{direction}:255");
            let control = dc_control(&original);
            assert_eq!(control.pwm(), Some(255));
            for duty in [1, 64, 128, 191, 255] {
                let nodes = control
                    .nodes_for(web::ControlPhase::Press, Some(duty), None)
                    .unwrap();
                assert!(
                    matches!(&nodes[0].action, RuntimeAction::Cue { cue, target, expires_after_ms, .. }
                    if cue == &format!("dc:jog:{direction}:{duty}") && target == "00000000000A" && *expires_after_ms == 500)
                );
            }
            let nodes = control
                .nodes_for(web::ControlPhase::Release, None, None)
                .unwrap();
            assert!(matches!(&nodes[0].action, RuntimeAction::Cue { cue, .. } if cue == "dc:stop"));
            assert!(
                control
                    .nodes_for(web::ControlPhase::Press, Some(0), None)
                    .is_err()
            );
            assert!(
                control
                    .nodes_for(web::ControlPhase::Release, Some(128), None)
                    .is_err()
            );
            assert!(
                matches!(&control.press[0].action, RuntimeAction::Cue { cue, .. } if cue == &original)
            );
        }
    }

    #[test]
    fn pwm_rejects_timed_stepper_malformed_and_non_dc_controls() {
        for cue in [
            "dc:fwd:70:500",
            "step:jog:fwd:30",
            "dc:stop",
            "dc:jog:fwd:0",
            "dc:jog:fwd:256",
            "dc:jog:side:10",
            "dc:jog:fwd:10:500",
            "dc:jog:fwd:+10",
        ] {
            let control = dc_control(cue);
            assert_eq!(control.pwm(), None, "{cue}");
            assert!(
                control
                    .nodes_for(web::ControlPhase::Press, Some(128), None)
                    .is_err(),
                "{cue}"
            );
        }
    }

    #[test]
    fn rpm_only_changes_finite_stepper_speed_within_safe_tuning_range() {
        let mut control = dc_control("step:rev:1600:60");
        control.release.clear();
        assert_eq!(control.rpm(), Some(60));
        for rpm in [10, 30, 60, 90, 120] {
            let nodes = control
                .nodes_for(web::ControlPhase::Press, None, Some(rpm))
                .unwrap();
            assert!(matches!(&nodes[0].action,
                RuntimeAction::Cue { cue, target, .. }
                if cue == &format!("step:rev:1600:{rpm}") && target == "00000000000A"));
        }
        for rpm in [1, 9, 121, 9000] {
            assert!(
                control
                    .nodes_for(web::ControlPhase::Press, None, Some(rpm))
                    .is_err()
            );
        }
        assert!(
            control
                .nodes_for(web::ControlPhase::Press, Some(128), Some(60))
                .is_err()
        );
        assert!(matches!(&control.press[0].action,
            RuntimeAction::Cue { cue, .. } if cue == "step:rev:1600:60"));
    }

    #[test]
    fn rpm_rejects_jogs_releases_and_non_stepper_controls() {
        for cue in [
            "step:jog:rev:30",
            "step:rev:0:60",
            "step:side:1600:60",
            "dc:jog:fwd:255",
        ] {
            let mut control = dc_control(cue);
            control.release.clear();
            assert_eq!(control.rpm(), None, "{cue}");
            assert!(
                control
                    .nodes_for(web::ControlPhase::Press, None, Some(60))
                    .is_err(),
                "{cue}"
            );
        }
        let mut control = dc_control("step:fwd:1600:60");
        control.release.clear();
        assert!(
            control
                .nodes_for(web::ControlPhase::Release, None, Some(60))
                .is_err()
        );
    }

    #[test]
    fn dc_profile_builds_smoothed_motor_cue_with_optional_audio_offset() {
        let profile = web::DcProfileInput {
            motor_enabled: true,
            motor_delay_ms: None,
            direction: web::DcDirection::Forward,
            peak_pwm_percent: 85,
            minimum_pwm_percent: 20,
            ramp_ms: 300,
            hold_ms: 700,
            fade_ms: 2200,
            audio: Some(web::DcProfileAudio {
                track: "tractor_tip".into(),
                output: "jbl".into(),
                motor_delay_ms: 500,
            }),
            eye: None,
            stepper: None,
        };
        let nodes = dc_profile_nodes(&profile, &dc_profile_target(), &ScreenHub::new([])).unwrap();
        assert_eq!(nodes.len(), 2);
        assert!(matches!(&nodes[0].action,
            RuntimeAction::Audio { track, sink, .. }
            if track == "tractor_tip" && sink == "jbl"));
        assert_eq!(nodes[1].at_ms, 500);
        assert!(matches!(&nodes[1].action,
            RuntimeAction::Cue { cue, target, timeout_ms, .. }
            if cue == "dc:c:f:217:51:300:700:2200"
                && target == "00000000000A" && *timeout_ms == 5200));
    }

    #[test]
    fn dc_profile_schedules_private_wake_by_saved_device_without_retiming_motor() {
        let hub = ScreenHub::new([(
            "eye".into(),
            screen::EyeSnapshot {
                mode: screen::EyeMode::Sleeping,
                gaze: screen::Gaze { x: 0.0, y: 0.0 },
            },
        )]);
        let first = hub
            .register_client("eye", "saved-eye".into(), "Eye".into())
            .unwrap();
        let second = hub
            .register_client("eye", "saved-eye".into(), "Eye".into())
            .unwrap();
        let _other = hub
            .register_client("eye", "other-eye".into(), "Other".into())
            .unwrap();
        let profile = web::DcProfileInput {
            motor_enabled: true,
            motor_delay_ms: None,
            direction: web::DcDirection::Forward,
            peak_pwm_percent: 60,
            minimum_pwm_percent: 20,
            ramp_ms: 300,
            hold_ms: 700,
            fade_ms: 3500,
            audio: Some(web::DcProfileAudio {
                track: "tractor_tip".into(),
                output: "jbl".into(),
                motor_delay_ms: 4000,
            }),
            eye: Some(web::DcProfileEye {
                device_id: "saved-eye".into(),
                wake_delay_ms: 750,
            }),
            stepper: None,
        };
        let nodes = dc_profile_nodes(&profile, &dc_profile_target(), &hub).unwrap();
        assert_eq!(nodes.len(), 4);
        assert_eq!(nodes[0].at_ms, 0);
        assert_eq!(nodes[1].at_ms, 4000);
        assert!(matches!(&nodes[1].action, RuntimeAction::Cue { cue, .. }
            if cue == "dc:c:f:153:51:300:700:3500"));
        for node in &nodes[2..] {
            assert_eq!(node.at_ms, 750);
            assert!(node.after.is_empty());
            assert!(
                matches!(&node.action, RuntimeAction::Screen { screen_id, command: screen::EyeCommand::Wake, .. }
                if screen_id == &first.token || screen_id == &second.token)
            );
        }
        // The selected identity survives new WebSocket tokens.
        drop(first);
        drop(second);
        assert!(dc_profile_nodes(&profile, &dc_profile_target(), &hub).is_err());
        let reconnected = hub
            .register_client("eye", "saved-eye".into(), "Eye".into())
            .unwrap();
        let nodes = dc_profile_nodes(&profile, &dc_profile_target(), &hub).unwrap();
        assert_eq!(nodes.len(), 3);
        assert!(
            matches!(&nodes[2].action, RuntimeAction::Screen { screen_id, .. } if screen_id == &reconnected.token)
        );
        for eye in [
            web::DcProfileEye {
                device_id: "".into(),
                wake_delay_ms: 750,
            },
            web::DcProfileEye {
                device_id: "saved-eye".into(),
                wake_delay_ms: 10_001,
            },
            web::DcProfileEye {
                device_id: "unknown".into(),
                wake_delay_ms: 750,
            },
        ] {
            assert!(
                dc_profile_nodes(
                    &web::DcProfileInput {
                        eye: Some(eye),
                        ..profile.clone()
                    },
                    &dc_profile_target(),
                    &hub
                )
                .is_err()
            );
        }
    }

    #[test]
    fn dc_profile_play_components_are_independent_and_keep_their_offsets() {
        let hub = ScreenHub::new([(
            "eye".into(),
            screen::EyeSnapshot {
                mode: screen::EyeMode::Sleeping,
                gaze: screen::Gaze { x: 0.0, y: 0.0 },
            },
        )]);
        let _client = hub
            .register_client("eye", "selected-eye".into(), "Eye".into())
            .unwrap();
        let mut stroke = dc_control("step:rev:1600:60");
        stroke.release.clear();
        assert_eq!(stroke.stroke_steps(), Some(1600));
        let controls = BTreeMap::from([("stroke".into(), stroke)]);
        for selection in 0..16 {
            let motor_enabled = selection & 2 != 0;
            let profile = web::DcProfileInput {
                motor_enabled,
                motor_delay_ms: Some(4000),
                direction: web::DcDirection::Forward,
                peak_pwm_percent: 60,
                minimum_pwm_percent: 20,
                ramp_ms: 300,
                hold_ms: 700,
                fade_ms: 3500,
                audio: (selection & 1 != 0).then(|| web::DcProfileAudio {
                    track: "tractor_tip".into(),
                    output: "speaker".into(),
                    motor_delay_ms: 0,
                }),
                eye: (selection & 4 != 0).then(|| web::DcProfileEye {
                    device_id: "selected-eye".into(),
                    wake_delay_ms: 750,
                }),
                stepper: (selection & 8 != 0).then(|| web::PlaybackStepper {
                    control: "stroke".into(),
                    rpm: 90,
                    delay_ms: 1500,
                }),
            };
            let result = playback_nodes(&profile, &dc_profile_target(), &hub, &controls);
            if selection == 0 {
                assert!(result.is_err());
                continue;
            }
            let nodes = result.unwrap();
            assert_eq!(nodes.len(), (selection as u32).count_ones() as usize);
            assert_eq!(
                nodes
                    .iter()
                    .any(|node| matches!(&node.action, RuntimeAction::Cue { cue, .. } if cue.starts_with("dc:"))),
                motor_enabled
            );
            for node in nodes {
                assert_eq!(
                    node.at_ms,
                    match node.action {
                        RuntimeAction::Audio { .. } => 0,
                        RuntimeAction::Cue { cue, target, .. } if cue.starts_with("step:") => {
                            assert_eq!(cue, "step:rev:1600:90");
                            assert_eq!(target, "00000000000A");
                            1500
                        }
                        RuntimeAction::Cue { .. } => 4000,
                        RuntimeAction::Screen { .. } => 750,
                    }
                );
            }
            if !motor_enabled {
                // Unused motor settings must neither dispatch nor prevent an eye/audio-only trial.
                let ignored = web::DcProfileInput {
                    peak_pwm_percent: 0,
                    fade_ms: 0,
                    motor_delay_ms: Some(u32::MAX),
                    ..profile
                };
                assert!(playback_nodes(&ignored, &dc_profile_target(), &hub, &controls).is_ok());
            }
        }
    }

    #[test]
    fn playback_rejects_unconfigured_strokes_bad_rpm_and_bad_delay_atomically() {
        let mut stroke = dc_control("step:rev:1600:60");
        stroke.release.clear();
        let controls = BTreeMap::from([
            ("stroke".into(), stroke),
            ("dc".into(), dc_control("dc:jog:fwd:255")),
        ]);
        for stepper in [
            web::PlaybackStepper {
                control: "missing".into(),
                rpm: 60,
                delay_ms: 500,
            },
            web::PlaybackStepper {
                control: "dc".into(),
                rpm: 60,
                delay_ms: 500,
            },
            web::PlaybackStepper {
                control: "stroke".into(),
                rpm: 9,
                delay_ms: 500,
            },
            web::PlaybackStepper {
                control: "stroke".into(),
                rpm: 121,
                delay_ms: 500,
            },
            web::PlaybackStepper {
                control: "stroke".into(),
                rpm: 60,
                delay_ms: 10001,
            },
        ] {
            let profile = web::DcProfileInput {
                motor_enabled: true,
                motor_delay_ms: Some(4000),
                direction: web::DcDirection::Forward,
                peak_pwm_percent: 60,
                minimum_pwm_percent: 20,
                ramp_ms: 300,
                hold_ms: 700,
                fade_ms: 3500,
                audio: None,
                eye: None,
                stepper: Some(stepper),
            };
            assert!(
                playback_nodes(
                    &profile,
                    &dc_profile_target(),
                    &ScreenHub::new([]),
                    &controls
                )
                .is_err()
            );
        }
    }

    #[test]
    fn dc_profile_rejects_unsafe_or_unrepresentable_parameters() {
        let base = web::DcProfileInput {
            motor_enabled: true,
            motor_delay_ms: None,
            direction: web::DcDirection::Reverse,
            peak_pwm_percent: 80,
            minimum_pwm_percent: 20,
            ramp_ms: 300,
            hold_ms: 700,
            fade_ms: 2200,
            audio: None,
            eye: None,
            stepper: None,
        };
        for profile in [
            web::DcProfileInput {
                peak_pwm_percent: 0,
                ..base.clone()
            },
            web::DcProfileInput {
                minimum_pwm_percent: 81,
                ..base.clone()
            },
            web::DcProfileInput {
                ramp_ms: 49,
                ..base.clone()
            },
            web::DcProfileInput {
                fade_ms: 10_000,
                ..base.clone()
            },
            web::DcProfileInput {
                ramp_ms: 9_999,
                hold_ms: 9_999,
                fade_ms: 50,
                ..base.clone()
            },
        ] {
            assert!(dc_profile_nodes(&profile, &dc_profile_target(), &ScreenHub::new([])).is_err());
        }
    }

    #[test]
    fn only_pure_immediate_display_controls_are_collapsed() {
        let state = screen::EyeSnapshot {
            mode: screen::EyeMode::Sleeping,
            gaze: screen::Gaze { x: 0.0, y: 0.0 },
        };
        let mut control = RuntimeControl {
            role: show_config::FlowRole::Utility,
            press: vec![RuntimeNode {
                id: "legacy-reset".into(),
                after: Vec::new(),
                transition: None,
                at_ms: 0,
                action: RuntimeAction::Screen {
                    screen_id: "eye".into(),
                    command: screen::EyeCommand::Reset,
                    final_state: state.clone(),
                    expires_after_ms: 2000,
                },
            }],
            release: Vec::new(),
        };
        assert!(is_display_alias(
            &control,
            "eye",
            &screen::EyeCommand::Reset,
            &state
        ));
        assert!(!is_display_alias(
            &control,
            "eye-2",
            &screen::EyeCommand::Reset,
            &state
        ));
        assert!(!is_display_alias(
            &control,
            "eye",
            &screen::EyeCommand::Wake,
            &state
        ));
        control.press[0].at_ms = 50;
        assert!(!is_display_alias(
            &control,
            "eye",
            &screen::EyeCommand::Reset,
            &state
        ));
        control.press[0].at_ms = 0;
        control.press.push(control.press[0].clone());
        assert!(!is_display_alias(
            &control,
            "eye",
            &screen::EyeCommand::Reset,
            &state
        ));
    }

    #[test]
    fn parses_run_config_and_kiosk_override() {
        let cli =
            Cli::try_parse_from(["fx", "run", "--config", "/shows/tractor.toml", "--no-kiosk"])
                .unwrap();
        let Command::Run(args) = cli.command else {
            panic!("expected run command");
        };
        let (config, kiosk, log_file) = args.into_options();
        assert_eq!(
            config.as_deref(),
            Some(std::path::Path::new("/shows/tractor.toml"))
        );
        assert_eq!(kiosk, Some(false));
        assert_eq!(log_file, std::path::Path::new("/tmp/fx-run.log"));
    }

    #[test]
    fn parses_volume_and_kiosk_commands() {
        assert!(Cli::try_parse_from(["fx", "volume", "set", "80", "--device", "jbl"]).is_ok());
        assert!(Cli::try_parse_from(["fx", "kiosk", "restart"]).is_ok());
    }
}
