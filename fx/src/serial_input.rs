use std::{
    fs::{self, File, OpenOptions},
    io::{BufRead, BufReader, Read, Write},
    path::{Path, PathBuf},
    process::Command,
    thread,
    time::{Duration, Instant},
};

use fx_audio::{FxError, Result};
use tokio::sync::mpsc;

#[cfg(test)]
use crate::cue_link::EventDeduper;
use crate::cue_link::{CueLinkSender, EventMessage, LinkMonitor};

const SERIAL_BY_ID: &str = "/dev/serial/by-id";

pub struct SerialLines {
    reader: BufReader<File>,
}

/// Owns one bidirectional serial Cue link. Incoming Cue JSON is normalized onto
/// a bounded Tokio channel; outgoing Cue requests use a separate bounded queue
/// and expire instead of being replayed late after a disconnect.
pub fn spawn_reconnecting_link(
    link_name: String,
    explicit_port: Option<PathBuf>,
    baud: u32,
    capacity: usize,
) -> (mpsc::Receiver<EventMessage>, CueLinkSender, LinkMonitor) {
    let (event_sender, event_receiver) = mpsc::channel(capacity);
    let (handle, outgoing_receiver) = CueLinkSender::channel(capacity);
    let monitor = LinkMonitor::default();
    let thread_monitor = monitor.clone();
    thread::Builder::new()
        .name(format!("fx-cue-{link_name}"))
        .spawn(move || {
            let mut retry_delay = Duration::from_millis(250);
            loop {
                let port = match select(explicit_port.clone()) {
                    Ok(port) => port,
                    Err(error) => {
                        crate::fx_log!("cue link `{link_name}` unavailable: {error}; retrying");
                        thread::sleep(retry_delay);
                        retry_delay = (retry_delay * 2).min(Duration::from_secs(5));
                        continue;
                    }
                };
                let mut connection = match CueSerial::open(&port, baud) {
                    Ok(connection) => connection,
                    Err(error) => {
                        crate::fx_log!(
                            "could not open cue link `{link_name}` at {}: {error}; retrying",
                            port.display()
                        );
                        thread::sleep(retry_delay);
                        retry_delay = (retry_delay * 2).min(Duration::from_secs(5));
                        continue;
                    }
                };

                crate::fx_log!(
                    "cue link `{link_name}` connected to {} at {baud} baud",
                    port.display()
                );
                thread_monitor.set_connected(true);
                retry_delay = Duration::from_millis(250);
                'connection: loop {
                    while let Ok(outgoing) = outgoing_receiver.try_recv() {
                        if Instant::now() >= outgoing.expires_at {
                            crate::fx_log!(
                                "dropping expired outbound cue `{}` on `{link_name}`",
                                outgoing.event
                            );
                            continue;
                        }
                        if let Err(error) =
                            connection.emit(outgoing.id, &outgoing.destination, &outgoing.event)
                        {
                            thread_monitor.set_connected(false);
                            crate::fx_log!(
                                "cue link `{link_name}` write failed: {error}; reconnecting"
                            );
                            break 'connection;
                        }
                    }

                    match connection.read_lines() {
                        Ok(lines) => {
                            if lines.is_empty() {
                                thread::sleep(Duration::from_millis(2));
                            }
                            for line in lines {
                                if let Some(mut message) = event_message(&line) {
                                    message.link = Some(link_name.clone());
                                    match event_sender.try_send(message) {
                                        Ok(()) => {}
                                        Err(mpsc::error::TrySendError::Full(message)) => {
                                            crate::fx_log!(
                                                "dropping inbound cue `{}`: runtime queue is full",
                                                message.event
                                            );
                                        }
                                        Err(mpsc::error::TrySendError::Closed(_)) => return,
                                    }
                                } else if emit_result(&line).is_some() {
                                    crate::fx_log!("cue link `{link_name}` {line}");
                                } else if !line.is_empty() {
                                    crate::fx_log!("ignoring non-event serial line: {line}");
                                }
                            }
                        }
                        Err(error) => {
                            thread_monitor.set_connected(false);
                            crate::fx_log!(
                                "cue link `{link_name}` read failed: {error}; reconnecting"
                            );
                            break;
                        }
                    }
                }
                thread::sleep(retry_delay);
            }
        })
        .expect("could not start cue serial owner thread");
    (event_receiver, handle, monitor)
}

struct CueSerial {
    file: File,
    pending: Vec<u8>,
}

impl CueSerial {
    fn open(port: &Path, baud: u32) -> Result<Self> {
        configure_link(port, baud)?;
        let file = OpenOptions::new().read(true).write(true).open(port)?;
        Ok(Self {
            file,
            pending: Vec::with_capacity(256),
        })
    }

    fn emit(&mut self, request: u64, destination: &str, event: &str) -> Result<()> {
        self.file
            .write_all(&emit_command(request, destination, event)?)?;
        self.file.flush()?;
        Ok(())
    }

    fn read_lines(&mut self) -> Result<Vec<String>> {
        let mut bytes = [0_u8; 256];
        let count = self.file.read(&mut bytes)?;
        if count == 0 {
            return Ok(Vec::new());
        }
        self.pending.extend_from_slice(&bytes[..count]);
        if self.pending.len() > 8 * 1024 {
            self.pending.clear();
            return Err(FxError::Serial("serial line exceeded 8 KiB".into()));
        }

        let mut lines = Vec::new();
        while let Some(newline) = self.pending.iter().position(|byte| *byte == b'\n') {
            let line = self.pending.drain(..=newline).collect::<Vec<_>>();
            let text = String::from_utf8_lossy(&line[..line.len() - 1])
                .trim_end_matches('\r')
                .to_string();
            lines.push(text);
        }
        Ok(lines)
    }
}

fn emit_command(request: u64, destination: &str, event: &str) -> Result<Vec<u8>> {
    let mut bytes = serde_json::to_vec(&serde_json::json!({
        "type": "emit",
        "request": request,
        "message_id": request,
        "destination": destination,
        "event": event,
    }))
    .map_err(|error| FxError::Serial(format!("could not encode cue command: {error}")))?;
    bytes.push(b'\n');
    Ok(bytes)
}

impl SerialLines {
    pub fn open(port: &Path, baud: u32) -> Result<Self> {
        configure(port, baud)?;
        let reader = BufReader::new(File::open(port)?);
        Ok(Self { reader })
    }

    pub fn next_line(&mut self) -> Result<Option<String>> {
        let mut line = String::new();
        let bytes = self.reader.read_line(&mut line)?;
        if bytes == 0 {
            return Ok(None);
        }
        Ok(Some(line.trim().to_string()))
    }
}

pub fn devices() -> Result<Vec<PathBuf>> {
    let mut devices = match fs::read_dir(SERIAL_BY_ID) {
        Ok(entries) => entries
            .filter_map(|entry| entry.ok().map(|entry| entry.path()))
            .collect::<Vec<_>>(),
        Err(error) if error.kind() == std::io::ErrorKind::NotFound => Vec::new(),
        Err(error) => return Err(error.into()),
    };
    devices.sort();
    Ok(devices)
}

pub fn select(explicit: Option<PathBuf>) -> Result<PathBuf> {
    if let Some(port) = explicit {
        return Ok(port);
    }

    let devices = devices()?;
    match devices.as_slice() {
        [only] => Ok(only.clone()),
        [] => Err(FxError::Serial(
            "no devices found under /dev/serial/by-id; connect the ESP32 or pass --port".into(),
        )),
        _ => Err(FxError::Serial(format!(
            "multiple devices found; choose one with --port: {}",
            devices
                .iter()
                .map(|path| path.display().to_string())
                .collect::<Vec<_>>()
                .join(", ")
        ))),
    }
}

pub fn event_message(line: &str) -> Option<EventMessage> {
    let value = serde_json::from_str::<serde_json::Value>(line).ok()?;
    let is_peer = value.get("type").and_then(serde_json::Value::as_str) == Some("peer");
    Some(EventMessage {
        link: None,
        event: if is_peer {
            "system:peer".into()
        } else {
            value.get("event")?.as_str()?.to_string()
        },
        sequence: value.get("sequence").and_then(serde_json::Value::as_u64),
        source: value
            .get(if is_peer { "node" } else { "source" })
            .and_then(serde_json::Value::as_str)
            .map(str::to_string),
        rssi: value.get("rssi").and_then(serde_json::Value::as_i64),
        service: value
            .get("service")
            .and_then(serde_json::Value::as_str)
            .map(str::to_string),
        transport: value
            .get("transport")
            .and_then(serde_json::Value::as_str)
            .map(str::to_string),
    })
}

fn emit_result(line: &str) -> Option<&str> {
    let value = serde_json::from_str::<serde_json::Value>(line).ok()?;
    (value.get("type")?.as_str()? == "emit_result").then_some(line)
}

pub fn event_name(line: &str) -> Option<String> {
    event_message(line).map(|message| message.event)
}

fn configure(port: &Path, baud: u32) -> Result<()> {
    let output = Command::new("stty")
        .arg("-F")
        .arg(port)
        .arg(baud.to_string())
        .args(["raw", "-echo", "-ixon", "-ixoff"])
        .output()?;

    if output.status.success() {
        Ok(())
    } else {
        let stdout = String::from_utf8_lossy(&output.stdout);
        let stderr = String::from_utf8_lossy(&output.stderr);
        let detail = [stdout.trim(), stderr.trim()]
            .into_iter()
            .filter(|text| !text.is_empty())
            .collect::<Vec<_>>()
            .join("; ");
        Err(FxError::CommandFailed {
            program: "stty".into(),
            status: output.status,
            stderr: detail,
        })
    }
}

fn configure_link(port: &Path, baud: u32) -> Result<()> {
    let output = Command::new("stty")
        .arg("-F")
        .arg(port)
        .arg(baud.to_string())
        .args(["raw", "-echo", "-ixon", "-ixoff", "min", "0", "time", "0"])
        .output()?;

    if output.status.success() {
        Ok(())
    } else {
        Err(FxError::CommandFailed {
            program: "stty".into(),
            status: output.status,
            stderr: String::from_utf8_lossy(&output.stderr).trim().to_string(),
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn extracts_event_name_from_json_line() {
        assert_eq!(
            event_name(r#"{"event":"tractor_tipped","sequence":42}"#),
            Some("tractor_tipped".into())
        );
        assert_eq!(event_name("not json"), None);
        assert_eq!(event_name(r#"{"sequence":42}"#), None);
    }

    #[test]
    fn emits_the_gateway_newline_json_contract() {
        let bytes = emit_command(42, "AABBCCDDEEFF", "tractor:stepper:stroke").unwrap();
        assert_eq!(bytes.last(), Some(&b'\n'));
        let value: serde_json::Value = serde_json::from_slice(&bytes).unwrap();
        assert_eq!(value["type"], "emit");
        assert_eq!(value["request"], 42);
        assert_eq!(value["destination"], "AABBCCDDEEFF");
        assert_eq!(value["event"], "tractor:stepper:stroke");
    }

    #[test]
    fn deduplicates_only_matching_source_event_and_sequence() {
        let mut deduper = EventDeduper::new(8);
        let first = EventMessage {
            link: Some("radio".into()),
            event: "horn:pushed".into(),
            sequence: Some(7),
            source: Some("AABBCCDDEEFF".into()),
            rssi: Some(-67),
            service: None,
            transport: None,
        };
        let different_event = EventMessage {
            event: "tractor:moo".into(),
            ..first.clone()
        };
        let different_sequence = EventMessage {
            sequence: Some(8),
            ..first.clone()
        };
        let different_source = EventMessage {
            source: Some("112233445566".into()),
            ..first.clone()
        };

        assert!(!deduper.is_duplicate(&first));
        assert!(deduper.is_duplicate(&first));
        assert!(!deduper.is_duplicate(&different_event));
        assert!(!deduper.is_duplicate(&different_sequence));
        assert!(!deduper.is_duplicate(&different_source));
    }

    #[test]
    fn extracts_peer_declarations() {
        let message = event_message(
            r#"{"type":"peer","node":"AABBCCDDEEFF","service":"dc-motor","transport":"esp-now","rssi":-61}"#,
        )
        .unwrap();
        assert_eq!(message.event, "system:peer");
        assert_eq!(message.source.as_deref(), Some("AABBCCDDEEFF"));
        assert_eq!(message.service.as_deref(), Some("dc-motor"));
        assert_eq!(message.transport.as_deref(), Some("esp-now"));
        assert_eq!(message.rssi, Some(-61));
    }
}
