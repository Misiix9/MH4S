#!/bin/bash

# Enable SDDM service
echo "[Unit]
Description=Simple Desktop Display Manager
Documentation=man:sddm(1) man:sddm.conf(5)
Conflicts=getty@tty1.service
After=systemd-user-sessions.service getty@tty1.service plymouth-quit.service systemd-logind.service
StartLimitIntervalSec=30
StartLimitBurst=2

[Service]
ExecStart=/usr/bin/sddm
Restart=always
RestartSec=1s

[Install]
Alias=display-manager.service
WantedBy=graphical.target" > /etc/systemd/system/sddm.service

# Create Hyprland desktop entry
echo "[Desktop Entry]
Name=Hyprland
Comment=Highly customizable dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application" > /usr/share/wayland-sessions/hyprland.desktop

# Set default session to Hyprland
echo "Session=hyprland.desktop" > /etc/sddm/scripts/Xsetup

# Enable SDDM service
systemctl enable sddm.service
