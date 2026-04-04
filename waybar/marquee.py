import subprocess
import time
import sys

# Settings
MAX_LEN = 30
SPEED = 0.2  # Seconds between frames
EMPTY_TEXT = ""


def get_metadata():
    try:
        # Get title and artist
        cmd = "playerctl metadata --format '{{title}} - {{artist}}'"
        result = subprocess.check_output(
            cmd, shell=True).decode('utf-8').strip()
        return result if result else EMPTY_TEXT
    except subprocess.CalledProcessError:
        # This happens if no player is running
        return EMPTY_TEXT


def main():
    offset = 0

    while True:
        full_text = get_metadata()

        if len(full_text) <= MAX_LEN:
            # If it fits, just print it plain
            sys.stdout.write(f"{full_text}\n")
        else:
            # Add a spacer for the loop
            scroll_text = full_text + " | "

            # Calculate the frame
            # The modulo (%) keeps the offset within the bounds of the string
            start = offset % len(scroll_text)
            display = (scroll_text + scroll_text)[start: start + MAX_LEN]

            sys.stdout.write(f"{display}\n")
            offset += 1

        sys.stdout.flush()
        time.sleep(SPEED)


if __name__ == "__main__":
    main()
