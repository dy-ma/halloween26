use std::{
    fmt,
    fs::{File, OpenOptions},
    io::Write,
    path::Path,
    sync::{Mutex, OnceLock},
    time::{SystemTime, UNIX_EPOCH},
};

use fx_audio::Result;

static LOG_FILE: OnceLock<Mutex<File>> = OnceLock::new();

pub fn init(path: &Path) -> Result<()> {
    let file = OpenOptions::new().create(true).append(true).open(path)?;
    let _ = LOG_FILE.set(Mutex::new(file));
    Ok(())
}

pub fn line(arguments: fmt::Arguments<'_>) {
    eprintln!("{arguments}");
    let Some(file) = LOG_FILE.get() else {
        return;
    };
    let timestamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();
    if let Ok(mut file) = file.lock() {
        let _ = writeln!(file, "[{timestamp}] {arguments}");
    }
}
