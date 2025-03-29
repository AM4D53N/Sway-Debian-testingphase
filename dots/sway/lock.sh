#!/bin/bash

######################################################################
#   Installation script for the installation of;                     #
#   Debian_Sway/.dots/sway/lock.sh                                   #
#                        +---------------+                           #
#                        | 'Debian-Sway' |                           #
#                        +---------------+                           #
#                                                                    #
#   by: AM4D53N                                                      #
#                                                                    #
#   This script was taken from:                                      #
#   https://code.krister.ee/lock-screen-in-sway/                     #
#                                                                    #
######################################################################

# Start a background process to manage DPMS:
# - Turns off the outputs after 10 seconds (idle)
# - Restores outputs when activity resumes
swayidle \
    timeout 10 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' &

# Launch the fancy lock screen with effects (requires swaylock-effects)
swaylock --clock --indicator --screenshots \
    --effect-scale 0.4 \
    --effect-vignette 0.2:0.5 \
    --effect-blur 8x4 \
    --datestr "%a %e.%m.%Y" \
    --timestr "%k:%M"

# Terminate the background swayidle process so it does not interfere after locking
kill %%
