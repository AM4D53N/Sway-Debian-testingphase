#!/bin/bash
######################################################################
#   Keyboard script for;                                             #
#                        +---------------+                           #
#                        | 'Debian-Sway' |                           #
#                        +---------------+                           #
#   by: AM4D53N                                                      #
######################################################################

LAYOUTS=("us" "dk" "de" "fr")

SELECTED_LAYOUT=$(printf "%s\n" "${LAYOUTS[@]}" | wofi --dmenu --prompt "Select Keyboard Layout")

if [[ -n "$SELECTED_LAYOUT" ]]; then
    swaymsg input "*" xkb_layout "$SELECTED_LAYOUT"
    notify-send "Keyboard Layout Changed" "Layout set to $SELECTED_LAYOUT"
fi