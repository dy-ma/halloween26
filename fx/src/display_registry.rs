use fx_audio::{FxError, Result};
use serde::{Deserialize, Serialize};
use std::{collections::BTreeMap, env, fs, path::PathBuf};

#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct DisplayDevice {
    pub id: String,
    pub name: String,
    pub user_agent: String,
    pub first_seen_at_ms: u64,
    pub last_seen_at_ms: u64,
}

#[derive(Clone, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
struct Saved {
    version: u8,
    devices: BTreeMap<String, DisplayDevice>,
}

pub struct DisplayRegistry {
    path: Option<PathBuf>,
    saved: Saved,
}

impl Default for DisplayRegistry {
    fn default() -> Self {
        Self {
            path: None,
            saved: Saved {
                version: 1,
                devices: BTreeMap::new(),
            },
        }
    }
}

impl DisplayRegistry {
    pub fn load_default() -> Result<Self> {
        let path = if let Some(path) = env::var_os("FX_DISPLAY_REGISTRY") {
            PathBuf::from(path)
        } else if let Some(root) = env::var_os("XDG_CONFIG_HOME") {
            PathBuf::from(root).join("fx/display-devices.json")
        } else {
            PathBuf::from(
                env::var_os("HOME").ok_or_else(|| FxError::Server("HOME is unavailable".into()))?,
            )
            .join(".config/fx/display-devices.json")
        };
        Self::load(path)
    }

    fn load(path: PathBuf) -> Result<Self> {
        let saved: Saved = match fs::read(&path) {
            Ok(bytes) => serde_json::from_slice(&bytes)
                .map_err(|e| FxError::Server(format!("invalid display registry: {e}")))?,
            Err(error) if error.kind() == std::io::ErrorKind::NotFound => Self::default().saved,
            Err(error) => return Err(error.into()),
        };
        if saved.version != 1
            || saved.devices.len() > 256
            || saved.devices.iter().any(|(id, device)| {
                id != &device.id
                    || id.is_empty()
                    || id.len() > 128
                    || device.name.is_empty()
                    || device.name.len() > 128
                    || device.user_agent.len() > 512
            })
        {
            return Err(FxError::Server("invalid display registry schema".into()));
        }
        Ok(Self {
            path: Some(path),
            saved,
        })
    }

    fn commit(&mut self, next: Saved) -> Result<()> {
        if let Some(path) = &self.path {
            if let Some(parent) = path.parent() {
                fs::create_dir_all(parent)?;
            }
            let temporary = path.with_extension(format!("{}.tmp", uuid::Uuid::new_v4()));
            let bytes =
                serde_json::to_vec_pretty(&next).map_err(|e| FxError::Server(e.to_string()))?;
            fs::write(&temporary, bytes)?;
            fs::rename(&temporary, path)?;
        }
        self.saved = next;
        Ok(())
    }

    pub fn seen(&mut self, id: &str, name: &str, agent: &str) -> Result<DisplayDevice> {
        if !self.saved.devices.contains_key(id) && self.saved.devices.len() >= 256 {
            return Err(FxError::Server(
                "saved display limit reached; forget unused devices".into(),
            ));
        }
        let now = crate::workflow::now_ms();
        let mut next = self.saved.clone();
        let device = next
            .devices
            .entry(id.into())
            .or_insert_with(|| DisplayDevice {
                id: id.into(),
                name: default_name(agent, id),
                user_agent: String::new(),
                first_seen_at_ms: now,
                last_seen_at_ms: now,
            });
        if !name.trim().is_empty() {
            device.name = bounded(name, 128);
        }
        device.user_agent = bounded(agent, 512);
        device.last_seen_at_ms = now;
        let result = device.clone();
        self.commit(next)?;
        Ok(result)
    }

    pub fn disconnected(&mut self, id: &str) -> Result<()> {
        let mut next = self.saved.clone();
        if let Some(device) = next.devices.get_mut(id) {
            device.last_seen_at_ms = crate::workflow::now_ms();
        }
        self.commit(next)
    }

    pub fn devices(&self) -> Vec<DisplayDevice> {
        self.saved.devices.values().cloned().collect()
    }

    pub fn forget(&mut self, id: &str) -> Result<()> {
        let mut next = self.saved.clone();
        if next.devices.remove(id).is_none() {
            return Err(FxError::Server("unknown display device".into()));
        }
        self.commit(next)
    }
}

fn default_name(agent: &str, id: &str) -> String {
    let browser = if agent.contains("Edg/") {
        "Edge"
    } else if agent.contains("Firefox/") {
        "Firefox"
    } else if agent.contains("Chrome/") || agent.contains("Chromium/") {
        "Chrome"
    } else if agent.contains("Safari/") {
        "Safari"
    } else {
        "Browser"
    };
    let suffix: String = id
        .chars()
        .rev()
        .take(6)
        .collect::<String>()
        .chars()
        .rev()
        .collect();
    format!("{browser} · {suffix}")
}

fn bounded(value: &str, limit: usize) -> String {
    let mut result = value.to_string();
    while result.len() > limit {
        result.pop();
    }
    result
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn saved_identity_survives_reload_and_can_be_forgotten() {
        let root = env::temp_dir().join(format!("fx-display-test-{}", uuid::Uuid::new_v4()));
        let path = root.join("devices.json");
        let mut registry = DisplayRegistry::load(path.clone()).unwrap();
        registry
            .seen("stable", "Test screen", "Chrome/123")
            .unwrap();
        let mut registry = DisplayRegistry::load(path.clone()).unwrap();
        registry.seen("stable", "", "Chrome/124").unwrap();
        assert_eq!(registry.devices().len(), 1);
        assert_eq!(registry.devices()[0].name, "Test screen");
        registry.forget("stable").unwrap();
        assert!(
            DisplayRegistry::load(path.clone())
                .unwrap()
                .devices()
                .is_empty()
        );
        fs::remove_file(path).unwrap();
        fs::remove_dir(root).unwrap();
    }
}
