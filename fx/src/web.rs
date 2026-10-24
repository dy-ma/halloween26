use std::{
    collections::BTreeMap,
    net::SocketAddr,
    path::PathBuf,
    process::Command,
    sync::{Arc, Mutex},
    time::{Duration, Instant, SystemTime, UNIX_EPOCH},
};

use axum::{
    Json, Router,
    extract::{
        DefaultBodyLimit, Path as AxumPath, Query, State, WebSocketUpgrade,
        ws::{CloseFrame, Message, WebSocket},
    },
    http::{
        HeaderMap, StatusCode,
        header::{CACHE_CONTROL, CONTENT_TYPE, HOST, ORIGIN, USER_AGENT},
    },
    response::{IntoResponse, Response},
    routing::{any, get},
};
use futures_util::{SinkExt, StreamExt};
use serde::{Deserialize, Serialize};
use tokio::{
    net::TcpListener,
    sync::{broadcast, mpsc, oneshot},
    time::timeout,
};
use tower_http::services::{ServeDir, ServeFile};

use crate::screen::{ScreenHub, ScreenSubscription};

const MAX_FRAME_BYTES: usize = 8 * 1024;

#[derive(Clone)]
struct WebState {
    hub: ScreenHub,
    configured_screen_id: String,
    control: ControlState,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct ControlDefinition {
    pub id: String,
    pub label: String,
    pub kind: &'static str,
    pub repeat_ms: Option<u64>,
    /// Configured PWM duty for adjustable DC jog controls (1..=255).
    pub pwm: Option<u8>,
    /// Configured RPM for adjustable finite stepper controls.
    pub rpm: Option<u16>,
    pub stroke_steps: Option<u32>,
    /// Current MQTT stepper planner; unknown on legacy transports.
    pub stroke_profile: Option<&'static str>,
    pub key: Option<String>,
    pub group: Option<String>,
    pub panel: String,
    pub target: Option<String>,
    pub section: &'static str,
    pub role: crate::show_config::FlowRole,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct AudioOutputDefinition {
    pub id: String,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct ControlManifest {
    pub show: String,
    pub runtime_instance: u32,
    pub reload_available: bool,
    pub controls: Vec<ControlDefinition>,
    pub audio_outputs: Vec<AudioOutputDefinition>,
}

#[derive(Clone)]
pub struct ControlState {
    pub manifest: ControlManifest,
    pub sender: mpsc::Sender<ControlRequest>,
    pub volume_sender: mpsc::Sender<VolumeRequest>,
    pub reload_sender: Option<mpsc::Sender<()>>,
    pub boards: BoardRegistry,
    pub workflows: crate::workflow::WorkflowHub,
    pub system: SystemRegistry,
}

#[derive(Clone)]
pub struct SystemRegistry {
    started_at: Instant,
    started_at_ms: u64,
    hostname: String,
    broker_restart_available: bool,
    links: Arc<Mutex<Vec<LinkRecord>>>,
}

#[derive(Clone)]
struct LinkRecord {
    id: String,
    transport: String,
    endpoint: String,
    monitor: crate::cue_link::LinkMonitor,
}

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
struct SystemStatus {
    started_at_ms: u64,
    uptime_ms: u64,
    hostname: String,
    wifi_ssid: Option<String>,
    broker_restart_available: bool,
    links: Vec<LinkStatus>,
    battery_percent: Option<u8>,
}

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
struct LinkStatus {
    id: String,
    transport: String,
    endpoint: String,
    connected: bool,
}

impl Default for SystemRegistry {
    fn default() -> Self {
        Self::new()
    }
}

impl SystemRegistry {
    pub fn new() -> Self {
        let started_at_ms = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_millis()
            .min(u64::MAX as u128) as u64;
        Self {
            started_at: Instant::now(),
            started_at_ms,
            hostname: hostname(),
            broker_restart_available: broker_restart_available(),
            links: Arc::new(Mutex::new(Vec::new())),
        }
    }

    pub fn register(
        &self,
        id: &str,
        transport: &str,
        endpoint: String,
        monitor: crate::cue_link::LinkMonitor,
    ) {
        self.links
            .lock()
            .expect("system links mutex")
            .push(LinkRecord {
                id: id.into(),
                transport: transport.into(),
                endpoint,
                monitor,
            });
    }

    fn snapshot(&self) -> SystemStatus {
        SystemStatus {
            started_at_ms: self.started_at_ms,
            uptime_ms: self.started_at.elapsed().as_millis().min(u64::MAX as u128) as u64,
            hostname: self.hostname.clone(),
            wifi_ssid: wifi_ssid(),
            broker_restart_available: self.broker_restart_available,
            links: self
                .links
                .lock()
                .expect("system links mutex")
                .iter()
                .map(|link| LinkStatus {
                    id: link.id.clone(),
                    transport: link.transport.clone(),
                    endpoint: link.endpoint.clone(),
                    connected: link.monitor.is_connected(),
                })
                .collect(),
            // No configured board currently reports measured battery charge.
            // Keep this explicit so future fuel-gauge telemetry has a stable API.
            battery_percent: None,
        }
    }
}

fn command_line(program: &str, arguments: &[&str]) -> Option<String> {
    let output = Command::new(program).args(arguments).output().ok()?;
    if !output.status.success() {
        return None;
    }
    let value = String::from_utf8(output.stdout).ok()?.trim().to_string();
    (!value.is_empty()).then_some(value)
}

fn hostname() -> String {
    std::env::var("HOSTNAME")
        .ok()
        .filter(|value| !value.trim().is_empty())
        .or_else(|| command_line("hostname", &[]))
        .unwrap_or_else(|| "unknown".into())
}

fn wifi_ssid() -> Option<String> {
    if !cfg!(target_os = "linux") {
        return None;
    }
    command_line("iwgetid", &["--raw"]).or_else(|| {
        command_line("nmcli", &["-t", "-f", "active,ssid", "dev", "wifi"]).and_then(|output| {
            output.lines().find_map(|line| {
                line.strip_prefix("yes:")
                    .filter(|ssid| !ssid.is_empty())
                    .map(str::to_string)
            })
        })
    })
}

fn broker_restart_available() -> bool {
    if !cfg!(target_os = "linux") {
        return false;
    }
    Command::new("pkcheck")
        .args([
            "--action-id",
            "org.freedesktop.systemd1.manage-units",
            "--process",
            &std::process::id().to_string(),
            "--detail",
            "unit",
            "mosquitto.service",
            "--detail",
            "verb",
            "restart",
        ])
        .status()
        .is_ok_and(|status| status.success())
}

#[derive(Clone, Default)]
pub struct BoardRegistry {
    boards: Arc<Mutex<BTreeMap<(String, String), BoardRecord>>>,
}

struct BoardRecord {
    node: String,
    service: String,
    link: String,
    transport: String,
    rssi: Option<i64>,
    last_seen: Instant,
}

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
struct BoardStatus {
    node: String,
    service: String,
    link: String,
    transport: String,
    rssi: Option<i64>,
    online: bool,
}

#[derive(Serialize)]
struct BoardList {
    boards: Vec<BoardStatus>,
}

impl BoardRegistry {
    pub fn record(
        &self,
        link: &str,
        node: &str,
        service: &str,
        transport: &str,
        rssi: Option<i64>,
    ) {
        let record = BoardRecord {
            node: node.to_string(),
            service: service.to_string(),
            link: link.to_string(),
            transport: transport.to_string(),
            rssi,
            last_seen: Instant::now(),
        };
        if let Ok(mut boards) = self.boards.lock() {
            boards.insert((link.to_string(), node.to_string()), record);
        }
    }

    fn snapshot(&self) -> Vec<BoardStatus> {
        let Ok(boards) = self.boards.lock() else {
            return Vec::new();
        };
        boards
            .values()
            .map(|board| BoardStatus {
                node: board.node.clone(),
                service: board.service.clone(),
                link: board.link.clone(),
                transport: board.transport.clone(),
                rssi: board.rssi,
                online: board.transport == "simulated"
                    || board.last_seen.elapsed() <= Duration::from_millis(3_500),
            })
            .collect()
    }
}

#[derive(Debug, Clone, Copy, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum ControlPhase {
    Press,
    Release,
}

#[derive(Debug, Clone, Copy, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum DcDirection {
    Forward,
    Reverse,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct DcProfileAudio {
    pub track: String,
    pub output: String,
    pub motor_delay_ms: u32,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct DcProfileEye {
    /// Saved browser identity, not the short-lived WebSocket connection ID.
    pub device_id: String,
    pub wake_delay_ms: u32,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct PlaybackStepper {
    pub control: String,
    pub rpm: u16,
    pub delay_ms: u32,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct DcProfileInput {
    #[serde(default = "default_motor_enabled")]
    pub motor_enabled: bool,
    pub motor_delay_ms: Option<u32>,
    pub direction: DcDirection,
    pub peak_pwm_percent: u8,
    pub minimum_pwm_percent: u8,
    pub ramp_ms: u32,
    pub hold_ms: u32,
    pub fade_ms: u32,
    pub audio: Option<DcProfileAudio>,
    pub eye: Option<DcProfileEye>,
    pub stepper: Option<PlaybackStepper>,
}

fn default_motor_enabled() -> bool {
    true
}

#[derive(Debug)]
pub struct ControlRequest {
    pub id: String,
    pub phase: ControlPhase,
    pub pwm: Option<u8>,
    pub rpm: Option<u16>,
    pub dc_profile: Option<DcProfileInput>,
    pub response: oneshot::Sender<std::result::Result<(), String>>,
}

#[derive(Debug)]
pub struct VolumeRequest {
    pub id: String,
    pub percent: Option<u8>,
    pub response: oneshot::Sender<std::result::Result<VolumeStatus, String>>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct VolumeStatus {
    pub id: String,
    pub percent: u8,
    pub muted: bool,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
struct ControlBody {
    control: String,
    phase: ControlPhase,
    pwm: Option<u8>,
    rpm: Option<u16>,
    dc_profile: Option<DcProfileInput>,
}

#[derive(Debug, Deserialize)]
#[serde(deny_unknown_fields)]
struct VolumeBody {
    percent: u8,
}

#[derive(Deserialize)]
#[serde(tag = "type", rename_all = "snake_case", deny_unknown_fields)]
enum AudioBody {
    Play {
        track: String,
        output: String,
        volume: Option<f32>,
    },
    Stop {
        playback: String,
    },
    Volume {
        output: String,
        percent: u8,
    },
    Connect {
        output: String,
    },
    Disconnect {
        output: String,
    },
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct RuntimeConfig<'a> {
    screen_id: String,
    websocket: WebSocketConfig<'a>,
}

#[derive(Serialize)]
struct WebSocketConfig<'a> {
    enabled: bool,
    url: &'a str,
}

#[derive(Debug, Deserialize)]
#[serde(tag = "type", deny_unknown_fields)]
enum ClientMessage {
    #[serde(rename = "hello")]
    Hello {
        v: u8,
        #[serde(rename = "screenId")]
        screen_id: String,
        #[serde(default, rename = "clientId")]
        client_id: Option<String>,
        #[serde(default, rename = "clientName")]
        client_name: Option<String>,
    },
    #[serde(rename = "ping")]
    Ping { v: u8, id: String },
    #[serde(rename = "applied")]
    Applied {
        v: u8,
        #[serde(rename = "sessionId")]
        session_id: String,
        seq: u64,
    },
}

pub async fn serve(
    bind: SocketAddr,
    static_dir: PathBuf,
    screen_id: String,
    hub: ScreenHub,
    control: ControlState,
) -> std::io::Result<()> {
    let listener = TcpListener::bind(bind).await?;
    crate::fx_log!("eye server listening on http://{bind}/");
    axum::serve(listener, app(static_dir, screen_id, hub, control)).await
}

fn app(static_dir: PathBuf, screen_id: String, hub: ScreenHub, control: ControlState) -> Router {
    let state = WebState {
        hub,
        configured_screen_id: screen_id,
        control,
    };
    let static_dir = std::fs::canonicalize(&static_dir).unwrap_or(static_dir);
    let index = static_dir.join("index.html");
    Router::new()
        .route("/healthz", get(healthz))
        .route("/config.json", get(runtime_config))
        .route("/api/control", get(control_manifest).post(control_action))
        .route("/api/boards", get(board_list))
        .route("/api/screens", get(screen_list))
        .route("/api/displays", get(display_list))
        .route("/api/displays/{id}", axum::routing::delete(forget_display))
        .route("/api/status", get(runtime_status))
        .route("/api/system", get(system_status))
        .route("/api/timing", axum::routing::post(update_timing))
        .route("/api/runtime/reload", axum::routing::post(runtime_reload))
        .route(
            "/api/lifecycle/broker/restart",
            axum::routing::post(broker_restart),
        )
        .route("/api/audio", get(audio_status).post(audio_action))
        .route("/api/volume/{output}", get(volume_get).post(volume_set))
        .route("/ws", any(websocket))
        .route_service("/control", ServeFile::new(index.clone()))
        .route_service("/control/", ServeFile::new(index.clone()))
        .fallback_service(
            ServeDir::new(static_dir)
                .append_index_html_on_directories(true)
                .not_found_service(ServeFile::new(index)),
        )
        .layer(DefaultBodyLimit::max(4 * 1024))
        .layer(axum::middleware::map_response(revalidate_html))
        .with_state(state)
}

async fn revalidate_html(mut response: Response) -> Response {
    // HTML points at content-hashed assets. Always revalidate the entry page so
    // a restarted kiosk does not keep an older WebSocket protocol client.
    if response.headers().get(CONTENT_TYPE).is_some_and(|value| {
        value
            .to_str()
            .is_ok_and(|value| value.starts_with("text/html"))
    }) {
        response
            .headers_mut()
            .insert(CACHE_CONTROL, "no-cache".parse().unwrap());
    }
    response
}

async fn healthz() -> &'static str {
    "ok"
}

async fn runtime_reload(State(state): State<WebState>, headers: HeaderMap) -> Response {
    if !same_origin_or_non_browser(&headers) {
        return StatusCode::FORBIDDEN.into_response();
    }
    let Some(sender) = &state.control.reload_sender else {
        return (
            StatusCode::CONFLICT,
            "show reload is available only under the fx service supervisor",
        )
            .into_response();
    };
    if sender.send(()).await.is_err() {
        return (StatusCode::SERVICE_UNAVAILABLE, "show runtime unavailable").into_response();
    }
    Json(serde_json::json!({ "status": "restarting" })).into_response()
}

async fn broker_restart(State(state): State<WebState>, headers: HeaderMap) -> Response {
    if !same_origin_or_non_browser(&headers) {
        return StatusCode::FORBIDDEN.into_response();
    }
    if !cfg!(target_os = "linux") {
        return (
            StatusCode::CONFLICT,
            "broker restart is available only on the Linux controller",
        )
            .into_response();
    }
    let restart = tokio::task::spawn_blocking(|| {
        Command::new("systemctl")
            .args([
                "--no-ask-password",
                "restart",
                "mosquitto.service",
            ])
            .output()
    });
    match timeout(Duration::from_secs(8), restart).await {
        Ok(Ok(Ok(output))) if output.status.success() => {
            state
                .control
                .workflows
                .note("Dashboard restarted the MQTT broker".into());
            Json(serde_json::json!({ "status": "restarted" })).into_response()
        }
        Ok(Ok(Ok(output))) => {
            let detail = String::from_utf8_lossy(&output.stderr).trim().to_string();
            (
                StatusCode::BAD_GATEWAY,
                if detail.is_empty() {
                    "systemctl could not restart mosquitto.service".into()
                } else {
                    detail
                },
            )
                .into_response()
        }
        Ok(Ok(Err(error))) => (
            StatusCode::SERVICE_UNAVAILABLE,
            format!("could not run systemctl: {error}"),
        )
            .into_response(),
        Ok(Err(error)) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            format!("broker restart task failed: {error}"),
        )
            .into_response(),
        Err(_) => (
            StatusCode::GATEWAY_TIMEOUT,
            "broker restart did not finish within 8 seconds",
        )
            .into_response(),
    }
}

#[derive(Deserialize)]
struct ConfigQuery {
    screen: Option<String>,
}

async fn runtime_config(
    State(state): State<WebState>,
    Query(query): Query<ConfigQuery>,
) -> Response {
    let screen_id = query.screen.unwrap_or(state.configured_screen_id);
    if !state.hub.has_screen(&screen_id) {
        return (StatusCode::BAD_REQUEST, "unknown display role").into_response();
    }
    let mut response = Json(RuntimeConfig {
        screen_id,
        websocket: WebSocketConfig {
            enabled: true,
            url: "/ws",
        },
    })
    .into_response();
    response
        .headers_mut()
        .insert(CACHE_CONTROL, "no-store".parse().unwrap());
    response
}

async fn websocket(
    ws: WebSocketUpgrade,
    State(state): State<WebState>,
    headers: HeaderMap,
) -> Response {
    if !same_origin(&headers) {
        return StatusCode::FORBIDDEN.into_response();
    }
    ws.max_message_size(MAX_FRAME_BYTES)
        .max_frame_size(MAX_FRAME_BYTES)
        .on_upgrade(move |socket| {
            handle_socket(
                socket,
                state,
                headers
                    .get(USER_AGENT)
                    .and_then(|value| value.to_str().ok())
                    .unwrap_or("")
                    .to_string(),
            )
        })
}

async fn control_manifest(State(state): State<WebState>) -> Json<ControlManifest> {
    Json(state.control.manifest)
}

async fn board_list(State(state): State<WebState>) -> Json<BoardList> {
    Json(BoardList {
        boards: state.control.boards.snapshot(),
    })
}

async fn screen_list(State(state): State<WebState>) -> Json<Vec<crate::screen::ScreenStatus>> {
    Json(state.hub.statuses())
}

async fn display_list(
    State(state): State<WebState>,
) -> Json<Vec<crate::screen::DisplayDeviceStatus>> {
    Json(state.hub.device_statuses())
}

async fn forget_display(
    AxumPath(id): AxumPath<String>,
    State(state): State<WebState>,
    headers: HeaderMap,
) -> Response {
    if !same_origin_or_non_browser(&headers) || !valid_id(&id) {
        return StatusCode::FORBIDDEN.into_response();
    }
    match state.hub.forget_device(&id) {
        Ok(()) => {
            state
                .control
                .workflows
                .note(format!("Forgot display device {id}"));
            StatusCode::NO_CONTENT.into_response()
        }
        Err(error) => (StatusCode::BAD_REQUEST, error.to_string()).into_response(),
    }
}

async fn runtime_status(State(state): State<WebState>) -> Json<crate::workflow::Snapshot> {
    Json(state.control.workflows.snapshot())
}

async fn system_status(State(state): State<WebState>) -> Response {
    let system = state.control.system.clone();
    match tokio::task::spawn_blocking(move || system.snapshot()).await {
        Ok(snapshot) => Json(snapshot).into_response(),
        Err(_) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            "system status unavailable",
        )
            .into_response(),
    }
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
struct TimingBody {
    node_id: String,
    at_ms: u64,
}

async fn update_timing(
    State(state): State<WebState>,
    headers: HeaderMap,
    Json(body): Json<TimingBody>,
) -> Response {
    if !same_origin_or_non_browser(&headers) {
        return StatusCode::FORBIDDEN.into_response();
    }
    match state
        .control
        .workflows
        .set_timing(&body.node_id, body.at_ms)
    {
        Ok(()) => Json(serde_json::json!({ "status": "updated" })).into_response(),
        Err(error) => (StatusCode::BAD_REQUEST, error).into_response(),
    }
}

async fn audio_status(State(state): State<WebState>) -> Response {
    match state.control.workflows.audio() {
        Ok(audio) => Json(audio.snapshot().await).into_response(),
        Err(error) => (StatusCode::SERVICE_UNAVAILABLE, error).into_response(),
    }
}

async fn audio_action(
    State(state): State<WebState>,
    headers: HeaderMap,
    Json(body): Json<AudioBody>,
) -> Response {
    if !same_origin_or_non_browser(&headers) {
        return StatusCode::FORBIDDEN.into_response();
    }
    let audio = match state.control.workflows.audio() {
        Ok(audio) => audio,
        Err(error) => return (StatusCode::SERVICE_UNAVAILABLE, error).into_response(),
    };
    let result = match body {
        AudioBody::Play {
            track,
            output,
            volume,
        } => {
            return match audio
                .play(&track, &output, volume, &state.control.workflows)
                .await
            {
                Ok(ticket) => (
                    StatusCode::ACCEPTED,
                    Json(serde_json::json!({ "playback": ticket.id })),
                )
                    .into_response(),
                Err(error) => (StatusCode::BAD_REQUEST, error).into_response(),
            };
        }
        AudioBody::Stop { playback } => audio.stop(&playback),
        AudioBody::Volume { output, percent } => audio.set_volume(&output, percent).await,
        AudioBody::Connect { output } => audio.bluetooth(&output, true).await,
        AudioBody::Disconnect { output } => audio.bluetooth(&output, false).await,
    };
    match result {
        Ok(()) => Json(serde_json::json!({ "status": "accepted" })).into_response(),
        Err(error) => (StatusCode::BAD_REQUEST, error).into_response(),
    }
}

async fn volume_get(AxumPath(output): AxumPath<String>, State(state): State<WebState>) -> Response {
    request_volume(&state, output, None).await
}

async fn volume_set(
    AxumPath(output): AxumPath<String>,
    State(state): State<WebState>,
    headers: HeaderMap,
    Json(body): Json<VolumeBody>,
) -> Response {
    if !same_origin_or_non_browser(&headers) || body.percent > 100 {
        return StatusCode::FORBIDDEN.into_response();
    }
    request_volume(&state, output, Some(body.percent)).await
}

async fn request_volume(state: &WebState, id: String, percent: Option<u8>) -> Response {
    if id.is_empty() || id.len() > 128 {
        return StatusCode::BAD_REQUEST.into_response();
    }
    let (response, result) = oneshot::channel();
    if state
        .control
        .volume_sender
        .send(VolumeRequest {
            id,
            percent,
            response,
        })
        .await
        .is_err()
    {
        return (
            StatusCode::SERVICE_UNAVAILABLE,
            "volume runtime unavailable",
        )
            .into_response();
    }
    match timeout(Duration::from_secs(2), result).await {
        Ok(Ok(Ok(status))) => Json(status).into_response(),
        Ok(Ok(Err(error))) => (StatusCode::BAD_REQUEST, error).into_response(),
        _ => (
            StatusCode::GATEWAY_TIMEOUT,
            "volume runtime did not respond",
        )
            .into_response(),
    }
}

async fn control_action(
    State(state): State<WebState>,
    headers: HeaderMap,
    Json(body): Json<ControlBody>,
) -> Response {
    if !same_origin_or_non_browser(&headers) || body.control.is_empty() || body.control.len() > 128
    {
        return StatusCode::FORBIDDEN.into_response();
    }
    let (response, result) = oneshot::channel();
    let request = ControlRequest {
        id: body.control,
        phase: body.phase,
        pwm: body.pwm,
        rpm: body.rpm,
        dc_profile: body.dc_profile,
        response,
    };
    if state.control.sender.send(request).await.is_err() {
        return (StatusCode::SERVICE_UNAVAILABLE, "show runtime unavailable").into_response();
    }
    match timeout(Duration::from_secs(2), result).await {
        Ok(Ok(Ok(()))) => Json(serde_json::json!({ "status": "accepted" })).into_response(),
        Ok(Ok(Err(error))) => (StatusCode::BAD_REQUEST, error).into_response(),
        _ => (StatusCode::GATEWAY_TIMEOUT, "show runtime did not respond").into_response(),
    }
}

fn same_origin(headers: &HeaderMap) -> bool {
    let Some(origin) = headers.get(ORIGIN).and_then(|value| value.to_str().ok()) else {
        return false;
    };
    let Some(host) = headers.get(HOST).and_then(|value| value.to_str().ok()) else {
        return false;
    };
    let Ok(origin) = origin.parse::<axum::http::Uri>() else {
        return false;
    };
    matches!(origin.scheme_str(), Some("http" | "https"))
        && origin
            .authority()
            .is_some_and(|authority| authority.as_str() == host)
}

fn same_origin_or_non_browser(headers: &HeaderMap) -> bool {
    headers.get(ORIGIN).is_none() || same_origin(headers)
}

async fn handle_socket(mut socket: WebSocket, state: WebState, agent: String) {
    let first = match timeout(Duration::from_secs(5), socket.recv()).await {
        Ok(Some(Ok(Message::Text(text)))) => decode_client(&text),
        _ => None,
    };
    let Some(ClientMessage::Hello {
        v: 1,
        screen_id,
        client_id,
        client_name,
    }) = first
    else {
        close_policy(&mut socket, "hello required").await;
        return;
    };
    if !state.hub.has_screen(&screen_id) {
        close_policy(&mut socket, "unknown screen").await;
        return;
    }
    let client_id = client_id.unwrap_or_else(|| uuid::Uuid::new_v4().to_string());
    let client_name = client_name.unwrap_or_default();
    let Ok(client) =
        state
            .hub
            .register_client_with_agent(&screen_id, client_id, client_name, &agent)
    else {
        close_policy(&mut socket, "display capacity reached").await;
        return;
    };

    let Ok(ScreenSubscription {
        snapshot,
        mut commands,
    }) = state.hub.subscribe(&client.token)
    else {
        close_policy(&mut socket, "unknown screen").await;
        return;
    };
    if send_json(&mut socket, &snapshot).await.is_err() {
        return;
    }

    let (mut sender, mut receiver) = socket.split();
    let mut heartbeat_check = tokio::time::interval(Duration::from_secs(5));
    loop {
        tokio::select! {
            _ = heartbeat_check.tick() => {
                if !state.hub.client_alive(&client.token) { break; }
            }
            incoming = receiver.next() => {
                let Some(Ok(message)) = incoming else { break };
                match message {
                    Message::Text(text) => match decode_client(&text) {
                        Some(ClientMessage::Ping { v: 1, id }) if valid_id(&id) => {
                            state.hub.heartbeat(&client.token);
                            let pong = serde_json::json!({ "v": 1, "type": "pong", "id": id });
                            if sender.send(Message::Text(pong.to_string().into())).await.is_err() {
                                break;
                            }
                        }
                        Some(ClientMessage::Applied { v: 1, session_id, seq }) => {
                            if !state.hub.acknowledge(&client.token, &session_id, seq) { break; }
                        }
                        _ => break,
                    },
                    Message::Ping(bytes) => {
                        if sender.send(Message::Pong(bytes)).await.is_err() { break; }
                    }
                    Message::Close(_) => break,
                    _ => break,
                }
            }
            outgoing = commands.recv() => match outgoing {
                Ok(command) => {
                    let Ok(text) = serde_json::to_string(&command) else { break };
                    if sender.send(Message::Text(text.into())).await.is_err() { break; }
                }
                // Missing even one command invalidates contiguous sequencing;
                // reconnecting produces an atomic fresh snapshot.
                Err(broadcast::error::RecvError::Lagged(_)) => break,
                Err(broadcast::error::RecvError::Closed) => break,
            }
        }
    }
}

fn decode_client(text: &str) -> Option<ClientMessage> {
    if text.len() > MAX_FRAME_BYTES {
        return None;
    }
    let message = serde_json::from_str::<ClientMessage>(text).ok()?;
    match &message {
        ClientMessage::Hello {
            v: 1,
            screen_id,
            client_id,
            client_name,
        } if valid_id(screen_id)
            && client_id.as_deref().is_none_or(valid_id)
            && client_name.as_deref().is_none_or(valid_id) =>
        {
            Some(message)
        }
        ClientMessage::Ping { v: 1, id } if valid_id(id) => Some(message),
        ClientMessage::Applied {
            v: 1,
            session_id,
            seq,
        } if valid_id(session_id) && *seq > 0 => Some(message),
        _ => None,
    }
}

fn valid_id(value: &str) -> bool {
    !value.is_empty() && value.len() <= 128
}

async fn send_json(socket: &mut WebSocket, value: &impl Serialize) -> std::result::Result<(), ()> {
    let text = serde_json::to_string(value).map_err(|_| ())?;
    socket
        .send(Message::Text(text.into()))
        .await
        .map_err(|_| ())
}

async fn close_policy(socket: &mut WebSocket, reason: &'static str) {
    let _ = socket
        .send(Message::Close(Some(CloseFrame {
            code: 1008,
            reason: reason.into(),
        })))
        .await;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn control_pwm_payload_is_optional_bounded_and_not_an_arbitrary_cue() {
        let legacy: ControlBody =
            serde_json::from_str(r#"{"control":"dc_a_forward","phase":"press"}"#).unwrap();
        assert_eq!(legacy.pwm, None);
        assert_eq!(legacy.rpm, None);
        assert!(legacy.dc_profile.is_none());
        let body: ControlBody =
            serde_json::from_str(r#"{"control":"dc_a_forward","phase":"press","pwm":128}"#)
                .unwrap();
        assert_eq!(body.pwm, Some(128));
        for invalid in ["-1", "256", "1.5", "\"128\""] {
            assert!(
                serde_json::from_str::<ControlBody>(&format!(
                    r#"{{"control":"dc_a_forward","phase":"press","pwm":{invalid}}}"#
                ))
                .is_err()
            );
        }
        assert!(
            serde_json::from_str::<ControlBody>(
                r#"{"control":"dc_a_forward","phase":"press","cue":"dc:fwd:255:99999"}"#
            )
            .is_err()
        );
        let stepper: ControlBody =
            serde_json::from_str(r#"{"control":"stepper_stroke","phase":"press","rpm":60}"#)
                .unwrap();
        assert_eq!(stepper.rpm, Some(60));
        let curve: ControlBody = serde_json::from_str(
            r#"{"control":"dc_a","phase":"press","dcProfile":{"direction":"forward","peakPwmPercent":85,"minimumPwmPercent":20,"rampMs":300,"holdMs":700,"fadeMs":2200,"audio":{"track":"tractor_tip","output":"jbl","motorDelayMs":500}}}"#,
        )
        .unwrap();
        let curve = curve.dc_profile.unwrap();
        assert!(
            curve.motor_enabled,
            "legacy clients still include the motor"
        );
        assert!(curve.motor_delay_ms.is_none());
        assert_eq!(curve.peak_pwm_percent, 85);
        assert_eq!(curve.minimum_pwm_percent, 20);
        assert_eq!(curve.audio.unwrap().motor_delay_ms, 500);
        assert!(curve.eye.is_none());
        let eye: DcProfileEye =
            serde_json::from_str(r#"{"deviceId":"pi-eye","wakeDelayMs":750}"#).unwrap();
        assert_eq!(eye.device_id, "pi-eye");
        assert_eq!(eye.wake_delay_ms, 750);
        let eye_only: DcProfileInput = serde_json::from_str(
            r#"{"motorEnabled":false,"motorDelayMs":4000,"direction":"forward","peakPwmPercent":60,"minimumPwmPercent":20,"rampMs":300,"holdMs":700,"fadeMs":3500,"eye":{"deviceId":"pi-eye","wakeDelayMs":750}}"#,
        ).unwrap();
        assert!(!eye_only.motor_enabled);
        assert_eq!(eye_only.motor_delay_ms, Some(4000));
        assert!(eye_only.audio.is_none());
        for invalid in [
            r#"{"deviceId":"pi-eye","wakeDelayMs":-1}"#,
            r#"{"deviceId":"pi-eye","wakeDelayMs":1.5}"#,
            r#"{"deviceId":"pi-eye","wakeDelayMs":750,"cue":"eye/reset"}"#,
        ] {
            assert!(serde_json::from_str::<DcProfileEye>(invalid).is_err());
        }
    }

    #[tokio::test]
    async fn html_revalidates_without_disabling_hashed_asset_caching() {
        let html = Response::builder()
            .header(CONTENT_TYPE, "text/html; charset=utf-8")
            .body(axum::body::Body::empty())
            .unwrap();
        assert_eq!(
            revalidate_html(html).await.headers()[CACHE_CONTROL],
            "no-cache"
        );
        let asset = Response::builder()
            .header(CONTENT_TYPE, "application/javascript")
            .body(axum::body::Body::empty())
            .unwrap();
        assert!(
            !revalidate_html(asset)
                .await
                .headers()
                .contains_key(CACHE_CONTROL)
        );
    }

    #[test]
    fn simulated_boards_remain_online_without_heartbeats() {
        let boards = BoardRegistry::default();
        boards.record("radio", "sim-dc-a", "dc_a", "simulated", None);
        {
            let mut records = boards.boards.lock().unwrap();
            records
                .get_mut(&("radio".to_string(), "sim-dc-a".to_string()))
                .unwrap()
                .last_seen = Instant::now() - Duration::from_secs(60);
        }

        assert!(boards.snapshot()[0].online);
    }
    use crate::screen::{EyeCommand, EyeMode, EyeSnapshot, Gaze};
    use futures_util::{SinkExt, StreamExt};
    use tokio_tungstenite::{
        connect_async,
        tungstenite::{Message as ClientFrame, client::IntoClientRequest},
    };

    #[test]
    fn accepts_only_bounded_versioned_client_messages() {
        assert!(matches!(
            decode_client(r#"{"v":1,"type":"hello","screenId":"tractor-eye"}"#),
            Some(ClientMessage::Hello { .. })
        ));
        assert!(matches!(
            decode_client(r#"{"v":1,"type":"ping","id":"1"}"#),
            Some(ClientMessage::Ping { .. })
        ));
        assert!(decode_client(r#"{"v":2,"type":"ping","id":"1"}"#).is_none());
        assert!(decode_client(r#"{"v":1,"type":"hello","screenId":""}"#).is_none());
        assert!(decode_client(&"x".repeat(MAX_FRAME_BYTES + 1)).is_none());
    }

    #[tokio::test]
    async fn real_websocket_synchronizes_then_receives_an_ordered_command() {
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let address = listener.local_addr().unwrap();
        let sleeping = EyeSnapshot {
            mode: EyeMode::Sleeping,
            gaze: Gaze { x: 0.0, y: 0.0 },
        };
        let tipping = EyeSnapshot {
            mode: EyeMode::Tipping,
            gaze: Gaze { x: -0.25, y: -0.65 },
        };
        let hub = ScreenHub::new([
            ("tractor-eye".into(), sleeping.clone()),
            ("aux".into(), sleeping.clone()),
        ]);
        let (control_sender, _control_receiver) = mpsc::channel(1);
        let (volume_sender, _volume_receiver) = mpsc::channel(1);
        let server_app = app(
            std::env::temp_dir(),
            "tractor-eye".into(),
            hub.clone(),
            ControlState {
                manifest: ControlManifest {
                    show: "test".into(),
                    runtime_instance: 1,
                    reload_available: false,
                    controls: Vec::new(),
                    audio_outputs: Vec::new(),
                },
                sender: control_sender,
                volume_sender,
                reload_sender: None,
                boards: BoardRegistry::default(),
                workflows: crate::workflow::WorkflowHub::default(),
                system: SystemRegistry::default(),
            },
        );
        let server = tokio::spawn(async move {
            axum::serve(listener, server_app).await.unwrap();
        });

        let mut request = format!("ws://{address}/ws").into_client_request().unwrap();
        request.headers_mut().insert(
            ORIGIN,
            format!("http://127.0.0.1:{}", address.port())
                .parse()
                .unwrap(),
        );
        let (mut socket, _) = connect_async(request).await.unwrap();
        socket
            .send(ClientFrame::Text(
                r#"{"v":1,"type":"hello","screenId":"tractor-eye"}"#.into(),
            ))
            .await
            .unwrap();

        let snapshot = socket.next().await.unwrap().unwrap().into_text().unwrap();
        let snapshot: serde_json::Value = serde_json::from_str(&snapshot).unwrap();
        assert_eq!(snapshot["type"], "snapshot");
        assert_eq!(snapshot["seq"], 0);
        assert_eq!(snapshot["state"]["mode"], "sleeping");

        hub.publish("tractor-eye", EyeCommand::Wake, tipping, 1234)
            .unwrap();
        let command = socket.next().await.unwrap().unwrap().into_text().unwrap();
        let command: serde_json::Value = serde_json::from_str(&command).unwrap();
        assert_eq!(command["type"], "command");
        assert_eq!(command["seq"], 1);
        assert_eq!(command["command"]["type"], "eye/wake");

        // A non-default configured display role can connect to the same /ws endpoint.
        let mut request = format!("ws://{address}/ws").into_client_request().unwrap();
        request
            .headers_mut()
            .insert(ORIGIN, format!("http://{address}").parse().unwrap());
        let (mut aux, _) = connect_async(request).await.unwrap();
        aux.send(ClientFrame::Text(
            r#"{"v":1,"type":"hello","screenId":"aux","clientId":"ipad","clientName":"iPad"}"#
                .into(),
        ))
        .await
        .unwrap();
        let snapshot = aux.next().await.unwrap().unwrap().into_text().unwrap();
        assert_eq!(
            serde_json::from_str::<serde_json::Value>(&snapshot).unwrap()["state"]["mode"],
            "sleeping"
        );
        assert_eq!(
            hub.statuses()
                .iter()
                .find(|s| s.id == "aux")
                .unwrap()
                .clients[0]
                .name,
            "iPad"
        );
        hub.publish("tractor-eye", EyeCommand::Wake, sleeping, 1234)
            .unwrap();
        assert!(
            tokio::time::timeout(Duration::from_millis(20), aux.next())
                .await
                .is_err()
        );

        server.abort();
    }
}
