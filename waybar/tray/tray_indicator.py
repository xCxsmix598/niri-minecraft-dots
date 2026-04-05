from pathlib import Path

if open(f'{Path.home()}/.config/waybar/tray/tray.state', 'r').read() == "off":
    print("")
else:
    print("")
