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
# Check for root privileges
#######################################################################
if [[ $EUID -ne 0 ]]; then
    printf "This script must be run with sudo, please enter your password.\n" >&2 
    exec sudo bash "$0" "$@"
fi
#######################################################################
# Update System
#######################################################################
printf "Starting setup...\n"

printf "Updating system...\n"
if ! (sudo apt update -yqq > /dev/null && sudo apt upgrade -qqy > /dev/null); then
    printf "Error: Failed to update system.\n" >&2
    exit 1
fi
#######################################################################
# Install Packages
#######################################################################
printf "Installing packages...\n"
source $SCRIPTPATH/dots/packages.sh
for package in "${packages[@]}"; do
    sudo apt install -yqq "$package" > /dev/null
done
#######################################################################
# Add Repository for Grub Theme
#######################################################################
read -n 1 -r -p "Are you planning on dual booting this device? [y/N]" input
if [[ "$input" =~ ^[Yy]$ ]]; then
    printf "Adding Bootloader theme...\n"
    sudo apt install -yqq grub-customizer > /dev/null    # Bootloader customization tool
    if ! wget -q -O- https://github.com/shvchk/poly-dark/raw/master/install.sh | bash -s -- --lang English > /dev/null; then
        printf "Failed to download bootloader theme, continuing without.\n"
    fi
else
    printf "Continuing without bootloader theme..\n"
fi
#######################################################################
# Compile swaylock-effects from Source
#######################################################################
printf "Compiling swaylock-effects...\n"
if ! ( git clone https://github.com/mortie/swaylock-effects.git /tmp/swaylock-effects > /dev/null &&
        cd /tmp/swaylock-effects &&
        make > /dev/null &&
        sudo make install > /dev/null ); then
    printf "Error: Failed to compile swaylock-effects.\n" >&2
else
    rm -rf /tmp/swaylock-effects
fi
#######################################################################
# Install VSCode or VSCodium (User Choice) (if compatible architecture)
#######################################################################
ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "amd64" ]; then
    printf "Micro is already installed on the system which can be used to write and edit code, but if you plan on larger programming tasks than editing the odd config file, you probably want a more complete IDE...\n"
    read -n 1 -r -p "Install 'VS Code' from microsoft [A], 'VS Codium' (an open-source alternative) [B], or skip [S]? [a/b/S] \n You can also press 'skip' [S] and download an alternative (IntelliJ, Geany, CodeLite, etc.) later on: " code_input
    if [[ "$code_input" =~ ^[Aa]$ ]]; then
        printf "Installing VSCode...\n"
        sudo apt install -yqq software-properties-common apt-transport-https wget > /dev/null
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -qq -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ > /dev/null
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        rm -f packages.microsoft.gpg
        sudo apt update -yqq > /dev/null
        sudo apt install -yqq code > /dev/null
    elif [[ "$code_input" =~ ^[Bb]$ ]]; then
        printf "Installing VSCodium...\n"
        sudo apt install -yqq wget gpg > /dev/null
        wget -qO- https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/repos/install.sh | sudo bash > /dev/null
        sudo apt update -yqq > /dev/null
        sudo apt install -yqq codium > /dev/null
    else
        printf "Skipping code editor installation.\n"
    fi
else
    printf "Micro is already installed on the system which can be used to write and edit code, but if you plan on larger programming tasks than editing the odd config file, you probably want a more complete IDE...\n"
    read -n 1 -r -p "Do you wish to install 'VS Code' from microsoft? [y/N] \n You can also press 'NO' [N] and download an alternative (IntelliJ, Geany, Code Lite, etc.) later on: " code_input_2
    if [[ "$code_input_2" =~ ^[Yy]$ ]]; then
        printf "Installing VSCode...\n"
        sudo apt install -yqq software-properties-common apt-transport-https wget > /dev/null
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -qq -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ > /dev/null
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        rm -f packages.microsoft.gpg
        sudo apt update -yqq > /dev/null
        sudo apt install -yqq code > /dev/null
    else
        printf "Skipping code editor installation.\n"
    fi
fi
#######################################################################
# Install Spotify (User Choice)
#######################################################################
read -n 1 -r -p "Install Spotify? [y/N] " spotify_input
echo
if [[ "$spotify_input" =~ ^[Yy]$ ]]; then
    printf "Installing Spotify...\n"
    sudo apt install -yqq curl gpg > /dev/null
    curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor -o /usr/share/keyrings/spotify-archive-keyring.gpg > /dev/null
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list > /dev/null
    sudo apt update -yqq > /dev/null
    sudo apt install -yqq spotify-client > /dev/null
else
    printf "Skipping Spotify installation.\n"
fi
#######################################################################
# Create Necessary Configuration Directories
#######################################################################
printf "Creating configuration directories...\n"
mkdir -p $HOME/.config/{sway,waybar,alacritty,wofi}
#######################################################################
# Configure shell Prompt
#######################################################################
printf "Configuring shell prompt...\n"
if curl -sS https://starship.rs/install.sh | sh > /dev/null; then
    if command -v starship >/dev/null; then
        starship preset tokyo-night -o $HOME/.config/starship.toml > /dev/null
    else
        printf "Error: Starship installation failed.\n" >&2
    fi
else
    printf "Error: Failed to download Starship.\n" >&2
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
cp $SCRIPTPATH/dots/alacritty/alacritty.toml $HOME/.config/alacritty/alacritty.toml
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
find $HOME/.config/sway -type f -name "*.sh" -exec chmod +x {} + > /dev/null
chmod +x $HOME/.config/waybar/menu.sh
#######################################################################
# Enable Firewall (UFW)
#######################################################################
printf "Configuring firewall...\n"

# Check if UFW is installed
if ! command -v ufw &> /dev/null; then
    sudo apt install -yqq ufw > /dev/null
fi

# Set explicit default policies
sudo ufw default deny incoming > /dev/null
sudo ufw default allow outgoing > /dev/null

# Check for active SSH connection
if [ -n "$SSH_CLIENT" ]; then
    printf "Allowing incoming SSH connections since the script is run via SSH.\n"
    sudo ufw limit ssh comment 'Rate limit SSH to prevent brute-force attacks' > /dev/null
else
    printf "You do not seem to be connecting to this device via SSH.\n"
    read -p "Do you want to allow incoming SSH connections? (y/N): " allow_ssh
    if [[ $allow_ssh =~ ^[Yy]$ ]]; then
        sudo ufw limit ssh comment 'Rate limit SSH to prevent brute-force attacks' > /dev/null
        printf "SSH allowed with rate limiting.\n"
    else
        printf "Incoming SSH blocked in firewall.\n"
    fi
fi

# Enable logging
sudo ufw logging on > /dev/null

# Enable firewall without prompting
sudo ufw --force enable > /dev/null

# Provide status and guidance
printf "Firewall enabled with defaults: incoming blocked (except allowed services), outgoing allowed.\n"
printf "SSH is %s with rate limiting.\n" "$(if ufw status | grep -q "22/tcp"; then echo "allowed"; else echo "blocked"; fi)"
printf "To allow additional services (e.g., file sharing), use 'sudo ufw allow <service>'.\n"
printf "For example, to allow Samba for file sharing, use 'sudo ufw allow samba'.\n"
#######################################################################
# Final Reboot Prompt
#######################################################################
sudo apt autoremove -yqq > /dev/null
printf "Installation complete! \n"
printf "Reboot system for all changes to take place.\n"
rebootfunc(){
    read -n 1 -r -p "Do you want to reboot now? (to avoid the installation-files self-deleting press [Q] to quit) [y/n/Q] " input
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
