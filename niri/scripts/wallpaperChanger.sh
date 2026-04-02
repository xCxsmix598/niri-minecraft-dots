#!/bin/bash

# --- Configuration ---
# Change this to the path of your wallpaper folder
WALLPAPER_DIR="$HOME/.wallpapers"
HISTORY_FILE="$HOME/.cache/wallpaper_history"

# --- Dependencies Check ---
# Ensure required tools are installed
for cmd in awww matugen; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is not installed."
    exit 1
  fi
done

# Ensure history file exists
touch "$HISTORY_FILE"

# Initialize awww if it's not running
if ! pgrep -x "awww-daemon" >/dev/null; then
  awww-daemon &
  sleep 0.5
fi

# --- Script Logic ---

# 1. Get list of all valid images
ALL_WALLPAPERS=$(find "$WALLPAPER_DIR" -type f | grep -E "\.(jpg|jpeg|png|webp)$" | sort)

# 2. Filter out wallpapers already in the history file
REMAINING=$(grep -vFf "$HISTORY_FILE" <<<"$ALL_WALLPAPERS")

# 3. If no wallpapers are left, reset the history
if [ -z "$REMAINING" ]; then
  echo "Cycle complete. Resetting history..."
  >"$HISTORY_FILE"
  REMAINING="$ALL_WALLPAPERS"
fi

# 4. Pick a random wallpaper from the remaining list
WALLPAPER=$(shuf -n 1 <<<"$REMAINING")

if [ -z "$WALLPAPER" ]; then
  echo "No wallpapers found in $WALLPAPER_DIR"
  exit 1
fi

# 5. Save the choice to history
echo "$WALLPAPER" >>"$HISTORY_FILE"

# 6. Set the wallpaper
# Using awww to apply the image
# 7. Generate colors with matugen
# 'image' mode extracts colors from the file
matugen image "$WALLPAPER" --source-color-index 0

killall -9 waybar
sleep 3
waybar &
disown

echo "Wallpaper changed to: $(basename "$WALLPAPER")"
echo "Progress: $(wc -l <"$HISTORY_FILE") / $(echo "$ALL_WALLPAPERS" | wc -l)"
