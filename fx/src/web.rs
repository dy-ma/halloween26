use std::{net::SocketAddr, path::PathBuf, time::Duration};

use axum::{
    Json, Router,
    extract::{
        State, WebSocketUpgrade,
        ws::{CloseFrame, Message, WebSocket},
    },
    http::{
        HeaderMap, StatusCode,
        header::{CACHE_CONTROL, ORIGIN},
    },
    response::{IntoResponse, Response},
    routing::{any, get},
};
use futures_util::{SinkExt, StreamExt};
use serde::{Deserialize, Serialize};
use tokio::{net::TcpListener, sync::broadcast, time::timeout};
use tower_http::services::ServeDir;

use crate::screen::{ScreenHub, ScreenSubscription};

const MAX_FRAME_BYTES: usize = 8 * 1024;

#[derive(Clone)]
struct WebState {
    hub: ScreenHub,
    configured_screen_id: String,
    allowed_origins: Vec<String>,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct RuntimeConfig<'a> {
    screen_id: &'a str,
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
    },
    #[serde(rename = "ping")]
    Ping { v: u8, id: String },
}

pub async fn serve(
    bind: SocketAddr,
    static_dir: PathBuf,
    screen_id: String,
    hub: ScreenHub,
) -> std::io::Result<()> {
    let listener = TcpListener::bind(bind).await?;
    crate::fx_log!("eye server listening on http://{bind}/");
    axum::serve(listener, app(bind, static_dir, screen_id, hub)).await
}

fn app(bind: SocketAddr, static_dir: PathBuf, screen_id: String, hub: ScreenHub) -> Router {
    let allowed_origins = vec![
        format!("http://127.0.0.1:{}", bind.port()),
        format!("http://localhost:{}", bind.port()),
        format!("http://[::1]:{}", bind.port()),
    ];
    let state = WebState {
        hub,
        configured_screen_id: screen_id,
        allowed_origins,
    };
    Router::new()
        .route("/healthz", get(healthz))
        .route("/config.json", get(runtime_config))
        .route("/ws", any(websocket))
        .fallback_service(ServeDir::new(static_dir).append_index_html_on_directories(true))
        .with_state(state)
}

async fn healthz() -> &'static str {
    "ok"
}

async fn runtime_config(State(state): State<WebState>) -> Response {
    let mut response = Json(RuntimeConfig {
        screen_id: &state.configured_screen_id,
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
    let origin = headers.get(ORIGIN).and_then(|value| value.to_str().ok());
    if !origin.is_some_and(|origin| {
        state
            .allowed_origins
            .iter()
            .any(|allowed| allowed == origin)
    }) {
        return StatusCode::FORBIDDEN.into_response();
    }
    ws.max_message_size(MAX_FRAME_BYTES)
        .max_frame_size(MAX_FRAME_BYTES)
        .on_upgrade(move |socket| handle_socket(socket, state))
}

async fn handle_socket(mut socket: WebSocket, state: WebState) {
    let first = match timeout(Duration::from_secs(5), socket.recv()).await {
        Ok(Some(Ok(Message::Text(text)))) => decode_client(&text),
        _ => None,
    };
    let Some(ClientMessage::Hello { v: 1, screen_id }) = first else {
        close_policy(&mut socket, "hello required").await;
        return;
    };
    if screen_id != state.configured_screen_id {
        close_policy(&mut socket, "unknown screen").await;
        return;
    }

    let Ok(ScreenSubscription {
        snapshot,
        mut commands,
    }) = state.hub.subscribe(&screen_id)
    else {
        close_policy(&mut socket, "unknown screen").await;
        return;
    };
    if send_json(&mut socket, &snapshot).await.is_err() {
        return;
    }

    let (mut sender, mut receiver) = socket.split();
    loop {
        tokio::select! {
            incoming = receiver.next() => {
                let Some(Ok(message)) = incoming else { break };
                match message {
                    Message::Text(text) => match decode_client(&text) {
                        Some(ClientMessage::Ping { v: 1, id }) if valid_id(&id) => {
                            let pong = serde_json::json!({ "v": 1, "type": "pong", "id": id });
                            if sender.send(Message::Text(pong.to_string().into())).await.is_err() {
                                break;
                            }
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
        ClientMessage::Hello { v: 1, screen_id } if valid_id(screen_id) => Some(message),
        ClientMessage::Ping { v: 1, id } if valid_id(id) => Some(message),
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
        let hub = ScreenHub::new([("tractor-eye".into(), sleeping.clone())]);
        let server_app = app(
            address,
            std::env::temp_dir(),
            "tractor-eye".into(),
            hub.clone(),
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

        server.abort();
    }
}
