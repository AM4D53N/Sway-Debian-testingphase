#!/bin/bash
######################################################################
#   Exit script for;                                                 #
#   Debian_Sway/.dots/sway/exit.sh                                   #
#                        +---------------+                           #
#                        | 'Debian-Sway' |                           #
#                        +---------------+                           #
#                                                                    #
#   This script was taken from:                                      #
#   learnlinux.tv/how-i-set-up-the-sway-window-manager-on-debian-12  #
#                                                                    #
######################################################################

if [[ ! $(pgrep -x "swaynag") ]]; then
    swaynag --background 333333 --border 333333 --border-bottom 333333 --button-background 1F1F1F \
        --button-border-size 0 --button-padding 8 --text FFFFFF --button-text FFFFFF --edge bottom \
        -t warning -m 'Do you really want to log out?' -B 'You heard me!' 'swaymsg exit'
fi
