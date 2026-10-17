use std::{
    env,
    fs::{self, OpenOptions},
    path::{Path, PathBuf},
    process::{Child, Command, Stdio},
    thread,
    time::Duration,
};

use fx_audio::{FxError, Result};

pub const DEFAULT_LOG_FILE: &str = "/tmp/fx-kiosk.log";
pub const DEFAULT_PID_FILE: &str = "/tmp/fx-kiosk.pid";

#[derive(Debug, Clone)]
pub struct KioskOptions {
    pub browser: PathBuf,
    pub url: String,
    pub log_file: PathBuf,
    pub pid_file: PathBuf,
}

pub struct ManagedKiosk {
    child: Child,
    pid_file: PathBuf,
    stop_on_drop: bool,
}

impl ManagedKiosk {
    pub fn start(options: &KioskOptions) -> Result<Self> {
        if let Some(pid) = running_pid(&options.pid_file)? {
            if let Some(owner) = managed_owner(pid) {
                return Err(FxError::Server(format!(
                    "kiosk PID {pid} is managed by fx run PID {owner}; stop that run first"
                )));
            }
            return Err(FxError::Server(format!(
                "kiosk is already running as PID {pid}; use `fx kiosk restart`"
            )));
        }

        let log = OpenOptions::new()
            .create(true)
            .append(true)
            .open(&options.log_file)?;
        let stderr = log.try_clone()?;
        let mut command = Command::new("setsid");
        command
            .arg(&options.browser)
            .args([
                "--kiosk",
                "--no-first-run",
                "--disable-session-crashed-bubble",
            ])
            .arg(&options.url)
            .stdin(Stdio::null())
            .stdout(Stdio::from(log))
            .stderr(Stdio::from(stderr));
        // SSH sessions commonly omit DISPLAY even while the Pi's local desktop is
        // active. Preserve an explicit value, otherwise target the primary display.
        if env::var_os("DISPLAY").is_none() {
            command.env("DISPLAY", ":0");
        }
        let child = command.spawn()?;
        write_pid(&options.pid_file, child.id())?;
        let mut kiosk = Self {
            child,
            pid_file: options.pid_file.clone(),
            stop_on_drop: true,
        };
        thread::sleep(Duration::from_millis(250));
        if let Some(status) = kiosk.try_wait()? {
            return Err(FxError::Server(format!(
                "kiosk exited immediately with {status}; see {}",
                options.log_file.display()
            )));
        }
        Ok(kiosk)
    }

    pub fn pid(&self) -> u32 {
        self.child.id()
    }

    pub fn try_wait(&mut self) -> Result<Option<std::process::ExitStatus>> {
        let status = self.child.try_wait()?;
        if status.is_some() {
            remove_pid_file_if_matches(&self.pid_file, self.child.id())?;
            self.stop_on_drop = false;
        }
        Ok(status)
    }

    pub fn detach(mut self) {
        self.stop_on_drop = false;
    }
}

impl Drop for ManagedKiosk {
    fn drop(&mut self) {
        if self.stop_on_drop {
            let _ = stop_pid(self.child.id(), &self.pid_file);
        }
    }
}

pub fn running_pid(pid_file: &Path) -> Result<Option<u32>> {
    let contents = match fs::read_to_string(pid_file) {
        Ok(contents) => contents,
        Err(error) if error.kind() == std::io::ErrorKind::NotFound => return Ok(None),
        Err(error) => return Err(error.into()),
    };
    let pid = contents
        .trim()
        .parse::<u32>()
        .map_err(|_| FxError::Server(format!("invalid kiosk PID file {}", pid_file.display())))?;
    if process_exists(pid) {
        Ok(Some(pid))
    } else {
        remove_pid_file(pid_file)?;
        Ok(None)
    }
}

pub fn stop(options: &KioskOptions) -> Result<bool> {
    let Some(pid) = running_pid(&options.pid_file)? else {
        return Ok(false);
    };
    if let Some(owner) = managed_owner(pid) {
        return Err(FxError::Server(format!(
            "kiosk PID {pid} is managed by fx run PID {owner}; stop that run or use --no-kiosk"
        )));
    }
    stop_pid(pid, &options.pid_file)?;
    Ok(true)
}

pub fn managed_owner(pid: u32) -> Option<u32> {
    let status =
        fs::read_to_string(Path::new("/proc").join(pid.to_string()).join("status")).ok()?;
    let parent = status
        .lines()
        .find_map(|line| line.strip_prefix("PPid:"))?
        .trim()
        .parse::<u32>()
        .ok()?;
    let command =
        fs::read_to_string(Path::new("/proc").join(parent.to_string()).join("comm")).ok()?;
    (command.trim() == "fx").then_some(parent)
}

fn stop_pid(pid: u32, pid_file: &Path) -> Result<()> {
    let status = Command::new("kill")
        .args(["-TERM", "--", &format!("-{pid}")])
        .status()?;
    if !status.success() && process_exists(pid) {
        return Err(FxError::Server(format!(
            "could not stop kiosk process group {pid}"
        )));
    }
    for _ in 0..20 {
        if !process_exists(pid) {
            break;
        }
        thread::sleep(Duration::from_millis(50));
    }
    remove_pid_file(pid_file)?;
    Ok(())
}

fn process_exists(pid: u32) -> bool {
    Path::new("/proc").join(pid.to_string()).exists()
}

fn write_pid(pid_file: &Path, pid: u32) -> Result<()> {
    if let Some(parent) = pid_file.parent() {
        fs::create_dir_all(parent)?;
    }
    let temporary = pid_file.with_extension("tmp");
    fs::write(&temporary, format!("{pid}\n"))?;
    fs::rename(temporary, pid_file)?;
    Ok(())
}

fn remove_pid_file(pid_file: &Path) -> Result<()> {
    match fs::remove_file(pid_file) {
        Ok(()) => Ok(()),
        Err(error) if error.kind() == std::io::ErrorKind::NotFound => Ok(()),
        Err(error) => Err(error.into()),
    }
}

fn remove_pid_file_if_matches(pid_file: &Path, expected_pid: u32) -> Result<()> {
    let contents = match fs::read_to_string(pid_file) {
        Ok(contents) => contents,
        Err(error) if error.kind() == std::io::ErrorKind::NotFound => return Ok(()),
        Err(error) => return Err(error.into()),
    };
    if contents.trim() == expected_pid.to_string() {
        remove_pid_file(pid_file)?;
    }
    Ok(())
}
