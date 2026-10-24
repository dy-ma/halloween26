use std::{
    collections::{HashSet, VecDeque},
    sync::mpsc as std_mpsc,
    thread,
    time::{Duration, Instant, SystemTime, UNIX_EPOCH},
};

use fx_audio::{FxError, Result};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct EventMessage {
    pub link: Option<String>,
    pub event: String,
    pub sequence: Option<u64>,
    pub source: Option<String>,
    pub rssi: Option<i64>,
    pub service: Option<String>,
    pub transport: Option<String>,
}

#[derive(Debug)]
pub(crate) struct OutgoingCue {
    pub(crate) id: u64,
    pub(crate) destination: String,
    pub(crate) event: String,
    pub(crate) execute_at_ms: u64,
    pub(crate) expires_after_ms: u32,
    pub(crate) generation: u32,
    pub(crate) expires_at: Instant,
}

#[derive(Clone)]
pub struct CueLinkSender {
    sender: std_mpsc::SyncSender<OutgoingCue>,
}

impl CueLinkSender {
    pub(crate) fn channel(capacity: usize) -> (Self, std_mpsc::Receiver<OutgoingCue>) {
        let (sender, receiver) = std_mpsc::sync_channel(capacity);
        (Self { sender }, receiver)
    }

    pub fn try_emit_tracked_scheduled(
        &self,
        destination: String,
        event: String,
        execute_at_ms: u64,
        lifetime: Duration,
        generation: u32,
    ) -> Result<u64> {
        let id = (uuid::Uuid::new_v4().as_u128() as u64).max(1);
        let expires_after_ms = lifetime.as_millis().min(u32::MAX as u128) as u32;
        let now_ms = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_millis()
            .min(u64::MAX as u128) as u64;
        let lead = execute_at_ms.saturating_sub(now_ms);
        self.sender
            .try_send(OutgoingCue {
                id,
                destination,
                event,
                execute_at_ms,
                expires_after_ms,
                generation,
                expires_at: Instant::now() + Duration::from_millis(lead) + lifetime,
            })
            .map(|_| id)
            .map_err(|error| FxError::Serial(format!("cue transmit queue unavailable: {error}")))
    }
}

pub struct EventDeduper {
    capacity: usize,
    seen: HashSet<(Option<String>, Option<String>, String, u64)>,
    order: VecDeque<(Option<String>, Option<String>, String, u64)>,
}

impl EventDeduper {
    pub fn new(capacity: usize) -> Self {
        Self {
            capacity,
            seen: HashSet::new(),
            order: VecDeque::new(),
        }
    }

    /// Returns true only when the same event and sequence were already observed.
    pub fn is_duplicate(&mut self, message: &EventMessage) -> bool {
        let Some(sequence) = message.sequence else {
            return false;
        };
        let key = (
            message.link.clone(),
            message.source.clone(),
            message.event.clone(),
            sequence,
        );
        if self.seen.contains(&key) {
            return true;
        }

        self.seen.insert(key.clone());
        self.order.push_back(key);
        while self.order.len() > self.capacity {
            if let Some(expired) = self.order.pop_front() {
                self.seen.remove(&expired);
            }
        }
        false
    }
}

pub fn spawn_simulated_link(link_name: String, capacity: usize) -> CueLinkSender {
    let (handle, outgoing_receiver) = CueLinkSender::channel(capacity);
    thread::Builder::new()
        .name(format!("fx-sim-{link_name}"))
        .spawn(move || {
            while let Ok(outgoing) = outgoing_receiver.recv() {
                if Instant::now() >= outgoing.expires_at {
                    crate::fx_log!(
                        "simulated link `{link_name}` dropped expired cue `{}` for `{}`",
                        outgoing.event,
                        outgoing.destination
                    );
                    continue;
                }
                crate::fx_log!(
                    "simulated link `{link_name}` delivered cue `{}` to `{}`",
                    outgoing.event,
                    outgoing.destination
                );
            }
        })
        .expect("could not start simulated cue link");
    handle
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn deduplicates_only_matching_link_source_event_and_sequence() {
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
        assert!(!deduper.is_duplicate(&first));
        assert!(deduper.is_duplicate(&first));
        assert!(!deduper.is_duplicate(&EventMessage {
            link: Some("backup".into()),
            ..first
        }));
    }
}
