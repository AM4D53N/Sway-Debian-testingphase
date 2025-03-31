#!/bin/bash
######################################################################
#   Installation script for the installation of;                     #
#                        +---------------+                           #
#                        | 'Sway-Debian' |                           #
#                        +---------------+                           #
#                                                                    #
#   by: AM4D53N                                                      #
######################################################################

#######################################################################
# Defining script constants
#######################################################################
SCRIPTPATH=$(dirname "$0") # Where did they save me?

#######################################################################
# Check for root privileges, lets see if nesecary, dont want more /root/ issues.
#######################################################################
#if [[ $EUID -ne 0 ]]; then
#    printf "This script must be run with sudo, please enter your password.\n" >&2 
#    exec sudo bash "$0" "$@"
#fi
#######################################################################
# Update System
#######################################################################
printf "Starting setup...\n"

printf "Updating system...\n"
if ! (sudo apt-get update -qqy && sudo apt-get upgrade -qqy); then
    printf "Error: Failed to update system.\n" >&2
    exit 1
fi
#######################################################################
# Install Packages
#######################################################################
printf "Installing packages...\n"
source $SCRIPTPATH/dots/packages.sh
for package in "${packages[@]}"; do
    if "sudo apt-get install -yqq "$package""; then
        printf "Installed $package successfully.\n"
    else
        printf "Error: Failed to install $package.\n" >&2
    fi
done

#######################################################################
# Install Iosevka Nerd Font
#######################################################################
printf "Installing Iosevka Nerd Font...\n"
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if wget -q -O "$FONT_DIR/IosevkaNerdFont.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Iosevka.zip && \
    unzip -q -o "$FONT_DIR/IosevkaNerdFont.zip" -d "$FONT_DIR" > /dev/null && \
    fc-cache -fv > /dev/null; then
    printf "Iosevka Nerd Font installed successfully.\n"
else
    printf "Error: Failed to download or install Iosevka Nerd Font.\n" >&2
fi

#######################################################################
# Add Repository for Grub Theme
#######################################################################
read -n 1 -r -p "Are you planning on dual booting this device? [y/N] " input
if [[ "$input" =~ ^[Yy]$ ]]; then
    printf "Adding Bootloader theme...\n"
    sudo apt-get install -yqq grub-customizer    # Bootloader customization tool
    if ! wget -q -O- https://github.com/shvchk/poly-dark/raw/master/install.sh | bash -s -- --lang English; then
        printf "Failed to download bootloader theme, continuing without.\n"
    else
        # Set GRUB timeout to -1
        sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=-1/' /etc/default/grub
        sudo update-grub
    fi
else
    printf "Continuing without bootloader theme...\n"
fi
#######################################################################
# Compile swaylock-effects from Source
#######################################################################
printf "Compiling swaylock-effects...\n"

# Install required dependencies
printf "Installing dependencies for swaylock-effects...\n"

# Clone, build, and install swaylock-effects
if ! ( git clone https://github.com/mortie/swaylock-effects.git /tmp/swaylock-effects &&
        cd /tmp/swaylock-effects &&
        meson build &&
        ninja -C build &&
        sudo ninja -C build install ); then
    printf "Error: Failed to compile swaylock-effects.\n" >&2
else
    printf "swaylock-effects compiled and installed successfully.\n"
    rm -rf /tmp/swaylock-effects
fi

# On systems without PAM, set suid for swaylock binary
if ! dpkg -l | grep -q libpam0g; then
    printf "PAM not detected. Setting suid for swaylock binary...\n"
    sudo chmod a+s /usr/local/bin/swaylock
fi
#######################################################################
# Install VSCode or VSCodium (User Choice) (if compatible architecture)
#######################################################################
# ARCH=$(dpkg --print-architecture)
# if [ "$ARCH" = "amd64" ]; then
#     printf "Micro is already installed on the system which can be used to write and edit code, but if you plan on larger programming tasks than editing the odd config file, you probably want a more complete IDE...\n"
#     read -n 1 -r -p "Install 'VS Code' from microsoft [A], 'VS Codium' (an open-source alternative) [B], or skip [S]? [a/b/S] \n You can also press 'skip' [S] and download an alternative (IntelliJ, Geany, CodeLite, etc.) later on: " code_input
#     if [[ "$code_input" =~ ^[Aa]$ ]]; then
#         printf "Installing VSCode...\n"
#         sudo apt-get install -yqq software-properties-common apt-transport-https wget > /dev/null
#         wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
#         sudo install -qq -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ > /dev/null
#         echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
#         rm -f packages.microsoft.gpg
#         sudo apt-get update -yqq > /dev/null
#         sudo apt-get install -yqq code > /dev/null
#     elif [[ "$code_input" =~ ^[Bb]$ ]]; then
#         printf "Installing VSCodium...\n"
#         sudo apt-get install -yqq wget gpg > /dev/null
#         wget -qO- https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/repos/install.sh | sudo bash > /dev/null
#         sudo apt-get update -yqq > /dev/null
#         sudo apt-get install -yqq codium > /dev/null
#     else
#         printf "Skipping code editor installation.\n"
#     fi
# else
#     printf "Micro is already installed on the system which can be used to write and edit code, but if you plan on larger programming tasks than editing the odd config file, you probably want a more complete IDE...\n"
#     read -n 1 -r -p "Do you wish to install 'VS Code' from microsoft? [y/N] \n You can also press 'NO' [N] and download an alternative (IntelliJ, Geany, Code Lite, etc.) later on: " code_input_2
#     if [[ "$code_input_2" =~ ^[Yy]$ ]]; then
#         printf "Installing VSCode...\n"
#         sudo apt-get install -yqq software-properties-common apt-transport-https wget > /dev/null
#         wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
#         sudo install -qq -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ > /dev/null
#         echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
#         rm -f packages.microsoft.gpg
#         sudo apt-get update -yqq > /dev/null
#         sudo apt-get install -yqq code > /dev/null
#     else
#         printf "Skipping code editor installation.\n"
#     fi
# fi
# #######################################################################
# # Install Spotify (User Choice)
# #######################################################################
# read -n 1 -r -p "Install Spotify? [y/N] " spotify_input
# echo
# if [[ "$spotify_input" =~ ^[Yy]$ ]]; then
#     printf "Installing Spotify...\n"
#     sudo apt-get install -yqq curl gpg > /dev/null
#     curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor -o /usr/share/keyrings/spotify-archive-keyring.gpg > /dev/null
#     echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list > /dev/null
#     sudo apt-get update -yqq > /dev/null
#     sudo apt-get install -yqq spotify-client > /dev/null
# else
#     printf "Skipping Spotify installation.\n"
# fi
#######################################################################
# Create Necessary Configuration Directories
#######################################################################
printf "Creating configuration directories...\n"
mkdir -p $HOME/.config/{sway,waybar,alacritty,wofi}
#######################################################################
# Configure shell Prompt
#######################################################################
printf "Configuring shell prompt...\n"
if curl -sS https://starship.rs/install.sh | sh; then
    if command -v starship > /dev/null; then
        # Download the Tokyo Night preset and save it to the Starship configuration file
        curl -sS https://starship.rs/presets/toml/tokyo-night.toml -o $HOME/.config/starship.toml
        printf "Starship prompt configured with the Tokyo Night preset.\n"
    else
        printf "Error: Starship installation failed.\n" >&2
    fi
else
    printf "Error: Failed to download Starship.\n" >&2
fi
# Enable Starship in Bash
if command -v starship > /dev/null; then
    if ! grep -q 'eval "$(starship init bash)"' "$HOME/.bashrc"; then
        echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
        printf "Starship prompt enabled for Bash.\n"
    else
        printf "Starship prompt is already enabled for Bash.\n"
    fi
fi
#######################################################################
# Set Wallpaper for Sway
#######################################################################
printf "Downloading wallpaper...\n"
WALLPAPER_URL="https://images.wallpapersden.com/image/download/sunset-scenery-minimal_am1uZmiUmZqaraWkpJRmbmdlrWZlbWU.jpg"
WALLPAPER_PATH="$HOME/.config/sway/wallpaper.jpg"

if ! curl -L "$WALLPAPER_URL" -o "$WALLPAPER_PATH" > /dev/null; then
    printf "Error: Failed to download wallpaper.\n" >&2
fi
#######################################################################
# Configure Sway
#######################################################################
printf "Configuring Window Manager...\n"
cp $SCRIPTPATH/dots/sway/config $HOME/.config/sway/config
cp $SCRIPTPATH/dots/sway/audio.sh $HOME/.config/sway/audio.sh
cp $SCRIPTPATH/dots/sway/exit.sh $HOME/.config/sway/exit.sh
cp $SCRIPTPATH/dots/sway/lock.sh $HOME/.config/sway/lock_screen.sh
cp $SCRIPTPATH/dots/sway/change_keyboard.sh $HOME/.config/sway/change_keyboard.sh
#######################################################################
# Configure Waybar
#######################################################################
printf "Configuring taskbar...\n"
cp $SCRIPTPATH/dots/waybar/config $HOME/.config/waybar/config
cp $SCRIPTPATH/dots/waybar/style.css $HOME/.config/waybar/style.css
cp $SCRIPTPATH/dots/waybar/menu.sh $HOME/.config/waybar/menu.sh
#######################################################################
# Configure Alacritty
#######################################################################
printf "Configuring terminal...\n"
cp $SCRIPTPATH/dots/alacritty/alacritty.yml $HOME/.config/alacritty/alacritty.yml
#######################################################################
# Configure Wofi
#######################################################################
printf "Configuring application launcher...\n"
cp $SCRIPTPATH/dots/wofi/config $HOME/.config/wofi/config
cp $SCRIPTPATH/dots/wofi/style.css $HOME/.config/wofi/style.css
#######################################################################
# Set Executable Permissions for Scripts
#######################################################################
printf "Setting executable permissions for scripts...\n"
chmod +x $HOME/.config/*/*.sh
#######################################################################
# Automate Sway Startup on TTY1
#######################################################################
printf "Configuring Sway to start automatically on TTY1...\n"

# Define the configuration to add
SWAY_STARTUP_CONFIG='
# Start Sway automatically on TTY1
if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
    exec sway
fi
'
# Check if the configuration already exists in ~/.bash_profile or ~/.bashrc
if ! grep -q "exec sway" "$HOME/.bash_profile" 2>/dev/null && ! grep -q "exec sway" "$HOME/.bashrc" 2>/dev/null; then
    # Append the configuration to ~/.bash_profile (or create it if it doesn't exist)
    if [ -f "$HOME/.bash_profile" ]; then
        echo "$SWAY_STARTUP_CONFIG" >> "$HOME/.bash_profile"
    else
        echo "$SWAY_STARTUP_CONFIG" >> "$HOME/.bashrc"
    fi
    printf "Sway startup configuration added to your shell profile.\n"
else
    printf "Sway startup configuration already exists. Skipping...\n"
fi
#######################################################################
# Configure Aliases
#######################################################################
printf "Configuring aliases...\n"

# Check if ~/.bash_aliases exists
if [ ! -f "$HOME/.bash_aliases" ]; then
    # Create ~/.bash_aliases and add aliases
    cat << 'EOF' > "$HOME/.bash_aliases"
# Custom Aliases
alias ll="ls -al --color=always"
alias la="ls -a --color=always"
alias update="sudo apt-get update && sudo apt-get upgrade -y"
alias reboot="sudo systemctl reboot"
alias shutdown="sudo systemctl poweroff"
alias _="sudo "
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias grep="grep --color=auto"
alias nano="micro"
alias py="python3"
alias pip="pip3"
alias apt="sudo nala"
alias nala="sudo nala"
EOF
fi # if .bash_aliases exists, do nothing, since the user might have their own aliases
#######################################################################
# Enable Firewall (UFW)
#######################################################################
printf "Configuring firewall...\n"

# Check if UFW is installed
if ! command -v ufw &> /dev/null; then
    sudo apt-get install -yqq ufw
fi

# Set explicit default policies
sudo ufw default deny incoming 
sudo ufw default allow outgoing

# Check for active SSH connection
if [ -n "$SSH_CLIENT" ]; then
    printf "Allowing incoming SSH connections since the script is run via SSH.\n"
    sudo ufw limit ssh comment 'Rate limit SSH to prevent brute-force attacks'
else
    printf "You do not seem to be connecting to this device via SSH.\n"
    read -p "Do you want to allow incoming SSH connections? [y/N]: " allow_ssh
    if [[ $allow_ssh =~ ^[Yy]$ ]]; then
        sudo ufw limit ssh comment 'Rate limit SSH to prevent brute-force attacks'
        printf "SSH allowed with rate limiting.\n"
    else
        printf "Incoming SSH blocked in firewall.\n"
    fi
fi

# Enable logging
sudo ufw logging on

# Enable firewall without prompting
sudo ufw --force enable

# Provide status and guidance
printf "Firewall enabled with defaults: incoming blocked (except allowed services), outgoing allowed.\n"
printf "SSH is %s with rate limiting.\n" "$(if ufw status | grep -q "22/tcp"; then echo "allowed"; else echo "blocked"; fi)"
printf "To allow additional services (e.g., file sharing), use 'sudo ufw allow <service>'.\n"
printf "For example, to allow Samba for file sharing, use 'sudo ufw allow samba'.\n"
#######################################################################
# Final Reboot Prompt
#######################################################################
sudo apt-get autoremove -yqq 
printf "Installation complete! \n"
printf "Reboot system for all changes to take place.\n"
rebootfunc(){
    read -n 1 -r -p "Do you want to reboot now? (to avoid the installation-files self-deleting press [Q] to quit, then reboot manually when you're ready) [y/n/Q] " input
    if [[ "$input" =~ ^[Yy]$ ]]; then
        printf "Rebooting now...\n"
        printf "The installation files will self-delete in 5 seconds \n"
        sleep 2    # Giving the user a chance to ^C in case they don't want the installation files to self-delete
        clear && printf "3.." && sleep 1
        clear && printf "2.." && sleep 1
        clear && printf "1.." && sleep 1
        cd $HOME # Move to safety to ensure user is not in dir while it's deleted
        sudo rm -fr $SCRIPTPATH && sudo reboot
    elif [[ "$input" =~ ^[Nn]$ ]]; then
        printf "Reboot aborted. Some changes won't take place until system is rebooted\n"
        printf "The installation files will self-delete in 5 seconds \n"
        sleep 2    # Giving the user a chance to ^C in case they don't want the installation files to self-delete
        clear && printf "3.." && sleep 1
        clear && printf "2.." && sleep 1
        clear && printf "1.." && sleep 1
        cd $HOME # Move to safety to ensure user is not in dir while it's deleted
        sudo rm -fr $SCRIPTPATH
    elif [[ "$input" =~ ^[Qq]$ ]]; then
        exit 0
    else
        clear
        rebootfunc
    fi
}
rebootfunc
