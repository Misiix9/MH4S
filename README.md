# MH4S - Modern Hyprland for Simplicity

A modern, minimal, and user-friendly Hyprland configuration with a complete installer script.

## Features

### Core Components
- **Hyprland** - Modern Wayland compositor
- **Waybar** - Customizable status bar
- **Kitty** - GPU-accelerated terminal
- **Rofi** - Application launcher and system menus
- **SDDM** - Display manager with custom theme

### Appearance
- Clean black & white theme
- Rounded corners and subtle transparency
- Smooth animations
- Lexend font throughout the system
- Consistent GTK and Qt theming
- Custom SDDM login screen

### Functionality
- Intelligent window management
- Dynamic workspace handling
- Rich system utilities
- Comprehensive keybindings
- Integrated clipboard manager
- Advanced screenshot tools
- Automatic wallpaper switching

### Utilities
- **Network Manager** - WiFi and connection management
- **Bluetooth Manager** - Device pairing and control
- **Audio Manager** - Volume and device control
- **Screenshot Tool** - Area, window, and screen capture
- **Clipboard Manager** - History and quick access
- **System Menu** - Unified control center
- **Wallpaper Manager** - GUI wallpaper selector

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Misiix9/MH4S.git
   cd MH4S
   ```

2. Run the installer:
   ```bash
   cd installer
   ./main.sh
   ```

3. Follow the interactive prompts to:
   - Install base system components
   - Set up themes and configurations
   - Install additional applications
   - Configure user preferences

## Keybindings

### Core
- `Super + Return` - Open terminal
- `Super + A` - Application launcher
- `Super + Q` - Close active window
- `Super + F` - Toggle floating
- `Super + S` - System menu
- `Super + L` - Lock screen
- `Super + W` - Wallpaper selector

### Workspaces
- `Super + 1-5` - Switch to workspace
- `Super + Shift + 1-5` - Move window to workspace

### Utilities
- `Super + N` - Network menu
- `Super + B` - Bluetooth menu
- `Super + M` - Audio menu
- `Super + V` - Clipboard manager
- `Print` - Full screenshot
- `Super + Print` - Active window screenshot
- `Super + Shift + S` - Area screenshot
- `Super + Shift + N` - Toggle Do Not Disturb

## Customization

### Configuration Files
- Hyprland: `~/.config/hypr/hyprland.conf`
- Waybar: `~/.config/waybar/config` and `style.css`
- Kitty: `~/.config/kitty/kitty.conf`
- Rofi: `~/.config/rofi/config.rasi`
- GTK: `~/.config/gtk-3.0/settings.ini`
- Qt: `~/.config/qt5ct/qt5ct.conf`

### Scripts
All utility scripts are located in `~/.config/hypr/scripts/`:
- `wallpaper-switcher.sh` - Automatic wallpaper rotation
- `wallpaper-gui.sh` - Wallpaper selector
- `screenshot.sh` - Screenshot utility
- `clipboard-manager.sh` - Clipboard management
- `network-manager.sh` - Network controls
- `bluetooth-manager.sh` - Bluetooth controls
- `audio-manager.sh` - Audio controls
- `system-menu.sh` - System control center

## Requirements

- Arch Linux or derivative
- yay (AUR helper)
- systemd
- Wayland-compatible GPU drivers

## Contributing

1. Fork the repository
2. Create a new branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

Created by Misiix9 with ♥️
