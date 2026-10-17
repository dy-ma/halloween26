use std::{collections::BTreeMap, env, fs, path::PathBuf};

use fx_audio::{FxError, Result};

#[derive(Debug, Clone)]
pub struct DeviceAliases {
    path: PathBuf,
    entries: BTreeMap<String, String>,
}

impl DeviceAliases {
    pub fn load_default() -> Result<Self> {
        Self::load(default_path()?)
    }

    fn load(path: PathBuf) -> Result<Self> {
        let entries = match fs::read_to_string(&path) {
            Ok(contents) => parse(&contents)?,
            Err(error) if error.kind() == std::io::ErrorKind::NotFound => BTreeMap::new(),
            Err(error) => return Err(error.into()),
        };
        Ok(Self { path, entries })
    }

    pub fn resolve(&self, value: Option<String>) -> Option<String> {
        value.map(|value| self.entries.get(&value).cloned().unwrap_or(value))
    }

    pub fn set(&mut self, alias: String, device_id: String) -> Result<()> {
        validate_alias(&alias)?;
        validate_device_id(&device_id)?;
        self.entries.insert(alias, device_id);
        self.save()
    }

    pub fn remove(&mut self, alias: &str) -> Result<bool> {
        let removed = self.entries.remove(alias).is_some();
        if removed {
            self.save()?;
        }
        Ok(removed)
    }

    pub fn iter(&self) -> impl Iterator<Item = (&str, &str)> {
        self.entries
            .iter()
            .map(|(alias, device)| (alias.as_str(), device.as_str()))
    }

    pub fn names_for<'a>(&'a self, device_id: &'a str) -> impl Iterator<Item = &'a str> {
        self.entries
            .iter()
            .filter(move |(_, target)| target.as_str() == device_id)
            .map(|(alias, _)| alias.as_str())
    }

    fn save(&self) -> Result<()> {
        if let Some(parent) = self.path.parent() {
            fs::create_dir_all(parent)?;
        }
        let temporary = self.path.with_extension("tmp");
        fs::write(&temporary, render(&self.entries))?;
        fs::rename(temporary, &self.path)?;
        Ok(())
    }
}

fn default_path() -> Result<PathBuf> {
    if let Some(directory) = env::var_os("XDG_CONFIG_HOME").filter(|value| !value.is_empty()) {
        return Ok(PathBuf::from(directory).join("fx/device-aliases"));
    }
    if let Some(directory) = env::var_os("HOME").filter(|value| !value.is_empty()) {
        return Ok(PathBuf::from(directory).join(".config/fx/device-aliases"));
    }
    Err(FxError::InvalidAlias(
        "neither XDG_CONFIG_HOME nor HOME is set".into(),
    ))
}

fn parse(contents: &str) -> Result<BTreeMap<String, String>> {
    let mut entries = BTreeMap::new();
    for (index, line) in contents.lines().enumerate() {
        let line = line.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        let Some((alias, device_id)) = line.split_once('\t') else {
            return Err(FxError::InvalidAlias(format!(
                "line {} is not tab-separated",
                index + 1
            )));
        };
        validate_alias(alias)?;
        validate_device_id(device_id)?;
        entries.insert(alias.to_string(), device_id.to_string());
    }
    Ok(entries)
}

fn render(entries: &BTreeMap<String, String>) -> String {
    entries
        .iter()
        .map(|(alias, device)| format!("{alias}\t{device}\n"))
        .collect()
}

fn validate_alias(alias: &str) -> Result<()> {
    if alias.is_empty()
        || !alias
            .chars()
            .all(|character| character.is_ascii_alphanumeric() || matches!(character, '-' | '_'))
    {
        return Err(FxError::InvalidAlias(format!(
            "`{alias}` must contain only letters, digits, hyphens, or underscores"
        )));
    }
    Ok(())
}

fn validate_device_id(device_id: &str) -> Result<()> {
    if device_id.is_empty() || device_id.contains(['\t', '\n', '\r']) {
        return Err(FxError::InvalidAlias(
            "device ID must be non-empty and fit on one line".into(),
        ));
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn aliases_round_trip() {
        let entries = parse(
            "# output aliases\nmain\tbluez_output.AA_BB.1\nanalog\talsa_output.platform.stereo\n",
        )
        .unwrap();

        assert_eq!(entries["main"], "bluez_output.AA_BB.1");
        assert_eq!(parse(&render(&entries)).unwrap(), entries);
    }

    #[test]
    fn rejects_ambiguous_aliases() {
        assert!(validate_alias("two words").is_err());
        assert!(validate_alias("jbl-go-5").is_ok());
    }

    #[test]
    fn load_handles_missing_file() {
        let path = PathBuf::from("/definitely/not/a/real/fx/alias/path");
        let aliases = DeviceAliases::load(path).unwrap();
        assert_eq!(aliases.iter().count(), 0);
    }
}
