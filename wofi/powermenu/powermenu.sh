#!/bin/sh

choice=$(echo -e 'Shutdown\nReboot\nHibernate\nSleep\nLogout' | wofi --sort-order Alphabetical -d --width=300 --height=300 -j --style=$HOME/.config/wofi/powermenu/style.css)

if [ $choice = 'Shutdown' ]; then
  systemctl poweroff
elif [ $choice = 'Reboot' ]; then
  systemctl reboot
elif [ $choice = 'Hibernate' ]; then
  systemctl hibernate
elif [ $choice = 'Sleep' ]; then
  systemctl sleep
elif [ $choice = 'Logout' ]; then
  niri msg action quit
fi
