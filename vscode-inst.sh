#!/bin/bash

# Configuration
INSTALL_DIR="/opt/vscode"
# Direct link for Linux x64 tar.gz
DOWNLOAD_URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"
DESKTOP_FILE="$HOME/.local/share/applications/code.desktop"
TMP_DIR="/tmp/vscode_update"

echo "Starting VS Code manual installation/update..."

# 1. Clean and create temporary directory
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

# 2. Download latest tarball
echo "Downloading VS Code from Microsoft..."
# Use -L to follow redirects and -J to use the filename from the server
curl -L "$DOWNLOAD_URL" -o vscode.tar.gz

# 3. Verify file format before extracting
if ! file vscode.tar.gz | grep -q "gzip compressed data"; then
  echo "Error: Downloaded file is not a valid gzip archive."
  echo "Check your internet connection or if Microsoft's link has changed."
  exit 1
fi

# 4. Prepare Installation Directory (Requires sudo)
if [ -d "$INSTALL_DIR" ]; then
  echo "Existing version found. Replacing..."
  sudo rm -rf "$INSTALL_DIR"
fi
sudo mkdir -p "$INSTALL_DIR"

# 5. Extract content
echo "Extracting files to $INSTALL_DIR..."
sudo tar -xzf vscode.tar.gz -C "$INSTALL_DIR" --strip-components=1

# 6. Create Symlink for terminal access
if [ ! -L /usr/bin/code ] && [ ! -f /usr/bin/code ]; then
  sudo ln -s "$INSTALL_DIR/bin/code" /usr/bin/code
fi

# 7. Create .desktop file for GNOME
echo "Creating GNOME desktop entry..."
cat <<EOF >"$DESKTOP_FILE"
[Desktop Entry]
Name=Visual Studio Code
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=$INSTALL_DIR/bin/code --unity-launch %F
Icon=$INSTALL_DIR/resources/app/resources/linux/code.png
Type=Application
StartupNotify=true
StartupWMClass=Code
Categories=Utility;TextEditor;Development;IDE;
MimeType=text/plain;inode/directory;application/x-code-workspace;
Keywords=vscode;code;editor;
EOF

chmod +x "$DESKTOP_FILE"

# 8. Cleanup
rm -rf "$TMP_DIR"

echo "--------------------------------------------------"
echo "Success! VS Code is installed/updated at $INSTALL_DIR"
