# MH4S Troubleshooting Guide

## Common Issues and Solutions

### 1. Display and Graphics

#### Black Screen After Login
- **Issue**: Screen goes black after SDDM login
- **Solution**:
  1. Switch to TTY (Ctrl+Alt+F2)
  2. Check Hyprland logs: `cat ~/.local/share/hyprland/hyprland.log`
  3. Verify GPU drivers are installed: `lspci -k | grep -A 2 -E "(VGA|3D)"`
  4. Ensure proper environment variables in `~/.config/hypr/hyprland.conf`

#### Screen Tearing
- **Issue**: Visual tearing during animations or video playback
- **Solution**:
  1. Enable VSync in hyprland.conf:
     ```ini
     general {
         no_vfr = false
     }
     ```
  2. Check GPU driver settings
  3. Try different animation settings

### 2. Audio

#### No Sound
- **Issue**: No audio output after installation
- **Solution**:
  1. Check PipeWire status: `systemctl --user status pipewire`
  2. Verify audio devices: `pactl list sinks`
  3. Test audio: `speaker-test -c 2`
  4. Check volume: `pamixer --get-volume`

#### Audio Crackling
- **Issue**: Audio distortion or crackling
- **Solution**:
  1. Check PipeWire configuration in `/etc/pipewire/pipewire.conf`
  2. Adjust sample rate and buffer size
  3. Restart PipeWire: `systemctl --user restart pipewire`

### 3. Network

#### WiFi Not Working
- **Issue**: Cannot connect to WiFi networks
- **Solution**:
  1. Check NetworkManager status: `systemctl status NetworkManager`
  2. Verify WiFi hardware: `rfkill list`
  3. List available networks: `nmcli device wifi list`
  4. Try manual connection: `nmcli device wifi connect SSID password PASSWORD`

#### Bluetooth Issues
- **Issue**: Cannot pair or connect Bluetooth devices
- **Solution**:
  1. Check Bluetooth service: `systemctl status bluetooth`
  2. Reset Bluetooth: `sudo systemctl restart bluetooth`
  3. Clear paired devices: `bluetoothctl paired-devices` then `remove <MAC>`
  4. Try manual pairing: `bluetoothctl scan on` then `pair <MAC>`

### 4. Application Issues

#### Rofi Not Launching
- **Issue**: Application launcher doesn't appear
- **Solution**:
  1. Check keybinding in hyprland.conf
  2. Verify Rofi installation: `which rofi`
  3. Test Rofi manually: `rofi -show drun`
  4. Check for configuration errors: `rofi -dump-config`

#### Waybar Missing Icons
- **Issue**: Status bar icons not displaying
- **Solution**:
  1. Verify Font Awesome installation
  2. Check font configuration in waybar/style.css
  3. Rebuild font cache: `fc-cache -fv`
  4. Restart Waybar: `killall waybar && waybar`

### 5. Theme and Appearance

#### GTK Theme Not Applied
- **Issue**: Applications using default theme
- **Solution**:
  1. Check GTK settings: `cat ~/.config/gtk-3.0/settings.ini`
  2. Verify theme installation
  3. Set theme manually: `gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'`
  4. Restart affected applications

#### Font Issues
- **Issue**: Incorrect or missing fonts
- **Solution**:
  1. Verify Lexend installation: `fc-list | grep Lexend`
  2. Check font configuration: `cat /etc/fonts/local.conf`
  3. Update font cache: `fc-cache -fv`
  4. Install missing fonts: `yay -S ttf-lexend-gfonts`

### 6. Performance

#### High CPU Usage
- **Issue**: System running hot or slow
- **Solution**:
  1. Check processes: `htop`
  2. Adjust animation settings in hyprland.conf
  3. Disable unnecessary background services
  4. Monitor GPU usage: `nvidia-smi` or `radeontop`

#### Slow Startup
- **Issue**: Long boot time to desktop
- **Solution**:
  1. Check startup applications
  2. Analyze boot time: `systemd-analyze blame`
  3. Disable unnecessary services
  4. Clean package cache: `yay -Scc`

### 7. Installation Issues

#### Package Installation Fails
- **Issue**: Error during package installation
- **Solution**:
  1. Update system: `sudo pacman -Syu`
  2. Clear package cache: `sudo pacman -Sc`
  3. Check mirrors: `sudo pacman-mirrors -g`
  4. Try alternative AUR helper

#### Script Permission Issues
- **Issue**: Cannot execute installation scripts
- **Solution**:
  1. Check permissions: `ls -l installer/*.sh`
  2. Make scripts executable: `chmod +x installer/*.sh`
  3. Run as regular user (not root)
  4. Check SELinux/AppArmor settings

### Getting Help

If you encounter issues not covered in this guide:

1. Check the Hyprland wiki
2. Review system logs:
   ```bash
   journalctl -b
   cat ~/.local/share/hyprland/hyprland.log
   ```
3. Open an issue on GitHub with:
   - Detailed description
   - System information
   - Relevant logs
   - Steps to reproduce

### Reporting Bugs

When reporting bugs, please include:

1. System information:
   ```bash
   neofetch
   uname -a
   ```
2. Relevant configuration files
3. Error messages
4. Steps to reproduce
5. Expected vs actual behavior
