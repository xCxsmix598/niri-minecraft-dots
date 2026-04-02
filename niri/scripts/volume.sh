#!/bin/bash

# Get current volume
get_volume() {
  wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'
}

# Check mute state
is_muted() {
  wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo "yes" || echo "no"
}

case "$1" in
up)
  wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
  ;;
down)
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
  ;;
mute)
  wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
  ;;
esac

VOL=$(get_volume)
MUTED=$(is_muted)

if [ "$MUTED" = "yes" ]; then
  ICON="audio-volume-muted-symbolic"
  TEXT="Muted"
elif [ "$VOL" -lt 30 ]; then
  ICON="audio-volume-low-symbolic"
  TEXT="Volume: ${VOL}"
elif [ "$VOL" -lt 70 ]; then
  ICON="audio-volume-medium-symbolic"
  TEXT="Volume: ${VOL}"
else
  ICON="audio-volume-high-symbolic"
  TEXT="Volume: ${VOL}"
fi

# Send notification (replace previous one using tag)
notify-send \
  -h string:x-canonical-private-synchronous:volume \
  -h int:value:"$VOL" \
  -i "$ICON" \
  "Volume" "$TEXT"
