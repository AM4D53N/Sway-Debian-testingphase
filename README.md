# Work in progress, do not run install
# Sway-Debian

Sway-Debian is a lightweight and customizable Debian-based environment featuring the Sway window manager. This setup is designed to provide a modern, efficient, and visually appealing desktop experience tailored for Wayland.

---

## Features

- **Sway Window Manager**: A tiling Wayland compositor inspired by i3.
- **Waybar**: A customizable status bar with built-in calendar and system information.
- **Wofi**: A Wayland-native application launcher.
- **Alacritty**: A fast and GPU-accelerated terminal emulator.
- **Custom Styling**: Preconfigured themes for Waybar, Sway, and other components.
- **Starship Prompt**: A minimal and customizable shell prompt with the Tokyo Night preset.
- **Firewall Configuration**: UFW (Uncomplicated Firewall) is preconfigured for security.
- **Optional Software**: Includes options for VSCode, VSCodium, Spotify, and more.

---

## Installation

### Prerequisites

- A fresh installation of Debian (or a Debian-based distribution).
- Internet access for downloading packages and dependencies.

### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/AM4D53N/Sway-Debian.git
   cd Sway-Debian
   chmod +x install.sh
   ./install.sh
   ```

2. Follow the prompts during installation to configure optional components like:
   - Bootloader theme (for dual-boot setups).
   - VSCode or VSCodium.
   - Spotify.

3. Reboot the system after installation to apply all changes:
   ```bash
   sudo reboot
   ```

---

## Components

### Core Environment
- **Sway**: Tiling window manager for Wayland.
- **Swaylock-effects**: Enhanced lock screen with effects (compiled from source).
- **Swayidle**: Inactivity daemon for auto-locking.

### Status Bar and Launcher
- **Waybar**: Customizable status bar with preconfigured styles.
- **Wofi**: Application launcher for Wayland.

### Terminal and Editor
- **Alacritty**: GPU-accelerated terminal emulator.
- **Micro**: A lightweight terminal-based text editor.
- **VSCode/VSCodium**: Optional IDEs for development.

### Additional Features
- **Starship Prompt**: Configured with the Tokyo Night preset for a modern shell experience.
- **Firewall**: UFW is preconfigured with secure defaults.

---

## Customization

### Waybar
- Configuration files are located in `~/.config/waybar/`.
- Modify `config` and `style.css` to customize the appearance and behavior.

### Sway
- Configuration files are located in `~/.config/sway/`.
- Modify `config` to adjust keybindings, layouts, and other settings.

### Starship Prompt
- Configuration file is located at `~/.config/starship.toml`.
- Modify this file to customize the shell prompt.

---

## Screenshots

![Sway-Debian Desktop](https://via.placeholder.com/800x450?text=Sway-Debian+Desktop)
*Example of the Sway-Debian desktop environment with Waybar and custom wallpaper.*

---

## Troubleshooting

### Common Issues
- **Missing Dependencies**: Ensure your system is up-to-date before running the script:
  ```bash
  sudo apt update && sudo apt upgrade
  ```
- **Wayland Compatibility**: Ensure your hardware supports Wayland. Older GPUs may not work well with Wayland.

### Logs
- Check the installation logs for errors:
  ```bash
  less /var/log/apt/history.log
  ```

---

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests to improve the project.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Credits

- **Author**: AM4D53N
- **Special Thanks**:
  - [Roboron3042](https://github.com/Roboron3042) for the Cyberpunk-Neon Alacritty theme.
  - [LearnLinux.tv](https://learnlinux.tv) for inspiration and guidance on setting up Sway on Debian.
  - [Krister.ee](https://code.krister.ee) for the lock screen script.
  - The open-source community for providing the tools and inspiration for this project.

