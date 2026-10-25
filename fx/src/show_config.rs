use std::{
    collections::{BTreeMap, BTreeSet},
    env, fs,
    net::SocketAddr,
    path::{Path, PathBuf},
};

use fx_audio::{FxError, Result};
use serde::{Deserialize, Serialize};

use crate::screen::{EyeCommand, EyeSnapshot};

const ACTIVE_SHOW_FILE: &str = "active-show";
const CONFIG_VERSION: u32 = 2;
const MAX_CUE_NAME_BYTES: usize = 31;

#[derive(Debug, Clone, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ShowConfig {
    pub version: u32,
    pub name: String,
    #[serde(default)]
    pub playback: PlaybackConfig,
    #[serde(default)]
    pub links: BTreeMap<String, LinkConfig>,
    #[serde(default)]
    pub sources: BTreeMap<String, SourceConfig>,
    #[serde(default)]
    pub assets: BTreeMap<String, AssetConfig>,
    #[serde(default)]
    pub sinks: BTreeMap<String, SinkConfig>,
    #[serde(default)]
    pub props: BTreeMap<String, PropConfig>,
    #[serde(default)]
    pub flows: BTreeMap<String, FlowConfig>,
    #[serde(default)]
    pub controls: BTreeMap<String, ControlConfig>,
    pub server: Option<ServerConfig>,
    #[serde(default)]
    pub kiosk: KioskConfig,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(tag = "type", deny_unknown_fields)]
pub enum LinkConfig {
    #[serde(rename = "serial-cue")]
    SerialCue {
        port: Option<PathBuf>,
        #[serde(default = "default_baud")]
        baud: u32,
    },
    #[serde(rename = "mqtt-cue")]
    MqttCue {
        host: String,
        #[serde(default = "default_mqtt_port")]
        port: u16,
        /// The Pi/fx node ID used as the source and MQTT inbox address.
        node: String,
        #[serde(default = "default_mqtt_client_id")]
        client_id: String,
        #[serde(default = "default_mqtt_topic_prefix")]
        topic_prefix: String,
        username: Option<String>,
        /// Read the broker password from this environment variable.
        password_env: Option<String>,
    },
    #[serde(rename = "simulated-cue")]
    SimulatedCue,
}

impl LinkConfig {
    pub fn serial(&self) -> Option<(Option<PathBuf>, u32)> {
        match self {
            Self::SerialCue { port, baud } => Some((port.clone(), *baud)),
            Self::MqttCue { .. } | Self::SimulatedCue => None,
        }
    }

    pub fn is_simulated(&self) -> bool {
        matches!(self, Self::SimulatedCue)
    }
}

#[derive(Debug, Clone, Deserialize)]
#[serde(tag = "type", deny_unknown_fields)]
pub enum SourceConfig {
    #[serde(rename = "cue-link")]
    CueLink { link: String },
}

impl SourceConfig {
    pub fn link(&self) -> &str {
        match self {
            Self::CueLink { link } => link,
        }
    }
}

#[derive(Debug, Clone, Deserialize)]
#[serde(tag = "type", deny_unknown_fields)]
pub enum AssetConfig {
    #[serde(rename = "audio")]
    Audio { file: PathBuf },
}

impl AssetConfig {
    pub fn audio_file(&self) -> &Path {
        match self {
            Self::Audio { file } => file,
        }
    }

    fn resolve_relative_to(&mut self, base: &Path) {
        match self {
            Self::Audio { file } if file.is_relative() => *file = base.join(&*file),
            Self::Audio { .. } => {}
        }
    }
}

#[derive(Debug, Clone, Deserialize)]
#[serde(tag = "type", deny_unknown_fields)]
pub enum SinkConfig {
    #[serde(rename = "audio")]
    Audio {
        /// Device alias or stable PipeWire node name.
        device: String,
        /// Default volume for actions using this sink.
        volume: Option<f32>,
    },
    #[serde(rename = "screen")]
    Screen {
        screen_id: String,
        initial_state: EyeSnapshot,
    },
    #[serde(rename = "cue")]
    Cue {
        link: String,
        target: String,
        #[serde(default)]
        namespace: String,
    },
}

#[derive(Debug, Clone, Deserialize)]
#[serde(tag = "type", deny_unknown_fields)]
pub enum ControlConfig {
    #[serde(rename = "flow")]
    Flow {
        label: String,
        flow: String,
        key: Option<String>,
        panel: Option<String>,
        section: Option<ControlSection>,
    },
    #[serde(rename = "cue")]
    Cue {
        label: String,
        sink: String,
        cue: String,
        release_cue: Option<String>,
        #[serde(default = "default_action_lifetime_ms")]
        expires_after_ms: u64,
        repeat_ms: Option<u64>,
        key: Option<String>,
        panel: Option<String>,
        section: Option<ControlSection>,
    },
}

#[derive(Debug, Clone, Copy, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum ControlSection {
    Show,
    Bench,
}

impl ControlSection {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Show => "show",
            Self::Bench => "bench",
        }
    }
}

#[derive(Debug, Clone, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct FlowConfig {
    pub trigger: TriggerConfig,
    #[serde(default)]
    pub role: FlowRole,
    #[serde(default)]
    pub nodes: Vec<NodeConfig>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct TriggerConfig {
    pub source: String,
    pub cue: String,
    /// Additional wire events that start the same flow. This keeps the
    /// choreography single-sourced while allowing a physical trigger and a
    /// legacy/operator trigger to coexist.
    #[serde(default)]
    pub aliases: Vec<String>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct NodeConfig {
    pub id: String,
    #[serde(default)]
    pub at_ms: u64,
    #[serde(default)]
    pub after: Vec<String>,
    /// Optional state transition in `prop.transition` form.
    pub transition: Option<String>,
    pub action: ActionConfig,
}

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Deserialize, Serialize)]
#[serde(rename_all = "kebab-case")]
pub enum FlowRole {
    #[default]
    Utility,
    Show,
    Reset,
    Stop,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct PropConfig {
    pub label: String,
    pub initial: String,
    pub ready: String,
    pub states: Vec<String>,
    #[serde(default)]
    pub transitions: BTreeMap<String, TransitionConfig>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct TransitionConfig {
    pub from: Vec<String>,
    pub active: String,
    pub to: String,
    pub failure: String,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(tag = "type", deny_unknown_fields)]
pub enum ActionConfig {
    #[serde(rename = "audio.play")]
    AudioPlay {
        sink: String,
        asset: String,
        /// Overrides the audio sink's default volume.
        volume: Option<f32>,
    },
    /// Low-latency playback through a resident, pre-warmed PCM channel.
    /// Intended for short interaction sounds such as the horn; normal music
    /// and dependency-aware tracks should continue to use `audio.play`.
    #[serde(rename = "audio.trigger")]
    AudioTrigger {
        sink: String,
        asset: String,
        /// Overrides the audio sink's default volume.
        volume: Option<f32>,
    },
    /// Starts or renews a named, resident audio voice. The clip plays from its
    /// beginning, then repeats the configured steady-state region until a
    /// matching stop arrives or the lease expires.
    #[serde(rename = "audio.hold.start")]
    AudioHoldStart {
        sink: String,
        asset: String,
        key: String,
        /// Overrides the audio sink's default volume.
        volume: Option<f32>,
        #[serde(default)]
        loop_start_ms: u64,
        loop_end_ms: Option<u64>,
        #[serde(default = "default_audio_hold_lease_ms")]
        lease_ms: u64,
    },
    /// Stops the named resident voice immediately. This is idempotent so a
    /// release arriving after lease expiry is harmless.
    #[serde(rename = "audio.hold.stop")]
    AudioHoldStop { key: String },
    #[serde(rename = "screen.command")]
    ScreenCommand {
        sink: String,
        command: EyeCommand,
        final_state: EyeSnapshot,
        #[serde(default = "default_action_lifetime_ms")]
        expires_after_ms: u64,
    },
    #[serde(rename = "cue.emit")]
    CueEmit {
        sink: String,
        cue: String,
        #[serde(default = "default_action_lifetime_ms")]
        expires_after_ms: u64,
        /// Physical application status, correlated to this command (not its ACK).
        wait_for: Option<String>,
        #[serde(default = "default_completion_timeout_ms")]
        timeout_ms: u64,
    },
}

#[derive(Debug, Clone, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct KioskConfig {
    #[serde(default)]
    pub enabled: bool,
    #[serde(default = "default_kiosk_browser")]
    pub browser: PathBuf,
    pub url: Option<String>,
    #[serde(default = "default_kiosk_log_file")]
    pub log_file: PathBuf,
    #[serde(default = "default_kiosk_pid_file")]
    pub pid_file: PathBuf,
}

impl Default for KioskConfig {
    fn default() -> Self {
        Self {
            enabled: false,
            browser: default_kiosk_browser(),
            url: None,
            log_file: default_kiosk_log_file(),
            pid_file: default_kiosk_pid_file(),
        }
    }
}

#[derive(Debug, Clone, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ServerConfig {
    pub bind: String,
    pub static_dir: PathBuf,
    pub screen_id: String,
}

impl ServerConfig {
    pub fn socket_addr(&self) -> Result<SocketAddr> {
        self.bind.parse::<SocketAddr>().map_err(|error| {
            FxError::ShowConfig(format!("invalid server.bind `{}`: {error}", self.bind))
        })
    }
}

#[derive(Debug, Clone, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct PlaybackConfig {
    #[serde(default = "default_max_active")]
    pub max_active: usize,
    #[serde(default = "default_dedupe_capacity")]
    pub dedupe_capacity: usize,
    /// Requested PipeWire latency for resident interaction channels.
    #[serde(default = "default_resident_latency_ms")]
    pub resident_latency_ms: u16,
}

impl Default for PlaybackConfig {
    fn default() -> Self {
        Self {
            max_active: default_max_active(),
            dedupe_capacity: default_dedupe_capacity(),
            resident_latency_ms: default_resident_latency_ms(),
        }
    }
}

pub fn load(path: &Path) -> Result<ShowConfig> {
    let contents = fs::read_to_string(path)?;
    let base = path.parent().unwrap_or_else(|| Path::new("."));
    parse(&contents, base)
}

pub fn load_active() -> Result<(PathBuf, ShowConfig)> {
    let path = active_show()?;
    let config = load(&path)?;
    Ok((path, config))
}

pub fn enable(path: &Path) -> Result<(PathBuf, ShowConfig)> {
    let canonical = fs::canonicalize(path)?;
    let config = load(&canonical)?;
    validate_files(&config)?;

    let active_path = active_show_pointer()?;
    if let Some(parent) = active_path.parent() {
        fs::create_dir_all(parent)?;
    }
    let temporary = active_path.with_extension("tmp");
    fs::write(&temporary, format!("{}\n", canonical.display()))?;
    fs::rename(temporary, active_path)?;
    Ok((canonical, config))
}

pub fn active_show() -> Result<PathBuf> {
    let pointer = active_show_pointer()?;
    let contents = fs::read_to_string(&pointer).map_err(|error| {
        if error.kind() == std::io::ErrorKind::NotFound {
            FxError::ShowConfig("no show is enabled; run `fx show enable <CONFIG>` first".into())
        } else {
            error.into()
        }
    })?;
    let path = PathBuf::from(contents.trim());
    if path.as_os_str().is_empty() {
        return Err(FxError::ShowConfig(format!(
            "{} is empty",
            pointer.display()
        )));
    }
    Ok(path)
}

pub fn validate_files(config: &ShowConfig) -> Result<()> {
    let mut missing = config
        .assets
        .values()
        .map(AssetConfig::audio_file)
        .filter(|file| !file.is_file())
        .map(|file| file.display().to_string())
        .collect::<Vec<_>>();
    if let Some(server) = &config.server {
        let index = server.static_dir.join("index.html");
        if !index.is_file() {
            missing.push(index.display().to_string());
        }
    }
    if missing.is_empty() {
        Ok(())
    } else {
        Err(FxError::ShowConfig(format!(
            "show file(s) not found: {}",
            missing.join(", ")
        )))
    }
}

fn parse(contents: &str, base: &Path) -> Result<ShowConfig> {
    let mut config = toml::from_str::<ShowConfig>(contents)
        .map_err(|error| FxError::ShowConfig(error.to_string()))?;
    for asset in config.assets.values_mut() {
        asset.resolve_relative_to(base);
    }
    if let Some(server) = &mut config.server
        && server.static_dir.is_relative()
    {
        server.static_dir = base.join(&server.static_dir);
    }
    validate(&config)?;
    Ok(config)
}

fn validate(config: &ShowConfig) -> Result<()> {
    if config.version != CONFIG_VERSION {
        return Err(FxError::ShowConfig(format!(
            "unsupported version {}; expected {CONFIG_VERSION}",
            config.version
        )));
    }
    require_name(&config.name, "show name")?;
    if config.flows.is_empty() {
        return Err(FxError::ShowConfig(
            "at least one flow must be configured".into(),
        ));
    }
    if config.playback.max_active == 0 || config.playback.dedupe_capacity == 0 {
        return Err(FxError::ShowConfig(
            "playback.max_active and playback.dedupe_capacity must be non-zero".into(),
        ));
    }
    if !(5..=100).contains(&config.playback.resident_latency_ms) {
        return Err(FxError::ShowConfig(
            "playback.resident_latency_ms must be between 5 and 100".into(),
        ));
    }

    validate_kiosk(config)?;

    for (name, link) in &config.links {
        require_name(name, "link name")?;
        if let Some((_, baud)) = link.serial()
            && baud == 0
        {
            return Err(FxError::ShowConfig(format!(
                "links.{name}.baud must be non-zero"
            )));
        }
        if let LinkConfig::MqttCue {
            host,
            port,
            node,
            client_id,
            topic_prefix,
            username,
            password_env,
        } = link
        {
            require_name(host, &format!("links.{name}.host"))?;
            require_name(node, &format!("links.{name}.node"))?;
            require_name(client_id, &format!("links.{name}.client_id"))?;
            require_name(topic_prefix, &format!("links.{name}.topic_prefix"))?;
            if *port == 0 {
                return Err(FxError::ShowConfig(format!(
                    "links.{name}.port must be non-zero"
                )));
            }
            if !is_node_id(node) {
                return Err(FxError::ShowConfig(format!(
                    "links.{name}.node must be a 12-digit hexadecimal node ID"
                )));
            }
            if username.is_some() != password_env.is_some() {
                return Err(FxError::ShowConfig(format!(
                    "links.{name}.username and password_env must be set together"
                )));
            }
        }
    }
    for (name, source) in &config.sources {
        require_name(name, "source name")?;
        require_reference(
            &config.links,
            source.link(),
            &format!("sources.{name}.link"),
        )?;
    }
    for (name, asset) in &config.assets {
        require_name(name, "asset name")?;
        if asset.audio_file().as_os_str().is_empty() {
            return Err(FxError::ShowConfig(format!(
                "assets.{name}.file must not be empty"
            )));
        }
    }

    let mut screen_ids = BTreeSet::new();
    for (name, sink) in &config.sinks {
        require_name(name, "sink name")?;
        match sink {
            SinkConfig::Audio { device, volume } => {
                require_name(device, &format!("sinks.{name}.device"))?;
                validate_volume(*volume, &format!("sinks.{name}.volume"))?;
            }
            SinkConfig::Screen {
                screen_id,
                initial_state,
            } => {
                require_name(screen_id, &format!("sinks.{name}.screen_id"))?;
                if !screen_ids.insert(screen_id.as_str()) {
                    return Err(FxError::ShowConfig(format!(
                        "duplicate screen id `{screen_id}`"
                    )));
                }
                initial_state.validate()?;
            }
            SinkConfig::Cue {
                link,
                target,
                namespace,
            } => {
                require_reference(&config.links, link, &format!("sinks.{name}.link"))?;
                require_name(target, &format!("sinks.{name}.target"))?;
                if matches!(config.links[link], LinkConfig::MqttCue { .. }) && !is_node_id(target) {
                    return Err(FxError::ShowConfig(format!(
                        "sinks.{name}.target must be a 12-digit hexadecimal node ID for MQTT"
                    )));
                }
                if namespace.len() >= MAX_CUE_NAME_BYTES {
                    return Err(FxError::ShowConfig(format!(
                        "sinks.{name}.namespace is too long"
                    )));
                }
            }
        }
    }

    validate_server(config, &screen_ids)?;
    validate_props(config)?;
    for (flow_name, flow) in &config.flows {
        validate_flow(config, flow_name, flow)?;
    }
    let mut control_keys = BTreeMap::new();
    for (control_name, control) in &config.controls {
        validate_control(config, control_name, control)?;
        let key = match control {
            ControlConfig::Flow { key, .. } | ControlConfig::Cue { key, .. } => key,
        };
        if let Some(key) = key {
            let normalized = key.to_lowercase();
            if let Some(previous) = control_keys.insert(normalized, control_name) {
                return Err(FxError::ShowConfig(format!(
                    "controls.{control_name}.key duplicates controls.{previous}.key"
                )));
            }
        }
    }
    Ok(())
}

fn validate_props(config: &ShowConfig) -> Result<()> {
    for (prop_name, prop) in &config.props {
        require_name(prop_name, "prop name")?;
        require_name(&prop.label, &format!("props.{prop_name}.label"))?;
        if prop.states.is_empty() {
            return Err(FxError::ShowConfig(format!(
                "props.{prop_name}.states must not be empty"
            )));
        }
        let mut states = BTreeSet::new();
        for state in &prop.states {
            require_name(state, &format!("props.{prop_name}.states"))?;
            if !states.insert(state.as_str()) {
                return Err(FxError::ShowConfig(format!(
                    "props.{prop_name}.states contains duplicate `{state}`"
                )));
            }
        }
        for (field, state) in [("initial", &prop.initial), ("ready", &prop.ready)] {
            if !states.contains(state.as_str()) {
                return Err(FxError::ShowConfig(format!(
                    "props.{prop_name}.{field} references unknown state `{state}`"
                )));
            }
        }
        for (transition_name, transition) in &prop.transitions {
            require_name(transition_name, "transition name")?;
            if transition.from.is_empty() {
                return Err(FxError::ShowConfig(format!(
                    "props.{prop_name}.transitions.{transition_name}.from must not be empty"
                )));
            }
            for state in transition.from.iter().chain([
                &transition.active,
                &transition.to,
                &transition.failure,
            ]) {
                if !states.contains(state.as_str()) {
                    return Err(FxError::ShowConfig(format!(
                        "props.{prop_name}.transitions.{transition_name} references unknown state `{state}`"
                    )));
                }
            }
        }
    }
    Ok(())
}

fn validate_control(config: &ShowConfig, name: &str, control: &ControlConfig) -> Result<()> {
    require_name(name, "control name")?;
    match control {
        ControlConfig::Flow {
            label, flow, key, ..
        } => {
            require_name(label, &format!("controls.{name}.label"))?;
            require_reference(&config.flows, flow, &format!("controls.{name}.flow"))?;
            validate_control_key(key.as_deref(), name)
        }
        ControlConfig::Cue {
            label,
            sink,
            cue,
            release_cue,
            expires_after_ms,
            repeat_ms,
            key,
            ..
        } => {
            require_name(label, &format!("controls.{name}.label"))?;
            let namespace = match config.sinks.get(sink) {
                Some(SinkConfig::Cue { namespace, .. }) => namespace,
                Some(_) => {
                    return Err(wrong_sink_type(&format!("controls.{name}"), sink, "cue"));
                }
                None => return Err(unknown_reference(&format!("controls.{name}.sink"), sink)),
            };
            validate_cue_name(
                &qualified_cue(namespace, cue),
                &format!("controls.{name}.cue"),
            )?;
            if let Some(release_cue) = release_cue {
                validate_cue_name(
                    &qualified_cue(namespace, release_cue),
                    &format!("controls.{name}.release_cue"),
                )?;
            }
            validate_lifetime(*expires_after_ms, &format!("controls.{name}"))?;
            if repeat_ms.is_some_and(|repeat| !(50..=5_000).contains(&repeat)) {
                return Err(FxError::ShowConfig(format!(
                    "controls.{name}.repeat_ms must be between 50 and 5000"
                )));
            }
            if repeat_ms.is_some() && release_cue.is_none() {
                return Err(FxError::ShowConfig(format!(
                    "controls.{name}.repeat_ms requires release_cue"
                )));
            }
            validate_control_key(key.as_deref(), name)
        }
    }
}

fn validate_control_key(key: Option<&str>, control: &str) -> Result<()> {
    if key.is_some_and(|value| value.trim().is_empty() || value.len() > 32) {
        return Err(FxError::ShowConfig(format!(
            "controls.{control}.key must contain between 1 and 32 bytes"
        )));
    }
    Ok(())
}

fn validate_kiosk(config: &ShowConfig) -> Result<()> {
    if config.kiosk.browser.as_os_str().is_empty()
        || config.kiosk.log_file.as_os_str().is_empty()
        || config.kiosk.pid_file.as_os_str().is_empty()
    {
        return Err(FxError::ShowConfig(
            "kiosk.browser, kiosk.log_file, and kiosk.pid_file must not be empty".into(),
        ));
    }
    if config.kiosk.enabled && config.kiosk.url.is_none() && config.server.is_none() {
        return Err(FxError::ShowConfig(
            "enabled kiosk requires kiosk.url or a [server] section".into(),
        ));
    }
    if let Some(url) = &config.kiosk.url
        && !url.starts_with("http://")
        && !url.starts_with("https://")
    {
        return Err(FxError::ShowConfig(
            "kiosk.url must begin with http:// or https://".into(),
        ));
    }
    Ok(())
}

fn validate_server(config: &ShowConfig, screen_ids: &BTreeSet<&str>) -> Result<()> {
    if let Some(server) = &config.server {
        server.socket_addr()?;
        if server.static_dir.as_os_str().is_empty() {
            return Err(FxError::ShowConfig(
                "server.static_dir must not be empty".into(),
            ));
        }
        if !screen_ids.contains(server.screen_id.as_str()) {
            return Err(FxError::ShowConfig(format!(
                "server.screen_id references unknown screen `{}`",
                server.screen_id
            )));
        }
    } else if !screen_ids.is_empty() {
        return Err(FxError::ShowConfig(
            "screen sinks require a [server] section".into(),
        ));
    }
    Ok(())
}

fn validate_flow(config: &ShowConfig, flow_name: &str, flow: &FlowConfig) -> Result<()> {
    require_name(flow_name, "flow name")?;
    require_reference(
        &config.sources,
        &flow.trigger.source,
        &format!("flows.{flow_name}.trigger.source"),
    )?;
    validate_cue_name(&flow.trigger.cue, &format!("flows.{flow_name}.trigger.cue"))?;
    let mut trigger_cues = BTreeSet::from([flow.trigger.cue.as_str()]);
    for (index, alias) in flow.trigger.aliases.iter().enumerate() {
        validate_cue_name(
            alias,
            &format!("flows.{flow_name}.trigger.aliases[{index}]"),
        )?;
        if !trigger_cues.insert(alias) {
            return Err(FxError::ShowConfig(format!(
                "flows.{flow_name}.trigger contains duplicate cue `{alias}`"
            )));
        }
    }
    if flow.nodes.is_empty() {
        return Err(FxError::ShowConfig(format!(
            "flows.{flow_name} must contain at least one node"
        )));
    }
    let mut node_ids = BTreeSet::new();
    for (index, node) in flow.nodes.iter().enumerate() {
        require_name(&node.id, &format!("flows.{flow_name}.nodes[{index}].id"))?;
        if !node_ids.insert(node.id.as_str()) {
            return Err(FxError::ShowConfig(format!(
                "flows.{flow_name} contains duplicate node id `{}`",
                node.id
            )));
        }
        validate_action(config, flow_name, node)?;
        if let Some(reference) = &node.transition {
            let Some((prop, transition)) = reference.split_once('.') else {
                return Err(FxError::ShowConfig(format!(
                    "flows.{flow_name}.nodes.{}.transition must use prop.transition form",
                    node.id
                )));
            };
            if prop.is_empty() || transition.is_empty() || transition.contains('.') {
                return Err(FxError::ShowConfig(format!(
                    "flows.{flow_name}.nodes.{}.transition must use prop.transition form",
                    node.id
                )));
            }
            let Some(prop_config) = config.props.get(prop) else {
                return Err(unknown_reference(
                    &format!("flows.{flow_name}.nodes.{}.transition prop", node.id),
                    prop,
                ));
            };
            if !prop_config.transitions.contains_key(transition) {
                return Err(unknown_reference(
                    &format!("flows.{flow_name}.nodes.{}.transition", node.id),
                    reference,
                ));
            }
        }
    }
    let mut resolved = BTreeSet::new();
    for node in &flow.nodes {
        let mut unique = BTreeSet::new();
        for dependency in &node.after {
            if !node_ids.contains(dependency.as_str())
                || dependency == &node.id
                || !unique.insert(dependency)
            {
                return Err(FxError::ShowConfig(format!(
                    "invalid dependency `{dependency}` on {flow_name}/{}",
                    node.id
                )));
            }
        }
    }
    loop {
        let before = resolved.len();
        for node in &flow.nodes {
            if node.after.iter().all(|id| resolved.contains(id.as_str())) {
                resolved.insert(node.id.as_str());
            }
        }
        if resolved.len() == flow.nodes.len() {
            break;
        }
        if resolved.len() == before {
            return Err(FxError::ShowConfig(format!(
                "flow `{flow_name}` contains a dependency cycle"
            )));
        }
    }
    Ok(())
}

fn validate_action(config: &ShowConfig, flow_name: &str, node: &NodeConfig) -> Result<()> {
    let field = format!("flows.{flow_name}.nodes.{}.action", node.id);
    match &node.action {
        ActionConfig::AudioPlay {
            sink,
            asset,
            volume,
        }
        | ActionConfig::AudioTrigger {
            sink,
            asset,
            volume,
        } => {
            match config.sinks.get(sink) {
                Some(SinkConfig::Audio { .. }) => {}
                Some(_) => return Err(wrong_sink_type(&field, sink, "audio")),
                None => return Err(unknown_reference(&format!("{field}.sink"), sink)),
            }
            match config.assets.get(asset) {
                Some(AssetConfig::Audio { .. }) => {}
                None => return Err(unknown_reference(&format!("{field}.asset"), asset)),
            }
            validate_volume(*volume, &format!("{field}.volume"))?;
        }
        ActionConfig::AudioHoldStart {
            sink,
            asset,
            key,
            volume,
            loop_start_ms,
            loop_end_ms,
            lease_ms,
        } => {
            match config.sinks.get(sink) {
                Some(SinkConfig::Audio { .. }) => {}
                Some(_) => return Err(wrong_sink_type(&field, sink, "audio")),
                None => return Err(unknown_reference(&format!("{field}.sink"), sink)),
            }
            match config.assets.get(asset) {
                Some(AssetConfig::Audio { .. }) => {}
                None => return Err(unknown_reference(&format!("{field}.asset"), asset)),
            }
            validate_audio_hold_key(key, &format!("{field}.key"))?;
            validate_volume(*volume, &format!("{field}.volume"))?;
            if !(250..=10_000).contains(lease_ms) {
                return Err(FxError::ShowConfig(format!(
                    "{field}.lease_ms must be between 250 and 10000"
                )));
            }
            if loop_end_ms.is_some_and(|end| end <= *loop_start_ms) {
                return Err(FxError::ShowConfig(format!(
                    "{field}.loop_end_ms must be greater than loop_start_ms"
                )));
            }
        }
        ActionConfig::AudioHoldStop { key } => {
            validate_audio_hold_key(key, &format!("{field}.key"))?;
        }
        ActionConfig::ScreenCommand {
            sink,
            command,
            final_state,
            expires_after_ms,
        } => {
            match config.sinks.get(sink) {
                Some(SinkConfig::Screen { .. }) => {}
                Some(_) => return Err(wrong_sink_type(&field, sink, "screen")),
                None => return Err(unknown_reference(&format!("{field}.sink"), sink)),
            }
            validate_lifetime(*expires_after_ms, &field)?;
            command.validate()?;
            final_state.validate()?;
        }
        ActionConfig::CueEmit {
            sink,
            cue,
            expires_after_ms,
            wait_for,
            timeout_ms,
        } => {
            let namespace = match config.sinks.get(sink) {
                Some(SinkConfig::Cue { namespace, .. }) => namespace,
                Some(_) => return Err(wrong_sink_type(&field, sink, "cue")),
                None => return Err(unknown_reference(&format!("{field}.sink"), sink)),
            };
            validate_lifetime(*expires_after_ms, &field)?;
            validate_cue_name(&qualified_cue(namespace, cue), &format!("{field}.cue"))?;
            if let Some(event) = wait_for {
                // Status wire names reserve 17 bytes for :<16-hex-command-id>.
                if event.is_empty() || event.len() > 14 || !(1..=600_000).contains(timeout_ms) {
                    return Err(FxError::ShowConfig(format!(
                        "{field}: wait_for must be 1–14 bytes and timeout_ms 1–600000"
                    )));
                }
            }
        }
    }
    Ok(())
}

fn default_completion_timeout_ms() -> u64 {
    10_000
}

pub fn qualified_cue(namespace: &str, cue: &str) -> String {
    if namespace.is_empty() {
        cue.to_string()
    } else {
        format!("{namespace}:{cue}")
    }
}

fn require_name(value: &str, field: &str) -> Result<()> {
    if value.trim().is_empty() {
        Err(FxError::ShowConfig(format!("{field} must not be empty")))
    } else {
        Ok(())
    }
}

fn require_reference<T>(items: &BTreeMap<String, T>, value: &str, field: &str) -> Result<()> {
    if items.contains_key(value) {
        Ok(())
    } else {
        Err(unknown_reference(field, value))
    }
}

fn unknown_reference(field: &str, value: &str) -> FxError {
    FxError::ShowConfig(format!("{field} references unknown `{value}`"))
}

fn wrong_sink_type(field: &str, sink: &str, expected: &str) -> FxError {
    FxError::ShowConfig(format!("{field} requires {expected} sink `{sink}`"))
}

fn validate_cue_name(cue: &str, field: &str) -> Result<()> {
    if cue.trim().is_empty() || cue.len() > MAX_CUE_NAME_BYTES {
        Err(FxError::ShowConfig(format!(
            "{field} must be 1..={MAX_CUE_NAME_BYTES} bytes"
        )))
    } else {
        Ok(())
    }
}

fn validate_lifetime(lifetime: u64, field: &str) -> Result<()> {
    if lifetime == 0 || lifetime > 60_000 {
        Err(FxError::ShowConfig(format!(
            "{field}.expires_after_ms must be between 1 and 60000"
        )))
    } else {
        Ok(())
    }
}

fn validate_volume(volume: Option<f32>, field: &str) -> Result<()> {
    if volume.is_some_and(|volume| !(0.0..=1.0).contains(&volume)) {
        Err(FxError::ShowConfig(format!(
            "{field} must be between 0.0 and 1.0"
        )))
    } else {
        Ok(())
    }
}

fn validate_audio_hold_key(key: &str, field: &str) -> Result<()> {
    if key.trim().is_empty() || key.len() > 64 {
        Err(FxError::ShowConfig(format!("{field} must be 1..=64 bytes")))
    } else {
        Ok(())
    }
}

fn active_show_pointer() -> Result<PathBuf> {
    if let Some(directory) = env::var_os("XDG_CONFIG_HOME").filter(|value| !value.is_empty()) {
        return Ok(PathBuf::from(directory).join("fx").join(ACTIVE_SHOW_FILE));
    }
    if let Some(directory) = env::var_os("HOME").filter(|value| !value.is_empty()) {
        return Ok(PathBuf::from(directory)
            .join(".config/fx")
            .join(ACTIVE_SHOW_FILE));
    }
    Err(FxError::ShowConfig(
        "neither XDG_CONFIG_HOME nor HOME is set".into(),
    ))
}

const fn default_baud() -> u32 {
    115_200
}
const fn default_mqtt_port() -> u16 {
    1883
}
fn default_mqtt_client_id() -> String {
    "fx-show".into()
}
fn default_mqtt_topic_prefix() -> String {
    "halloween".into()
}

fn is_node_id(value: &str) -> bool {
    value.len() == 12 && value.bytes().all(|byte| byte.is_ascii_hexdigit())
}
const fn default_max_active() -> usize {
    16
}

const fn default_resident_latency_ms() -> u16 {
    20
}
const fn default_dedupe_capacity() -> usize {
    4096
}
const fn default_action_lifetime_ms() -> u64 {
    2_000
}

const fn default_audio_hold_lease_ms() -> u64 {
    1_200
}

fn default_kiosk_browser() -> PathBuf {
    "chromium".into()
}

fn default_kiosk_log_file() -> PathBuf {
    crate::kiosk::DEFAULT_LOG_FILE.into()
}

fn default_kiosk_pid_file() -> PathBuf {
    crate::kiosk::DEFAULT_PID_FILE.into()
}

#[cfg(test)]
mod tests {
    use super::*;

    const VALID: &str = r#"
version = 2
name = "tractor-test"

[links.radio]
type = "serial-cue"

[sources.radio]
type = "cue-link"
link = "radio"

[assets.tip]
type = "audio"
file = "audio/tip.wav"

[sinks.speaker]
type = "audio"
device = "jbl"
volume = 0.7

[sinks.motor]
type = "cue"
link = "radio"
target = "AABBCCDDEEFF"
namespace = "tractor:stepper"

[flows.tip]
trigger = { source = "radio", cue = "tractor:tipped" }

[[flows.tip.nodes]]
id = "sound"
action = { type = "audio.play", sink = "speaker", asset = "tip" }

[[flows.tip.nodes]]
id = "stroke"
at_ms = 8500
action = { type = "cue.emit", sink = "motor", cue = "stroke", expires_after_ms = 500 }

[controls.tip]
type = "flow"
label = "Run tractor tip"
flow = "tip"

[controls.stepper]
type = "cue"
label = "Stepper stroke"
sink = "motor"
cue = "stroke"
"#;

    #[test]
    fn accepts_a_complete_manifest_and_resolves_asset_paths() {
        let config = parse(VALID, Path::new("/shows")).unwrap();
        assert_eq!(
            config.assets["tip"].audio_file(),
            Path::new("/shows/audio/tip.wav")
        );
    }

    #[test]
    fn rejects_unknown_edges_and_wrong_sink_types() {
        let unknown = VALID.replace("sink = \"motor\"", "sink = \"missing\"");
        assert!(parse(&unknown, Path::new("/shows")).is_err());

        let wrong_type = VALID.replace("sink = \"motor\"", "sink = \"speaker\"");
        assert!(parse(&wrong_type, Path::new("/shows")).is_err());
    }

    #[test]
    fn rejects_duplicate_node_ids_and_oversized_wire_cues() {
        let duplicate = VALID.replace("id = \"stroke\"", "id = \"sound\"");
        assert!(parse(&duplicate, Path::new("/shows")).is_err());

        let too_long = VALID.replace(
            "cue = \"stroke\"",
            "cue = \"this-name-is-far-too-long-for-the-wire\"",
        );
        assert!(parse(&too_long, Path::new("/shows")).is_err());
    }

    #[test]
    fn rejects_unknown_fields_instead_of_silently_ignoring_typos() {
        let invalid = VALID.replace("name = \"tractor-test\"", "name = \"x\"\ntyop = 1");
        assert!(parse(&invalid, Path::new("/shows")).is_err());
    }

    #[test]
    fn validates_dag_edges_and_rejects_cycles_and_unknown_dependencies() {
        let valid = VALID.replace("id = \"stroke\"", "id = \"stroke\"\nafter = [\"sound\"]");
        assert!(parse(&valid, Path::new("/shows")).is_ok());
        let cycle = valid.replace("id = \"sound\"", "id = \"sound\"\nafter = [\"stroke\"]");
        assert!(parse(&cycle, Path::new("/shows")).is_err());
        assert!(
            parse(
                &valid.replace("after = [\"sound\"]", "after = [\"missing\"]"),
                Path::new("/shows")
            )
            .is_err()
        );
    }

    #[test]
    fn checked_in_show_manifests_match_the_public_schema() {
        for manifest in [
            include_str!("../shows/tractor-bluetooth.toml"),
            include_str!("../shows/tractor-usb.toml"),
            include_str!("../../sync/shows/integration-sim.toml"),
            include_str!("../../sync/shows/integration-hardware.toml"),
            include_str!("../../sync/shows/integration-mqtt.toml"),
        ] {
            parse(manifest, Path::new("/shows")).unwrap();
        }
    }

    #[test]
    fn installed_stepper_direction_mapping_stays_calibrated() {
        for manifest in [
            include_str!("../../sync/shows/integration-sim.toml"),
            include_str!("../../sync/shows/integration-hardware.toml"),
            include_str!("../../sync/shows/integration-mqtt.toml"),
        ] {
            let show = parse(manifest, Path::new("/shows")).unwrap();
            for (control, expected) in [
                ("stepper_stroke", "step:rev:1600:60"),
                ("stepper_position_cw", "step:jog:fwd:30"),
                ("stepper_position_ccw", "step:jog:rev:30"),
            ] {
                assert!(matches!(
                    &show.controls[control],
                    ControlConfig::Cue { cue, .. } if cue == expected
                ));
            }
            assert!(show.flows["integration"].nodes.iter().any(|node| {
                node.id == "stepper-turn"
                    && matches!(
                        &node.action,
                        ActionConfig::CueEmit { cue, .. } if cue == "step:rev:1600:60"
                    )
            }));
        }
    }
}
