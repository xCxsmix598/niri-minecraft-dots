#!/bin/bash

get_percent() {
  current=$(brightnessctl get)
  max=$(brightnessctl max)
  echo $((current * 100 / max))
}

case "$1" in
up)
  brightnessctl set +5%
  ;;
down)
  brightnessctl set 5%-
  ;;
esac

PERCENT=$(get_percent)

# Choose icon based on brightness
if [ "$PERCENT" -eq 0 ]; then
  ICON="display-brightness-off-symbolic"
elif [ "$PERCENT" -lt 30 ]; then
  ICON="display-brightness-low-symbolic"
elif [ "$PERCENT" -lt 70 ]; then
  ICON="display-brightness-medium-symbolic"
else
  ICON="display-brightness-high-symbolic"
fi

notify-send \
  -h string:x-canonical-private-synchronous:brightness \
  -h int:value:"$PERCENT" \
  -h string:class:brightness \
  -i "$ICON" \
  "Brightness" "${PERCENT}%"
