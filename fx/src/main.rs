use std::{
    collections::BTreeMap,
    path::PathBuf,
    process::ExitCode,
    str::FromStr,
    sync::Arc,
    thread::JoinHandle,
    time::{Duration, SystemTime, UNIX_EPOCH},
};

macro_rules! fx_log {
    ($($argument:tt)*) => {
        crate::logging::line(format_args!($($argument)*))
    };
}
pub(crate) use fx_log;

mod aliases;
mod kiosk;
mod logging;
mod screen;
mod serial_input;
mod show_config;
mod web;

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
    action: RuntimeAction,
}

#[derive(Clone)]
enum RuntimeAction {
    Audio {
        file: PathBuf,
        sink: String,
        device: DeviceSelector,
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
        sender: serial_input::CueLinkSender,
        cue: String,
        expires_after_ms: u64,
    },
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
        let (port, baud) = link.serial();
        println!(
            "  {name}: serial-cue {} at {baud} baud",
            port.as_ref()
                .map(|port| port.display().to_string())
                .unwrap_or_else(|| "(auto)".into())
        );
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
                link, namespace, ..
            } => {
                println!("  {name}: cue -> {link} namespace `{namespace}`");
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
    let mut cue_senders = BTreeMap::new();
    for (link_name, link) in &show.links {
        let (port, baud) = link.serial();
        let (mut incoming, outgoing) =
            serial_input::spawn_reconnecting_link(link_name.clone(), port, baud, 128);
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
    drop(event_sender);

    let flows = compile_flows(&show, &cue_senders)?;
    let screen_hub = ScreenHub::new(show.sinks.values().filter_map(|sink| match sink {
        show_config::SinkConfig::Screen {
            screen_id,
            initial_state,
        } => Some((screen_id.clone(), initial_state.clone())),
        _ => None,
    }));
    let (server_result_tx, mut server_result_rx) = tokio::sync::mpsc::channel(1);
    let server_started = show.server.is_some();
    if let Some(server) = show.server.clone() {
        let bind = server.socket_addr()?;
        let hub = screen_hub.clone();
        tokio::spawn(async move {
            let result = web::serve(bind, server.static_dir, server.screen_id, hub).await;
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

    let mut deduper = serial_input::EventDeduper::new(show.playback.dedupe_capacity);
    let audio_slots = Arc::new(Semaphore::new(show.playback.max_active));

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
                if deduper.is_duplicate(&message) {
                    fx_log!("deduped event `{}` sequence {:?}", message.event, message.sequence);
                    continue;
                }
                dispatch_show_event(
                    &message,
                    &flows,
                    &screen_hub,
                    Arc::clone(&audio_slots),
                );
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
    cue_senders: &BTreeMap<String, serial_input::CueLinkSender>,
) -> Result<BTreeMap<(String, String), Vec<RuntimeNode>>> {
    let aliases = DeviceAliases::load_default()?;
    let mut compiled = BTreeMap::new();
    for (flow_name, flow) in &show.flows {
        let source_link = show.sources[&flow.trigger.source].link().to_string();
        let nodes = compiled
            .entry((source_link, flow.trigger.cue.clone()))
            .or_insert_with(Vec::new);
        for node in &flow.nodes {
            let action = match &node.action {
                show_config::ActionConfig::AudioPlay {
                    sink,
                    asset,
                    volume,
                } => {
                    let show_config::SinkConfig::Audio {
                        device,
                        volume: sink_volume,
                    } = &show.sinks[sink]
                    else {
                        unreachable!("validated audio sink")
                    };
                    RuntimeAction::Audio {
                        file: show.assets[asset].audio_file().to_path_buf(),
                        sink: sink.clone(),
                        device: DeviceSelector::from(aliases.resolve(Some(device.clone()))),
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
                } => {
                    let show_config::SinkConfig::Cue {
                        link, namespace, ..
                    } = &show.sinks[sink]
                    else {
                        unreachable!("validated cue sink")
                    };
                    RuntimeAction::Cue {
                        sink: sink.clone(),
                        sender: cue_senders[link].clone(),
                        cue: show_config::qualified_cue(namespace, cue),
                        expires_after_ms: *expires_after_ms,
                    }
                }
            };
            nodes.push(RuntimeNode {
                id: format!("{flow_name}/{}", node.id),
                at_ms: node.at_ms,
                action,
            });
        }
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
    message: &serial_input::EventMessage,
    flows: &BTreeMap<(String, String), Vec<RuntimeNode>>,
    screen_hub: &ScreenHub,
    audio_slots: Arc<Semaphore>,
) {
    let link = message.link.as_deref().unwrap_or("unknown");
    let nodes = flows
        .get(&(link.to_string(), message.event.clone()))
        .map(Vec::as_slice)
        .unwrap_or_default();
    let source = message.source.as_deref().unwrap_or("unknown");
    let rssi = message
        .rssi
        .map(|value| format!(" at {value} dBm"))
        .unwrap_or_default();
    fx_log!(
        "cue `{}` sequence {:?} from {source}{rssi} via `{link}`: scheduling {} node(s)",
        message.event,
        message.sequence,
        nodes.len()
    );

    for node in nodes {
        let node = node.clone();
        let screen_hub = screen_hub.clone();
        let audio_slots = Arc::clone(&audio_slots);
        tokio::spawn(async move {
            if node.at_ms > 0 {
                tokio::time::sleep(Duration::from_millis(node.at_ms)).await;
            }
            execute_node(node, &screen_hub, audio_slots).await;
        });
    }
}

async fn execute_node(node: RuntimeNode, screen_hub: &ScreenHub, audio_slots: Arc<Semaphore>) {
    match node.action {
        RuntimeAction::Audio {
            file,
            sink,
            device,
            volume,
        } => {
            let Ok(permit) = audio_slots.try_acquire_owned() else {
                fx_log!("node `{}` dropped: all playback slots are active", node.id);
                return;
            };
            let request = PlaybackRequest {
                file: file.clone(),
                device,
                options: PlaybackOptions {
                    volume,
                    latency: None,
                },
            };
            fx_log!("node `{}` playing {} on `{sink}`", node.id, file.display());
            let result = tokio::task::spawn_blocking(move || {
                let _permit = permit;
                PipeWire::default().play(&request)
            })
            .await;
            match result {
                Ok(Ok(())) => {}
                Ok(Err(error)) => fx_log!("node `{}` playback failed: {error}", node.id),
                Err(error) => fx_log!("node `{}` playback task failed: {error}", node.id),
            }
        }
        RuntimeAction::Screen {
            screen_id,
            command,
            final_state,
            expires_after_ms,
        } => publish_screen_action(
            screen_hub,
            &node.id,
            &screen_id,
            command,
            final_state,
            expires_after_ms,
        ),
        RuntimeAction::Cue {
            sink,
            sender,
            cue,
            expires_after_ms,
        } => match sender.try_emit(cue.clone(), Duration::from_millis(expires_after_ms)) {
            Ok(()) => fx_log!("node `{}` queued cue `{cue}` on `{sink}`", node.id),
            Err(error) => fx_log!("node `{}` cue action failed: {error}", node.id),
        },
    }
}

fn publish_screen_action(
    screen_hub: &ScreenHub,
    node_id: &str,
    screen_id: &str,
    command: screen::EyeCommand,
    final_state: screen::EyeSnapshot,
    expires_after_ms: u64,
) {
    let now_ms = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis()
        .min(u128::from(u64::MAX)) as u64;
    match screen_hub.publish(
        screen_id,
        command,
        final_state,
        now_ms.saturating_add(expires_after_ms),
    ) {
        Ok(envelope) => fx_log!(
            "node `{node_id}` sent {:?} to `{screen_id}` as screen sequence {}",
            envelope.command,
            envelope.seq
        ),
        Err(error) => fx_log!("node `{node_id}` screen action failed: {error}"),
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
    let mut deduper = serial_input::EventDeduper::new(dedupe_capacity);
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
