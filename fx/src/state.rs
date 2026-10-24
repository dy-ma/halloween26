use crate::show_config::{FlowRole, PropConfig};
use serde::Serialize;
use std::{
    collections::BTreeMap,
    sync::{Arc, Mutex},
};

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize)]
#[serde(rename_all = "kebab-case")]
pub enum SystemMode {
    Unmanaged,
    NeedsReset,
    Ready,
    Running,
    Resetting,
    Halted,
    Fault,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TransitionRef {
    pub prop: String,
    pub transition: String,
}

impl TransitionRef {
    pub fn parse(value: &str) -> Option<Self> {
        let (prop, transition) = value.split_once('.')?;
        if prop.is_empty() || transition.is_empty() || transition.contains('.') {
            return None;
        }
        Some(Self {
            prop: prop.into(),
            transition: transition.into(),
        })
    }
}

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct PendingTransition {
    pub name: String,
    pub phase: &'static str,
    pub execute_at_ms: Option<u64>,
    pub run_id: String,
    pub node_id: String,
}

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct PropStatus {
    pub id: String,
    pub label: String,
    pub state: String,
    pub ready_state: String,
    pub pending: Option<PendingTransition>,
}

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct StateSnapshot {
    pub mode: SystemMode,
    pub props: Vec<PropStatus>,
}

#[derive(Clone)]
struct PropRuntime {
    config: PropConfig,
    state: String,
    pending: Option<PendingTransition>,
}

struct Inner {
    mode: SystemMode,
    props: BTreeMap<String, PropRuntime>,
}

#[derive(Clone)]
pub struct StateHub {
    inner: Arc<Mutex<Inner>>,
}

impl Default for StateHub {
    fn default() -> Self {
        Self::new(&BTreeMap::new())
    }
}

impl StateHub {
    pub fn new(configs: &BTreeMap<String, PropConfig>) -> Self {
        let props = configs
            .iter()
            .map(|(id, config)| {
                (
                    id.clone(),
                    PropRuntime {
                        config: config.clone(),
                        state: config.initial.clone(),
                        pending: None,
                    },
                )
            })
            .collect::<BTreeMap<_, _>>();
        let mode = if props.is_empty() {
            SystemMode::Unmanaged
        } else if props.values().all(|prop| prop.state == prop.config.ready) {
            SystemMode::Ready
        } else {
            SystemMode::NeedsReset
        };
        Self {
            inner: Arc::new(Mutex::new(Inner { mode, props })),
        }
    }

    pub fn snapshot(&self) -> StateSnapshot {
        let inner = self.inner.lock().expect("state mutex");
        StateSnapshot {
            mode: inner.mode,
            props: inner
                .props
                .iter()
                .map(|(id, prop)| PropStatus {
                    id: id.clone(),
                    label: prop.config.label.clone(),
                    state: prop.state.clone(),
                    ready_state: prop.config.ready.clone(),
                    pending: prop.pending.clone(),
                })
                .collect(),
        }
    }

    pub fn begin_flow(&self, role: FlowRole) -> Result<(), String> {
        let mut inner = self.inner.lock().expect("state mutex");
        if inner.mode == SystemMode::Unmanaged || role == FlowRole::Utility {
            return Ok(());
        }
        match role {
            FlowRole::Show if inner.mode == SystemMode::Ready => {
                inner.mode = SystemMode::Running;
                Ok(())
            }
            FlowRole::Show => Err(format!(
                "show request rejected while controller is {:?}",
                inner.mode
            )),
            FlowRole::Reset
                if matches!(
                    inner.mode,
                    SystemMode::NeedsReset
                        | SystemMode::Ready
                        | SystemMode::Halted
                        | SystemMode::Fault
                ) =>
            {
                inner.mode = SystemMode::Resetting;
                Ok(())
            }
            FlowRole::Reset => Err(format!(
                "reset request rejected while controller is {:?}",
                inner.mode
            )),
            FlowRole::Stop => {
                inner.mode = SystemMode::Halted;
                Ok(())
            }
            FlowRole::Utility => Ok(()),
        }
    }

    pub fn finish_flow(&self, role: FlowRole, success: bool) {
        let mut inner = self.inner.lock().expect("state mutex");
        if inner.mode == SystemMode::Unmanaged || role == FlowRole::Utility {
            return;
        }
        // A cancelled older run may finish after a stop or reset has already
        // changed the controller mode. It must not overwrite the newer state.
        match role {
            FlowRole::Show if inner.mode == SystemMode::Running => {
                inner.mode = if success {
                    SystemMode::NeedsReset
                } else {
                    SystemMode::Fault
                };
            }
            FlowRole::Reset if inner.mode == SystemMode::Resetting => {
                inner.mode = if success
                    && inner
                        .props
                        .values()
                        .all(|prop| prop.state == prop.config.ready)
                {
                    SystemMode::Ready
                } else {
                    SystemMode::Fault
                };
            }
            FlowRole::Stop => inner.mode = SystemMode::Halted,
            _ => {}
        }
    }

    pub fn reserve(
        &self,
        transition: &TransitionRef,
        run_id: &str,
        node_id: &str,
        execute_at_ms: Option<u64>,
    ) -> Result<(), String> {
        let mut inner = self.inner.lock().expect("state mutex");
        let prop = inner
            .props
            .get_mut(&transition.prop)
            .ok_or_else(|| format!("unknown prop `{}`", transition.prop))?;
        let definition = prop
            .config
            .transitions
            .get(&transition.transition)
            .ok_or_else(|| {
                format!(
                    "unknown transition `{}.{}`",
                    transition.prop, transition.transition
                )
            })?;
        if prop.pending.is_some() {
            return Err(format!(
                "prop `{}` already has pending work",
                transition.prop
            ));
        }
        if !definition.from.contains(&prop.state) {
            return Err(format!(
                "transition `{}.{}` is not allowed from `{}`",
                transition.prop, transition.transition, prop.state
            ));
        }
        prop.pending = Some(PendingTransition {
            name: transition.transition.clone(),
            phase: "scheduled",
            execute_at_ms,
            run_id: run_id.into(),
            node_id: node_id.into(),
        });
        Ok(())
    }

    pub fn begin_transition(&self, transition: &TransitionRef, run_id: &str, node_id: &str) {
        let mut inner = self.inner.lock().expect("state mutex");
        let Some(prop) = inner.props.get_mut(&transition.prop) else {
            return;
        };
        let Some(pending) = prop.pending.as_mut() else {
            return;
        };
        if pending.run_id != run_id || pending.node_id != node_id {
            return;
        }
        pending.phase = "active";
        if let Some(definition) = prop.config.transitions.get(&transition.transition) {
            prop.state = definition.active.clone();
        }
    }

    pub fn complete_transition(&self, transition: &TransitionRef, run_id: &str, node_id: &str) {
        self.finish_transition(transition, run_id, node_id, true);
    }

    pub fn fail_transition(&self, transition: &TransitionRef, run_id: &str, node_id: &str) {
        self.finish_transition(transition, run_id, node_id, false);
    }

    fn finish_transition(
        &self,
        transition: &TransitionRef,
        run_id: &str,
        node_id: &str,
        success: bool,
    ) {
        let mut inner = self.inner.lock().expect("state mutex");
        let Some(prop) = inner.props.get_mut(&transition.prop) else {
            return;
        };
        if !prop
            .pending
            .as_ref()
            .is_some_and(|pending| pending.run_id == run_id && pending.node_id == node_id)
        {
            return;
        }
        if let Some(definition) = prop.config.transitions.get(&transition.transition) {
            prop.state = if success {
                definition.to.clone()
            } else {
                definition.failure.clone()
            };
        }
        prop.pending = None;
    }

    pub fn halt(&self) {
        let mut inner = self.inner.lock().expect("state mutex");
        if inner.mode != SystemMode::Unmanaged {
            inner.mode = SystemMode::Halted;
        }
        for prop in inner.props.values_mut() {
            if prop.pending.is_some() && prop.config.states.iter().any(|state| state == "halted") {
                prop.state = "halted".into();
            }
            prop.pending = None;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::show_config::TransitionConfig;

    fn lift() -> PropConfig {
        PropConfig {
            label: "Lift A".into(),
            initial: "unknown".into(),
            ready: "low".into(),
            states: [
                "unknown", "homing", "low", "raising", "high", "halted", "fault",
            ]
            .into_iter()
            .map(str::to_string)
            .collect(),
            transitions: BTreeMap::from([
                (
                    "home".into(),
                    TransitionConfig {
                        from: ["unknown", "halted", "high", "fault"]
                            .into_iter()
                            .map(str::to_string)
                            .collect(),
                        active: "homing".into(),
                        to: "low".into(),
                        failure: "fault".into(),
                    },
                ),
                (
                    "raise".into(),
                    TransitionConfig {
                        from: vec!["low".into()],
                        active: "raising".into(),
                        to: "high".into(),
                        failure: "fault".into(),
                    },
                ),
            ]),
        }
    }

    #[test]
    fn reset_establishes_ready_and_stop_requires_homing_again() {
        let hub = StateHub::new(&BTreeMap::from([("lift_a".into(), lift())]));
        assert_eq!(hub.snapshot().mode, SystemMode::NeedsReset);
        hub.begin_flow(FlowRole::Reset).unwrap();
        let home = TransitionRef::parse("lift_a.home").unwrap();
        hub.reserve(&home, "reset", "home", Some(100)).unwrap();
        assert_eq!(hub.snapshot().props[0].state, "unknown");
        hub.begin_transition(&home, "reset", "home");
        assert_eq!(hub.snapshot().props[0].state, "homing");
        hub.complete_transition(&home, "reset", "home");
        hub.finish_flow(FlowRole::Reset, true);
        assert_eq!(hub.snapshot().mode, SystemMode::Ready);

        hub.begin_flow(FlowRole::Show).unwrap();
        let raise = TransitionRef::parse("lift_a.raise").unwrap();
        hub.reserve(&raise, "show", "raise", None).unwrap();
        hub.begin_transition(&raise, "show", "raise");
        hub.halt();
        assert_eq!(hub.snapshot().mode, SystemMode::Halted);
        assert_eq!(hub.snapshot().props[0].state, "halted");
        assert!(hub.begin_flow(FlowRole::Show).is_err());
    }

    #[test]
    fn cancelled_show_cannot_overwrite_a_newer_stop_or_reset() {
        let hub = StateHub::new(&BTreeMap::from([("lift_a".into(), lift())]));
        hub.begin_flow(FlowRole::Reset).unwrap();
        let home = TransitionRef::parse("lift_a.home").unwrap();
        hub.reserve(&home, "reset", "home", None).unwrap();
        hub.begin_transition(&home, "reset", "home");
        hub.complete_transition(&home, "reset", "home");
        hub.finish_flow(FlowRole::Reset, true);
        hub.begin_flow(FlowRole::Show).unwrap();

        hub.halt();
        hub.begin_flow(FlowRole::Reset).unwrap();
        hub.finish_flow(FlowRole::Show, false);
        assert_eq!(hub.snapshot().mode, SystemMode::Resetting);
        assert!(hub.begin_flow(FlowRole::Reset).is_err());
    }
}
