from pathlib import Path
import subprocess
import os
import signal

pid = f'{Path.home()}/.config/waybar/tray/tray.pid'
state = f'{Path.home()}/.config/waybar/tray/tray.state'
config = f'{Path.home()}/.config/waybar/tray/tray.jsonc'
style = f'{Path.home()}/.config/waybar/tray/style.css'


on = """// -*- mode: jsonc -*-
{
  "layer": "top", // Waybar at top layer
  "position": "top", // Waybar position (top|bottom|left|right)
  "height": 50, // Waybar height (to be removed for auto height)
  //"width": 1920, // Waybar width
  "margin-top": 0,
  "margin-right": 0,
  "passthrough": false,
  "spacing": 5, // Gaps between modules (4px)
  // Choose the order of the modules
  "modules-right": [
    "tray"
  ],
  "exclusive": false,
  "name": "tray",
  "tray": {
    "icon-size": 21,
    "spacing": 10,
    "icons": {
      "blueman": "bluetooth",
      "TelegramDesktop": "$HOME/.local/share/icons/hicolor/16x16/apps/telegram.png"
    }
  }
}"""

off = """// -*- mode: jsonc -*-
{
  "layer": "top", // Waybar at top layer
  "position": "top", // Waybar position (top|bottom|left|right)
  "height": 50, // Waybar height (to be removed for auto height)
  //"width": 1920, // Waybar width
  "margin-top": 0,
  "margin-right": 0,
  "passthrough": true,
  "spacing": 5, // Gaps between modules (4px)
  // Choose the order of the modules
  "modules-right": [
    "tray"
  ],
  "exclusive": false,
  "name": "tray",
  "tray": {
    "icon-size": 21,
    "spacing": 10,
    "icons": {
      "blueman": "bluetooth",
      "TelegramDesktop": "$HOME/.local/share/icons/hicolor/16x16/apps/telegram.png"
    }
  }
}"""


on_style = """@import "../colors.css";

.tray {
  background-color: transparent;
}

#tray {
  background-color: @primary_container;
  color: @on_primary_container;
  padding-left: 16px;
  padding-right: 16px;
  font-size: 14px;
  border-radius: 12px 12px 12px 12px;
  border: 1px solid @primary;
  margin-top: 4px;
  margin-bottom: 8px;
}

#tray menu {
  font-family: 'Mojangles';
  color: @on_primary_container;
  background-color: @surface;
  border: 1px solid @primary;
}"""

off_style = """.tray {
  background-color: transparent;
}

#tray {
  opacity: 0;
}"""

START_WAYBAR = [
    'waybar',
    '-c',
    config,
    '-s',
    style
]

if open(state, 'r').read() == "off":
    open(config, 'w').write(on)
    open(style, 'w').write(on_style)
    open(state, 'w').write('on')
else:
    open(config, 'w').write(off)
    open(style, 'w').write(off_style)
    open(state, 'w').write('off')

try:
    os.kill(int(open(pid, 'r').read()), signal.SIGINT)
except ProcessLookupError:
    pass

proc = subprocess.Popen(START_WAYBAR, start_new_session=True)
open(pid, 'w').write(str(proc.pid))
os.system('pkill -SIGUSR8 waybar')
