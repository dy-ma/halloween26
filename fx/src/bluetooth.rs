use std::{collections::BTreeMap, path::PathBuf, process::Command, time::Duration};

use crate::{FxError, Result};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct BluetoothDevice {
    pub address: String,
    pub name: String,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct BluetoothDeviceInfo {
    pub address: String,
    pub name: String,
    pub paired: bool,
    pub bonded: bool,
    pub trusted: bool,
    pub connected: bool,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DeviceFilter {
    All,
    Paired,
    Bonded,
    Trusted,
    Connected,
}

impl DeviceFilter {
    fn as_bluetoothctl_arg(self) -> Option<&'static str> {
        match self {
            Self::All => None,
            Self::Paired => Some("Paired"),
            Self::Bonded => Some("Bonded"),
            Self::Trusted => Some("Trusted"),
            Self::Connected => Some("Connected"),
        }
    }
}

#[derive(Debug, Clone)]
pub struct BluezCli {
    program: PathBuf,
}

impl Default for BluezCli {
    fn default() -> Self {
        Self {
            program: "bluetoothctl".into(),
        }
    }
}

impl BluezCli {
    pub fn with_program(program: impl Into<PathBuf>) -> Self {
        Self {
            program: program.into(),
        }
    }

    pub fn devices(&self, filter: DeviceFilter) -> Result<Vec<BluetoothDevice>> {
        let mut args = vec!["devices"];
        if let Some(filter) = filter.as_bluetoothctl_arg() {
            args.push(filter);
        }
        let output = self.run(&args)?;
        Ok(parse_devices(&output))
    }

    pub fn scan(&self, duration: Duration) -> Result<Vec<BluetoothDevice>> {
        let seconds = duration.as_secs().max(1).to_string();
        self.run(&["--timeout", &seconds, "scan", "on"])?;
        self.devices(DeviceFilter::All)
    }

    pub fn pair(&self, address: &str) -> Result<String> {
        self.run(&["pair", address])
    }

    pub fn trust(&self, address: &str) -> Result<String> {
        self.run(&["trust", address])
    }

    pub fn connect(&self, address: &str) -> Result<String> {
        self.run(&["connect", address])
    }

    pub fn disconnect(&self, address: &str) -> Result<String> {
        self.run(&["disconnect", address])
    }

    pub fn remove(&self, address: &str) -> Result<String> {
        self.run(&["remove", address])
    }

    pub fn info(&self, address: &str) -> Result<String> {
        self.run(&["info", address])
    }

    pub fn device_info(&self, address: &str) -> Result<BluetoothDeviceInfo> {
        let output = self.info(address)?;
        parse_device_info(&output).ok_or_else(|| {
            FxError::InvalidBluetooth(format!("could not parse bluetoothctl info for `{address}`"))
        })
    }

    fn run(&self, args: &[&str]) -> Result<String> {
        let output = Command::new(&self.program).args(args).output()?;
        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stdout = String::from_utf8_lossy(&output.stdout);
            let stderr = String::from_utf8_lossy(&output.stderr);
            let detail = [stdout.trim(), stderr.trim()]
                .into_iter()
                .filter(|text| !text.is_empty())
                .collect::<Vec<_>>()
                .join("; ");
            Err(FxError::CommandFailed {
                program: self.program.display().to_string(),
                status: output.status,
                stderr: detail,
            })
        }
    }
}

pub fn parse_devices(output: &str) -> Vec<BluetoothDevice> {
    let mut devices = BTreeMap::new();

    for line in output.lines() {
        let Some(device_text) = line
            .find("Device ")
            .map(|index| &line[index + "Device ".len()..])
        else {
            continue;
        };
        let mut fields = device_text.splitn(2, char::is_whitespace);
        let Some(address) = fields.next() else {
            continue;
        };
        let Some(name) = fields.next().map(str::trim).filter(|name| !name.is_empty()) else {
            continue;
        };

        if looks_like_address(address) {
            devices.insert(
                address.to_uppercase(),
                BluetoothDevice {
                    address: address.to_uppercase(),
                    name: name.to_string(),
                },
            );
        }
    }

    devices.into_values().collect()
}

fn looks_like_address(value: &str) -> bool {
    value.len() == 17
        && value
            .split(':')
            .all(|part| part.len() == 2 && part.chars().all(|c| c.is_ascii_hexdigit()))
}

pub fn parse_device_info(output: &str) -> Option<BluetoothDeviceInfo> {
    let mut address = None;
    let mut name = None;
    let mut paired = false;
    let mut bonded = false;
    let mut trusted = false;
    let mut connected = false;

    for line in output.lines() {
        let trimmed = line.trim();
        if let Some(rest) = trimmed.strip_prefix("Device ") {
            address = rest.split_whitespace().next().map(str::to_uppercase);
        } else if let Some(value) = trimmed.strip_prefix("Name:") {
            name = Some(value.trim().to_string());
        } else if let Some(value) = trimmed.strip_prefix("Paired:") {
            paired = value.trim() == "yes";
        } else if let Some(value) = trimmed.strip_prefix("Bonded:") {
            bonded = value.trim() == "yes";
        } else if let Some(value) = trimmed.strip_prefix("Trusted:") {
            trusted = value.trim() == "yes";
        } else if let Some(value) = trimmed.strip_prefix("Connected:") {
            connected = value.trim() == "yes";
        }
    }

    Some(BluetoothDeviceInfo {
        address: address?,
        name: name.unwrap_or_else(|| "Unknown device".to_string()),
        paired,
        bonded,
        trusted,
        connected,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_and_deduplicates_device_lines() {
        let output = "\
Device 74:68:59:F0:F2:F4 JBL Go 5
[NEW] Device AA:BB:CC:DD:EE:FF Other Speaker
[CHG] Device 74:68:59:F0:F2:F4 JBL Go 5
garbage
";

        assert_eq!(
            parse_devices(output),
            vec![
                BluetoothDevice {
                    address: "74:68:59:F0:F2:F4".into(),
                    name: "JBL Go 5".into(),
                },
                BluetoothDevice {
                    address: "AA:BB:CC:DD:EE:FF".into(),
                    name: "Other Speaker".into(),
                },
            ]
        );
    }

    #[test]
    fn parses_device_connection_state() {
        let output = "\
Device 74:68:59:F0:F2:F4 (public)
\tName: JBL Go 5
\tPaired: yes
\tBonded: yes
\tTrusted: yes
\tConnected: no
";

        assert_eq!(
            parse_device_info(output),
            Some(BluetoothDeviceInfo {
                address: "74:68:59:F0:F2:F4".into(),
                name: "JBL Go 5".into(),
                paired: true,
                bonded: true,
                trusted: true,
                connected: false,
            })
        );
    }
}
