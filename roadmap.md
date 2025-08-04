# Hyprland Custom Setup & Installer Roadmap

This roadmap guides you through building your full Hyprland config and a shareable Arch Linux installer script. The project includes system-wide theming, layout, automation, and usability focused on minimal black/white design, using Lexend font everywhere.

## PHASE 1: PREPARATION & ENVIRONMENT SETUP

### 1.1 Install Arch Linux

* Use the official Arch ISO
* Partition and format the disk (ext4 or btrfs recommended)
* Install base system with:

  ```bash
  pacstrap /mnt base linux linux-firmware sudo
  ```
* Generate fstab, chroot, setup locale, hostname, etc.
* Install GRUB or systemd-boot
* Reboot into system

### 1.2 Add AUR Helper

```bash
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
```

### 1.3 Essential Packages

```bash
sudo pacman -S hyprland kitty dolphin rofi waybar mako zsh alacritty pipewire wireplumber pavucontrol xdg-desktop-portal-hyprland wofi networkmanager blueman bitwarden wl-clipboard grim slurp wlroots swaybg noto-fonts ttf-font-awesome unzip brightnessctl pamixer
```

AUR:

```bash
yay -S spicetify-cli zen-browser visual-studio-code-bin ttf-lexend-gfonts cliphist sddm-astronaut-theme-git
```

## PHASE 2: FONT & THEME

### 2.1 Font Configuration

* Set Lexend system-wide:

```ini
/etc/fonts/local.conf
```

```xml
<fontconfig>
  <match target="pattern">
    <edit name="family" mode="prepend">
      <string>Lexend</string>
    </edit>
  </match>
</fontconfig>
```

* GTK + QT override:

```bash
~/.config/gtk-3.0/settings.ini
~/.config/qt5ct/qt5ct.conf
```

## PHASE 3: HYPRLAND CONFIGURATION

### 3.1 Base Config Layout

Location: `~/.config/hypr/hyprland.conf`

* Set scaling: `monitor = eDP-1,1920x1080@60,auto,1.25`
* Tiling layout
* Rounded corners: `20px`
* Border size and color logic
* Gaps: `5px inner`, `10px outer`
* Animations: snappy
* Blur and opacity config for windows
* Keybinds: SUPER + ... (mapped based on answers)
* Master-stack layout

### 3.2 Keybindings

```ini
bind = SUPER, RETURN, exec, kitty
bind = SUPER, A, exec, rofi -show drun
bind = SUPER, Q, killactive
bind = SUPER, F, togglefloating
bind = SUPER, 1, workspace, 1
...
bind = SHIFT+SUPER, W, exec, wallpaper-gui
```

### 3.3 Wallpaper

* Auto-switching script every 3–8 minutes
* Bubble animation effect
* GUI launcher (wallpaper-gui) for image selection

### 3.4 Application Rules

* All applications blurred and transparent
* Border active: 2px white
* Border inactive: 2px black

## PHASE 4: WAYBAR SETUP

### 4.1 Layout

* Top bar
* Modules: battery, brightness, Bluetooth, audio, workspaces, datetime, weather
* Icons only, hover reveals text with slide animation

### 4.2 Fonts and Colors

* Font: Lexend
* Icons from Font Awesome
* Colors: only black, white, gray
* Add calendar popup on date hover

## PHASE 5: ROFI / LAUNCHER

### 5.1 Style

* List style launcher
* Transparent + blurred background
* Application icons enabled
* Recent apps sorted to top
* Launch calculator mode too

## PHASE 6: TERMINAL & SHELL

### 6.1 Kitty

* Lexend font
* Transparent background
* Colors: black/white only

### 6.2 Shell

* zsh + oh-my-zsh
* Starship prompt optional
* Add aliases for core tasks

## PHASE 7: APPS CONFIGURATION

### 7.1 File Manager

* Dolphin (dark theme, macOS style icons)

### 7.2 Text Editor

* Kate (dark, Lexend font)

### 7.3 Browser

* Zen-browser (theme match system)

### 7.4 Spotify + Spicetify

* Install and configure
* Album cover widget on desktop

### 7.5 Notifications

* Mako, top-right
* Timeout: few seconds
* History: enabled
* Sound + style for warnings

## PHASE 8: UTILITIES

* Clipboard manager: Cliphist
* Screenshot tool: Grim + Slurp
* Password manager: Bitwarden
* Audio mixer: Pavucontrol
* Bluetooth: Blueman
* Wallpaper engine GUI (wallpaper-gui)

## PHASE 9: INSTALLER CREATION

### 9.1 Structure

* Modular scripts (install.sh, config.sh, apps.sh, theme.sh, post.sh)
* Interactive prompts with options
* Auto-detect GPU, resolution, keyboard, audio, brightness keys
* Auto-install drivers and kernel modules

### 9.2 Features

* Theme chooser
* Detect missing packages
* AUR support via yay
* Dotfile management via `chezmoi` or simple `cp`
* Logs with timestamps
* Abort-safe
* Post-install tips file

## PHASE 10: POST-INSTALL

### 10.1 Login

* SDDM (with astronaut theme)

### 10.2 Auto-launch

* Enable services: NetworkManager, pipewire, sddm

### 10.3 Final Touches

* Background rotation enabled on startup
* All apps themed with Lexend font
* Wallpapers pre-installed
* Power plan config for performance/balanced/saver/gamer

---

# ✅ DONE CHECKLIST

* [ ] Arch Installed
* [ ] yay installed
* [ ] Packages installed
* [ ] Fonts + GTK/Qt config
* [ ] Hyprland configured
* [ ] Wallpaper engine & GUI
* [ ] Waybar configured
* [ ] Rofi launcher styled
* [ ] Kitty + ZSH
* [ ] All apps styled
* [ ] Installer script created
* [ ] GitHub repo created
* [ ] README with usage guide

Once you're ready, I can start generating the scripts, configs, and wallpapers. Let me know when! ✅
