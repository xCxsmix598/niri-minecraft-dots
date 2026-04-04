#!/usr/bin/env python3

from pathlib import Path

STATE_FILE = Path.home() / ".config/waybar/scripts/tray.state"

state = STATE_FILE.read_text().strip() if STATE_FILE.exists() else "off"

if state == "off":
    print("")  # up arrow
else:
    print("")  # down arrow
