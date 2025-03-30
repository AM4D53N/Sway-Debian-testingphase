#!/bin/bash
######################################################################
#   Waybar menu script for;                                          #
#                        +---------------+                           #
#                        | 'Sway-Debian' |                           #
#                        +---------------+                           #
#   by: AM4D53N                                                      #
######################################################################
# Define menu options
OPTIONS="Shutdown\nReboot\nLock Screen"

# Display menu using wofi and capture the selected option
CHOICE=$(echo -e "$OPTIONS" | wofi --dmenu --prompt "Power Menu")

# Execute the chosen action
case "$CHOICE" in
    "Shutdown")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Lock Screen")
        bash ~/.config/sway/lock.sh
        ;;
    *)
        exit 1  # Exit if no valid option is selected (e.g., menu closed)
        ;;
esac
