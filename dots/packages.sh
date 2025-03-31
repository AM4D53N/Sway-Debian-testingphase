######################################################################
#  Packages for the installation of                                  #
#                        +---------------+                           #
#                        | 'Debian-Sway' |                           #
#                        +---------------+                           #
#  by: AM4D53N                                                       #
######################################################################

packages=(
######################################################################
#                       Core Sway Environment                        #
######################################################################
"sway"                   # | window manager
"swaybg"                 # | Utility to set background image
"swayimg"                # | Handles image displays
# "swaylock-effects"     # | Compiled from source in install.sh. Screen locker + Enhanced effects for the lock screen
"swayidle"               # | Inactivity daemon for auto-locking
"wayland"                # | Wayland display server protocol
"wayland-protocols"      # | Wayland protocol extensions
"xwayland"               # | Compatibility layer to run X11 applications on Wayland

######################################################################
#                      Status Bar and Launcher                       #
######################################################################
"waybar"                 # | Customizable status bar (with built-in calendar)
"wofi"                   # | Wayland-native application launcher

######################################################################
#                         Terminal and Editor                        #
######################################################################
"alacritty"              # | Terminal emulator
"micro"                  # | Simple terminal-based text editor
# "VSCode"               # | Compiled from source. Installation confirmed by user prompt in install.sh (IDE)
# "VSCodium"             # | Compiled from source. Installation confirmed by user prompt in install.sh (Free Open-Source alternative to VSCode)

######################################################################
#                            File Managers                           #
######################################################################
"ranger"                 # | TUI file manager
"thunar"                 # | GUI file manager

######################################################################
#                             Web Browser                            #
######################################################################
"firefox-esr"            # | Extended Support Release of Firefox

######################################################################
#                         Multimedia and Audio                       #
######################################################################
"playerctl"              # | Media control utility (integrates with Waybar)
"pipewire"               # | Modern multimedia server for audio (and video)
"wireplumber"            # | Session manager for Pipewire
"pavucontrol"            # | GUI to control audio devices
"vlc"                    # | For media playback, works with playerctl
# "Spotify"              # | Installation confirmed by user prompt in install.sh

######################################################################
#                   Brightness and Display Tools                     #
######################################################################
"brightnessctl"          # | Tool to control screen brightness

######################################################################
#                        Network and Bluetooth                       #
######################################################################
"network-manager-gnome"  # | Network management services. provides the network menu components, includes nm-applet (Tray applet)
"bluez"                  # | Bluetooth management tool
"bluez-tools"            # | Set of tools to manage Bluetooth devices.
"blueman"                # | GUI for 'BlueZ'
"libspa-0.2-bluetooth"   # | Bluetooth support for Pipewire.

######################################################################
#                           System Utilities                         #
######################################################################
"build-essential"        # | Essential tools for compiling software
"git"                    # | For working with GitHub
"unzip"                  # | File decompression tool
"wlr-randr"              # | CLI tool to manage Wayland outputs
"v4l-utils"              # | Utilities for managing webcams
"guvcview"               # | GUI for webcam viewing and control
"htop"                   # | Process viewer
"tldr"                   # | Simplified man pages for quick help
"curl"                   # | Command line tool and library for transferring data with URLs
"wget"                   # | Network downloader
"cmake"                  # | Build system generator
"meson"                  # | Build system for modern software
"libxkbcommon-dev"       # | Development files for libxkbcommon (keyboard handling library)
"libcairo2-dev"          # | Development files for Cairo graphics library
"libgdk-pixbuf2.0-dev"   # | Development files for GDK Pixbuf (image loading library)
"libpam0g-dev"           # | Development files for PAM (Pluggable Authentication Modules)
"scdoc"                  # | Tool for generating man pages

######################################################################
#                 Aesthetic and Interface Enhancements               #
######################################################################
"fonts-font-awesome"     # | Icon fonts for GUI apps (e.g. Waybar, Wofi)
"papirus-icon-theme"     # | Icon theme
# "grub-customizer"      # | Installation confirmed by user prompt in install.sh. Tool for customizing GRUB (nice to have for dual boot)
"nala"                   # | Modern and user-friendly apt frontend
)