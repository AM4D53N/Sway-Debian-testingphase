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
SCRIPTPATH=$(realpath "$0") # Where did they save me?
USERID=$(whoami) # Who are you?
USERHOME=$(grep "^$USERID:" /etc/passwd | cut -d: -f6) # Where do you live? (Just to be sure that sudo doesn't make script think your home is /root/)

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
if ! sudo apt update -yqq || ! sudo apt upgrade -qqy; then
    printf "Error: Failed to update system.\n" >&2
    exit 1
fi
#######################################################################
# Install Packages
#######################################################################
printf "Installing packages...\n"
source $SCRIPTPATH/dots/packages.sh
for package in "${packages[@]}"; do
    sudo apt install -yqq "$package"
done
#######################################################################
# Add Repository for Grub Theme
#######################################################################
read -n 1 -r -p "Are you planning on dual booting this device? (Y/n)" input
if [[ "$input" =~ ^[Yy]$ ]]; then
    printf "Adding Bootloader theme...\n"
    sudo apt install -yqq grub-customizer     # Bootloader customization tool
    if ! wget -q -O- https://github.com/shvchk/poly-dark/raw/master/install.sh | bash -s -- --lang English; then
        printf "Failed to download bootloader theme, continuing without.\n"
    fi
else
    printf "Continuing without bootloader theme..\n"
fi
#######################################################################
# Compile swaylock-effects from Source
#######################################################################
printf "Compiling swaylock-effects...\n"
if ! ( git clone https://github.com/mortie/swaylock-effects.git /tmp/swaylock-effects &&
        cd /tmp/swaylock-effects &&
        make &&
        sudo make install ); then
    printf "Error: Failed to compile swaylock-effects.\n" >&2
else
    rm -rf /tmp/swaylock-effects
fi
#######################################################################
# Install VSCode or VSCodium (User Choice) (if compatible architecture)
#######################################################################
ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "amd64" ]; then
    read -n 1 -r -p "Install VSCode (Y), VSCodium (N), or skip (S)? (Y/n/s) " code_input
    if [[ "$code_input" =~ ^[Yy]$ ]]; then
        # Install VSCode using the official Microsoft repository
        printf "Installing VSCode...\n"
        sudo apt install -yqq software-properties-common apt-transport-https wget
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        rm packages.microsoft.gpg
        echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
        sudo apt update -yqq
        sudo apt install -yqq code
    elif [[ "$code_input" =~ ^[Nn]$ ]]; then
        # Install VSCodium using its official repository install script
        printf "Installing VSCodium...\n"
        sudo apt install -yqq wget gpg
        wget -qO- https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/repos/install.sh | sudo bash
        sudo apt update -yqq
        sudo apt install -yqq codium
    else
        printf "Skipping code editor installation.\n"
    fi
fi
#######################################################################
# Install Spotify (User Choice)
#######################################################################
read -n 1 -r -p "Install Spotify? (Y/n) " spotify_input
echo
if [[ "$spotify_input" =~ ^[Yy]$ ]]; then
    printf "Installing Spotify...\n"
    sudo apt install -yqq curl gpg
    curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor -o /usr/share/keyrings/spotify-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/spotify-archive-keyring.gpg] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update -yqq
    sudo apt install -yqq spotify-client
else
    printf "Skipping Spotify installation.\n"
fi
#######################################################################
# Create Necessary Configuration Directories
#######################################################################
printf "Creating configuration directories...\n"
mkdir -p $USERHOME/.config/{sway,waybar,alacritty,wofi}
#######################################################################
# Configure shell Prompt
#######################################################################
printf "Configuring shell prompt...\n"
if curl -sS https://starship.rs/install.sh | sh; then
    if command -v starship >/dev/null; then
        starship preset tokyo-night -o $USERHOME/.config/starship.toml
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
WALLPAPER_PATH="$USERHOME/.config/sway/wallpaper.jpg"

if ! curl -L "$WALLPAPER_URL" -o "$WALLPAPER_PATH"; then
    printf "Error: Failed to download wallpaper.\n" >&2
fi
#######################################################################
# Configure Sway
#######################################################################
printf "Configuring Window Manager...\n"
cp $SCRIPTPATH/dots/sway/config $USERHOME/.config/sway/config
cp $SCRIPTPATH/dots/sway/audio.sh $USERHOME/.config/sway/audio.sh
cp $SCRIPTPATH/dots/sway/exit.sh $USERHOME/.config/sway/exit.sh
cp $SCRIPTPATH/dots/sway/lock.sh $USERHOME/.config/sway/lock_screen.sh
#######################################################################
# Configure Waybar
#######################################################################
printf "Configuring taskbar...\n"
cp $SCRIPTPATH/dots/waybar/config $USERHOME/.config/waybar/config
cp $SCRIPTPATH/dots/waybar/style.css $USERHOME/.config/waybar/style.css
cp $SCRIPTPATH/dots/waybar/menu.sh $USERHOME/.config/waybar/menu.sh
#######################################################################
# Configure Alacritty
#######################################################################
printf "Configuring terminal...\n"
cp $SCRIPTPATH/dots/alacritty/alacritty.toml $USERHOME/.config/alacritty/alacritty.toml
#######################################################################
# Configure Wofi
#######################################################################
printf "Configuring application launcher...\n"
cp $SCRIPTPATH/dots/wofi/config $USERHOME/.config/wofi/config
cp $SCRIPTPATH/dots/wofi/style.css $USERHOME/.config/wofi/style.css
#######################################################################
# Set Executable Permissions for Scripts
#######################################################################
printf "Setting executable permissions for scripts...\n"
find $USERHOME/.config/sway -type f -name "*.sh" -exec chmod +x {} +
#######################################################################
# Enable Firewall (UFW)
#######################################################################
printf "Configuring firewall...\n"

# Check if UFW is installed
if ! command -v ufw &> /dev/null; then
    sudo apt install -yqq ufw
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
    read -p "Do you want to allow incoming SSH connections? (y/N): " allow_ssh
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
sudo apt autoremove -yqq
printf "Installation complete! \n"
printf "Reboot system for all changes to take place.\n"
rebootfunc(){
    read -n 1 -r -p "Do you want to reboot now? (Y/n) " input
    if [[ "$input" =~ ^[Yy]$ ]]; then
        printf "Rebooting now...\n"
        printf "The installation files will self-delete in 5 seconds \n"
        sleep 2    # Giving the user a chance to ^C in case they don't want the installation files to self-delete
        clear && printf "3.." && sleep 1
        clear && printf "2.." && sleep 1
        clear && printf "1.." && sleep 1
        cd $USERHOME # Move to safety to ensure user is not in dir while it's deleted
        sudo rm -fr $SCRIPTPATH && sudo reboot
    elif [[ "$input" =~ ^[Nn]$ ]]; then
        printf "Reboot aborted. Some changes won't take place until system is rebooted\n"
        printf "The installation files will self-delete in 5 seconds \n"
        sleep 2    # Giving the user a chance to ^C in case they don't want the installation files to self-delete
        clear && printf "3.." && sleep 1
        clear && printf "2.." && sleep 1
        clear && printf "1.." && sleep 1
        cd $USERHOME # Move to safety to ensure user is not in dir while it's deleted
        sudo rm -fr $SCRIPTPATH
    elif [[ "$input" =~ ^[Qq]$ ]]; then
        exit 0
    else
        clear
        rebootfunc
    fi
}
rebootfunc