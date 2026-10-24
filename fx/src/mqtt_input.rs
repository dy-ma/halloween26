use std::{
    collections::{HashSet, VecDeque},
    env,
    sync::mpsc as std_mpsc,
    thread,
    time::{Duration, Instant, SystemTime, UNIX_EPOCH},
};

use rumqttc::{Client, Event, Incoming, MqttOptions, QoS};
use tokio::sync::mpsc;

use crate::cue_link::{CueLinkSender, EventMessage, LinkMonitor, OutgoingCue};

const WIRE_SIZE: usize = 80;
const NAME_CAPACITY: usize = 32;
const BROADCAST_NODE: u64 = 0xffff_ffff_ffff;
const KIND_CUE: u8 = 1;
const KIND_ACK: u8 = 2;
const KIND_HELLO: u8 = 3;
const KIND_CLOCK: u8 = 4;

#[derive(Debug, Clone)]
pub struct MqttLinkConfig {
    pub host: String,
    pub port: u16,
    pub node: String,
    pub client_id: String,
    pub topic_prefix: String,
    pub username: Option<String>,
    pub password_env: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
struct Packet {
    kind: u8,
    source: u64,
    destination: u64,
    id: u64,
    execute_at_ms: u64,
    expires_after_ms: u32,
    generation: u32,
    name: String,
}

struct PendingCue {
    packet: Packet,
    bytes: Vec<u8>,
    expires_at: Instant,
    next_attempt_at: Instant,
    attempts: u8,
}

pub fn spawn_reconnecting_link(
    link_name: String,
    config: MqttLinkConfig,
    capacity: usize,
) -> (mpsc::Receiver<EventMessage>, CueLinkSender, LinkMonitor) {
    let local_node = parse_node(&config.node).expect("validated MQTT node ID");
    let prefix = config.topic_prefix.trim_end_matches('/').to_string();
    let inbox_topic = format!("{prefix}/cue/{:012X}", local_node);
    let presence_filter = format!("{prefix}/presence/+");
    let presence_topic = format!("{prefix}/presence/{:012X}", local_node);
    let clock_topic = format!("{prefix}/clock");
    let (event_sender, event_receiver) = mpsc::channel(capacity);
    let (handle, outgoing_receiver) = CueLinkSender::channel(capacity);
    let (ack_sender, ack_receiver) = std_mpsc::sync_channel::<u64>(capacity);
    let connected = LinkMonitor::default();

    let mut options = MqttOptions::new(&config.client_id, &config.host, config.port);
    options.set_keep_alive(Duration::from_secs(5));
    options.set_clean_session(true);
    if let (Some(username), Some(password_env)) = (&config.username, &config.password_env) {
        match env::var(password_env) {
            Ok(password) => {
                options.set_credentials(username, password);
            }
            Err(error) => crate::fx_log!(
                "MQTT link `{link_name}` cannot read password_env `{password_env}`: {error}"
            ),
        }
    }
    let (client, mut connection) = Client::new(options, capacity);

    let reader_client = client.clone();
    let reader_connected = connected.clone();
    let reader_link = link_name.clone();
    let reader_prefix = prefix.clone();
    let reader_inbox = inbox_topic.clone();
    let reader_presence = presence_filter.clone();
    thread::Builder::new()
        .name(format!("fx-mqtt-rx-{link_name}"))
        .spawn(move || {
            let mut seen = HashSet::new();
            let mut seen_order = VecDeque::new();
            for notification in connection.iter() {
                match notification {
                    Ok(Event::Incoming(Incoming::ConnAck(_))) => {
                        reader_connected.set_connected(true);
                        if let Err(error) = reader_client
                            .try_subscribe(reader_inbox.clone(), QoS::AtLeastOnce)
                        {
                            crate::fx_log!(
                                "MQTT link `{reader_link}` could not subscribe to `{reader_inbox}`: {error}"
                            );
                        }
                        if let Err(error) = reader_client
                            .try_subscribe(reader_presence.clone(), QoS::AtLeastOnce)
                        {
                            crate::fx_log!(
                                "MQTT link `{reader_link}` could not subscribe to `{reader_presence}`: {error}"
                            );
                        }
                        crate::fx_log!("MQTT link `{reader_link}` connected");
                    }
                    Ok(Event::Incoming(Incoming::Publish(publish))) => {
                        let Some(packet) = decode_packet(publish.payload.as_ref()) else {
                            crate::fx_log!(
                                "MQTT link `{reader_link}` ignored invalid packet on `{}`",
                                publish.topic
                            );
                            continue;
                        };
                        if publish.topic == reader_inbox {
                            match packet.kind {
                                KIND_ACK if packet.destination == local_node => {
                                    let _ = ack_sender.try_send(packet.id);
                                }
                                KIND_CUE if packet.destination == local_node => {
                                    let key = (packet.source, packet.id);
                                    let duplicate = seen.contains(&key);
                                    let accepted = duplicate
                                        || event_sender
                                            .try_send(EventMessage {
                                                link: Some(reader_link.clone()),
                                                event: packet.name.clone(),
                                                sequence: Some(packet.id),
                                                source: Some(format!("{:012X}", packet.source)),
                                                rssi: None,
                                                service: None,
                                                transport: Some("mqtt".into()),
                                            })
                                            .is_ok();
                                    if accepted {
                                        if !duplicate {
                                            seen.insert(key);
                                            seen_order.push_back(key);
                                            while seen_order.len() > 512 {
                                                if let Some(expired) = seen_order.pop_front() {
                                                    seen.remove(&expired);
                                                }
                                            }
                                        }
                                        let ack = encode_packet(&Packet {
                                            kind: KIND_ACK,
                                            source: local_node,
                                            destination: packet.source,
                                            id: packet.id,
                                            execute_at_ms: 0,
                                            expires_after_ms: 0,
                                            generation: 0,
                                            name: String::new(),
                                        });
                                        let topic = format!(
                                            "{reader_prefix}/cue/{:012X}",
                                            packet.source
                                        );
                                        if let Err(error) = reader_client.try_publish(
                                            topic,
                                            QoS::AtLeastOnce,
                                            false,
                                            ack,
                                        ) {
                                            crate::fx_log!(
                                                "MQTT link `{reader_link}` could not ACK cue {}: {error}",
                                                packet.id
                                            );
                                        }
                                    } else {
                                        crate::fx_log!(
                                            "MQTT link `{reader_link}` did not ACK `{}` because the runtime queue is full",
                                            packet.name
                                        );
                                    }
                                }
                                _ => {}
                            }
                        } else if publish.topic.starts_with(&format!("{reader_prefix}/presence/"))
                            && packet.kind == KIND_HELLO
                        {
                            let _ = event_sender.try_send(EventMessage {
                                link: Some(reader_link.clone()),
                                event: "system:peer".into(),
                                sequence: None,
                                source: Some(format!("{:012X}", packet.source)),
                                rssi: None,
                                service: Some(packet.name),
                                transport: Some("mqtt".into()),
                            });
                        }
                    }
                    Ok(_) => {}
                    Err(error) => {
                        reader_connected.set_connected(false);
                        crate::fx_log!(
                            "MQTT link `{reader_link}` disconnected: {error}; reconnecting"
                        );
                    }
                }
            }
            reader_connected.set_connected(false);
        })
        .expect("could not start MQTT receive thread");

    let writer_link = link_name;
    let writer_connected = connected.clone();
    thread::Builder::new()
        .name(format!("fx-mqtt-tx-{writer_link}"))
        .spawn(move || {
            let mut pending = Vec::<PendingCue>::new();
            let mut next_presence_at = Instant::now();
            let mut next_clock_at = Instant::now();
            let mut clock_sequence = 0_u64;
            loop {
                while let Ok(id) = ack_receiver.try_recv() {
                    if let Some(index) = pending.iter().position(|cue| cue.packet.id == id) {
                        let delivered = pending.remove(index);
                        crate::fx_log!(
                            "MQTT link `{writer_link}` delivered cue `{}` to `{:012X}` after {} attempt(s)",
                            delivered.packet.name,
                            delivered.packet.destination,
                            delivered.attempts
                        );
                    }
                }
                while let Ok(outgoing) = outgoing_receiver.try_recv() {
                    queue_outgoing(local_node, outgoing, &mut pending);
                }

                let now = Instant::now();
                pending.retain_mut(|cue| {
                    if now >= cue.expires_at {
                        crate::fx_log!(
                            "MQTT link `{writer_link}` timed out cue `{}` to `{:012X}` after {} attempt(s)",
                            cue.packet.name,
                            cue.packet.destination,
                            cue.attempts
                        );
                        return false;
                    }
                    if writer_connected.is_connected() && now >= cue.next_attempt_at {
                        let topic = format!("{prefix}/cue/{:012X}", cue.packet.destination);
                        match client.try_publish(
                            topic,
                            QoS::AtLeastOnce,
                            false,
                            cue.bytes.clone(),
                        ) {
                            Ok(()) => {
                                cue.attempts = cue.attempts.saturating_add(1);
                                let delay = 70_u64
                                    .saturating_mul(1_u64 << cue.attempts.min(2))
                                    .min(240);
                                cue.next_attempt_at = now + Duration::from_millis(delay);
                            }
                            Err(error) => {
                                crate::fx_log!(
                                    "MQTT link `{writer_link}` publish queue unavailable: {error}"
                                );
                                cue.next_attempt_at = now + Duration::from_millis(100);
                            }
                        }
                    }
                    true
                });

                if writer_connected.is_connected() && now >= next_presence_at {
                    let hello = encode_packet(&Packet {
                        kind: KIND_HELLO,
                        source: local_node,
                        destination: BROADCAST_NODE,
                        id: 0,
                        execute_at_ms: 0,
                        expires_after_ms: 0,
                        generation: 0,
                        name: "fx".into(),
                    });
                    let _ = client.try_publish(
                        presence_topic.clone(),
                        QoS::AtLeastOnce,
                        false,
                        hello,
                    );
                    next_presence_at = now + Duration::from_secs(1);
                }
                if writer_connected.is_connected() && now >= next_clock_at {
                    clock_sequence = clock_sequence.wrapping_add(1).max(1);
                    let clock = encode_packet(&Packet {
                        kind: KIND_CLOCK,
                        source: local_node,
                        destination: BROADCAST_NODE,
                        id: clock_sequence,
                        execute_at_ms: epoch_ms(),
                        expires_after_ms: 0,
                        generation: 0,
                        name: String::new(),
                    });
                    let _ = client.try_publish(
                        clock_topic.clone(),
                        QoS::AtLeastOnce,
                        false,
                        clock,
                    );
                    next_clock_at = now + Duration::from_secs(1);
                }
                thread::sleep(Duration::from_millis(5));
            }
        })
        .expect("could not start MQTT transmit thread");

    (event_receiver, handle, connected)
}

fn queue_outgoing(local_node: u64, outgoing: OutgoingCue, pending: &mut Vec<PendingCue>) {
    if Instant::now() >= outgoing.expires_at {
        return;
    }
    let Some(destination) = parse_node(&outgoing.destination) else {
        crate::fx_log!("invalid MQTT cue destination `{}`", outgoing.destination);
        return;
    };
    let packet = Packet {
        kind: KIND_CUE,
        source: local_node,
        destination,
        id: outgoing.id,
        execute_at_ms: outgoing.execute_at_ms,
        expires_after_ms: outgoing.expires_after_ms,
        generation: outgoing.generation,
        name: outgoing.event,
    };
    pending.push(PendingCue {
        bytes: encode_packet(&packet),
        packet,
        expires_at: outgoing.expires_at,
        next_attempt_at: Instant::now(),
        attempts: 0,
    });
}

fn parse_node(value: &str) -> Option<u64> {
    if value.len() != 12 || !value.bytes().all(|byte| byte.is_ascii_hexdigit()) {
        return None;
    }
    u64::from_str_radix(value, 16)
        .ok()
        .filter(|node| *node != 0)
}

fn epoch_ms() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis()
        .min(u64::MAX as u128) as u64
}

fn encode_packet(packet: &Packet) -> Vec<u8> {
    let mut bytes = vec![0_u8; WIRE_SIZE];
    bytes[..4].copy_from_slice(b"CUE3");
    bytes[4] = 3;
    bytes[5] = packet.kind;
    bytes[8..16].copy_from_slice(&packet.source.to_le_bytes());
    bytes[16..24].copy_from_slice(&packet.destination.to_le_bytes());
    bytes[24..32].copy_from_slice(&packet.id.to_le_bytes());
    bytes[32..40].copy_from_slice(&packet.execute_at_ms.to_le_bytes());
    bytes[40..44].copy_from_slice(&packet.expires_after_ms.to_le_bytes());
    bytes[44..48].copy_from_slice(&packet.generation.to_le_bytes());
    let name = packet.name.as_bytes();
    bytes[48..48 + name.len().min(NAME_CAPACITY - 1)]
        .copy_from_slice(&name[..name.len().min(NAME_CAPACITY - 1)]);
    bytes
}

fn decode_packet(bytes: &[u8]) -> Option<Packet> {
    if bytes.len() != WIRE_SIZE || &bytes[..4] != b"CUE3" || bytes[4] != 3 {
        return None;
    }
    let kind = bytes[5];
    if !matches!(kind, KIND_CUE | KIND_ACK | KIND_HELLO | KIND_CLOCK) {
        return None;
    }
    let source = u64::from_le_bytes(bytes[8..16].try_into().ok()?);
    let destination = u64::from_le_bytes(bytes[16..24].try_into().ok()?);
    let id = u64::from_le_bytes(bytes[24..32].try_into().ok()?);
    let execute_at_ms = u64::from_le_bytes(bytes[32..40].try_into().ok()?);
    let expires_after_ms = u32::from_le_bytes(bytes[40..44].try_into().ok()?);
    let generation = u32::from_le_bytes(bytes[44..48].try_into().ok()?);
    if source == 0 || source > BROADCAST_NODE {
        return None;
    }
    if kind == KIND_CUE && execute_at_ms != 0 && (expires_after_ms == 0 || generation == 0) {
        return None;
    }
    let name_bytes = &bytes[48..];
    let end = name_bytes.iter().position(|byte| *byte == 0)?;
    let name = std::str::from_utf8(&name_bytes[..end]).ok()?.to_string();
    match kind {
        KIND_CUE if destination != 0 && destination != source && id != 0 && !name.is_empty() => {}
        KIND_ACK if destination != 0 && destination != source && id != 0 => {}
        KIND_HELLO if destination == BROADCAST_NODE && id == 0 => {}
        KIND_CLOCK
            if destination == BROADCAST_NODE
                && id != 0
                && execute_at_ms != 0
                && expires_after_ms == 0
                && generation == 0 => {}
        _ => return None,
    }
    Some(Packet {
        kind,
        source,
        destination,
        id,
        execute_at_ms,
        expires_after_ms,
        generation,
        name,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn cue_wire_format_matches_the_embedded_protocol() {
        let packet = Packet {
            kind: KIND_CUE,
            source: 0x112233445566,
            destination: 0xAABBCCDDEEFF,
            id: 0x1234567800000001,
            execute_at_ms: 1_800_000_000_000,
            expires_after_ms: 2_000,
            generation: 7,
            name: "dc:stop".into(),
        };
        let bytes = encode_packet(&packet);
        assert_eq!(bytes.len(), WIRE_SIZE);
        assert_eq!(decode_packet(&bytes), Some(packet));
    }

    #[test]
    fn validates_node_ids() {
        assert_eq!(parse_node("AABBCCDDEEFF"), Some(0xAABBCCDDEEFF));
        assert_eq!(parse_node("not-a-node"), None);
        assert_eq!(parse_node("000000000000"), None);
    }
}
