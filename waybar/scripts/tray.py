import subprocess
from pathlib import Path
import os

STATE_FILE = Path.home() / ".config/waybar/scripts/tray.state"
PID_FILE = Path.home() / ".config/waybar/scripts/tray.pid"

WAYBAR_CMD = [
    "waybar",
    "-c",
    str(Path.home() / ".config/waybar/tray.jsonc")
]


def read(path):
    return path.read_text().strip() if path.exists() else ""


def write(path, content):
    path.write_text(content)


def is_running(pid):
    return pid.isdigit() and Path(f"/proc/{pid}").exists()


def start():
    pid = read(PID_FILE)

    # prevent duplicate instances
    if is_running(pid):
        return

    proc = subprocess.Popen(WAYBAR_CMD)
    write(PID_FILE, str(proc.pid))
    write(STATE_FILE, "on")


def stop():
    pid = read(PID_FILE)

    if is_running(pid):
        subprocess.run(["kill", pid])

    # cleanup stale PID no matter what
    PID_FILE.unlink(missing_ok=True)
    write(STATE_FILE, "off")


def toggle():
    if read(STATE_FILE) == "on":
        stop()
    else:
        start()


if __name__ == "__main__":
    toggle()
    os.system("pkill -SIGUSR8 waybar")
