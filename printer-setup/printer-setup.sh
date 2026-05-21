#!/bin/bash

# Add CUPS
sudo pacman -Syu cups cups-browsed cups-filters cups-pdf system-config-printer --needed

# Enable Services
sudo systemctl enable --now cups.socket
sudo systemctl enable --now cups-browsed.service
sudo systemctl enable --now avahi-daemon.service
sudo systemctl restart avahi-daemon

# Firewall
echo "If error mention no firewall, then ignore the message."
sudo firewall-cmd --zone=public --add-service=mdns --permanent && sudo firewall-cmd --reload
