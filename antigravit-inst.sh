#!/bin/bash

# Configuration
INSTALL_DIR="$HOME/.antigravity"
DESKTOP_FILE="$HOME/.local/share/applications/antigravity.desktop"

echo "Checking for Google Antigravity installation..."

# Create directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

tar -xzf ~/Downloads/Antigravity.tar.gz -C "$INSTALL_DIR" --strip-components=1

# Create .desktop file for EndeavourOS menu integration
echo "Creating desktop entry..."
cat <<EOF >"$DESKTOP_FILE"
[Desktop Entry]
Name=Google Antigravity
Comment=Agentic Development Platform from Google
Exec=/home/ripalb/.antigravity/antigravity --enable-features=UseOzonePlatform --ozone-platform=wayland %F
Icon=/home/ripalb/.antigravity/resources/app/resources/linux/code.png
Terminal=false
Type=Application
Categories=Development;IDE;
MimeType=text/plain;
EOF

chmod +x "$DESKTOP_FILE"

echo "Installation/Upgrade complete. You can find Antigravity in your application menu."
