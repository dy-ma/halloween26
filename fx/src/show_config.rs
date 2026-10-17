use std::{
    collections::{BTreeMap, BTreeSet},
    env, fs,
    net::SocketAddr,
    path::{Path, PathBuf},
};

use fx_audio::{FxError, Result};
use serde::Deserialize;

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
    pub flows: BTreeMap<String, FlowConfig>,
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
}

impl LinkConfig {
    pub fn serial(&self) -> (Option<PathBuf>, u32) {
        match self {
            Self::SerialCue { port, baud } => (port.clone(), *baud),
        }
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
        #[serde(default)]
        namespace: String,
    },
}

#[derive(Debug, Clone, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct FlowConfig {
    pub trigger: TriggerConfig,
    #[serde(default)]
    pub nodes: Vec<NodeConfig>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct TriggerConfig {
    pub source: String,
    pub cue: String,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct NodeConfig {
    pub id: String,
    #[serde(default)]
    pub at_ms: u64,
    pub action: ActionConfig,
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
}

impl Default for PlaybackConfig {
    fn default() -> Self {
        Self {
            max_active: default_max_active(),
            dedupe_capacity: default_dedupe_capacity(),
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

    validate_kiosk(config)?;

    for (name, link) in &config.links {
        require_name(name, "link name")?;
        let (_, baud) = link.serial();
        if baud == 0 {
            return Err(FxError::ShowConfig(format!(
                "links.{name}.baud must be non-zero"
            )));
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
            SinkConfig::Cue { link, namespace } => {
                require_reference(&config.links, link, &format!("sinks.{name}.link"))?;
                if namespace.len() >= MAX_CUE_NAME_BYTES {
                    return Err(FxError::ShowConfig(format!(
                        "sinks.{name}.namespace is too long"
                    )));
                }
            }
        }
    }

    validate_server(config, &screen_ids)?;
    for (flow_name, flow) in &config.flows {
        validate_flow(config, flow_name, flow)?;
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
        } => {
            let namespace = match config.sinks.get(sink) {
                Some(SinkConfig::Cue { namespace, .. }) => namespace,
                Some(_) => return Err(wrong_sink_type(&field, sink, "cue")),
                None => return Err(unknown_reference(&format!("{field}.sink"), sink)),
            };
            validate_lifetime(*expires_after_ms, &field)?;
            validate_cue_name(&qualified_cue(namespace, cue), &format!("{field}.cue"))?;
        }
    }
    Ok(())
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
const fn default_max_active() -> usize {
    16
}
const fn default_dedupe_capacity() -> usize {
    4096
}
const fn default_action_lifetime_ms() -> u64 {
    2_000
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
    fn checked_in_show_manifests_match_the_public_schema() {
        for manifest in [
            include_str!("../shows/tractor-bluetooth.toml"),
            include_str!("../shows/tractor-usb.toml"),
        ] {
            parse(manifest, Path::new("/shows")).unwrap();
        }
    }
}
