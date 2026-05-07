#!/bin/bash

# Define the target installation directory
DOTNET_DIR="$HOME/.dotnet"

# 1. Download the official Microsoft installation script
echo "Downloading the latest dotnet-install script..."
curl -L https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
chmod +x dotnet-install.sh

# 2. Run the script to install/update the latest SDK
# This will add the new version to ~/.dotnet alongside existing ones.
# .NET automatically uses the highest version found in the directory.
echo "Installing/Updating the latest .NET SDK to $DOTNET_DIR..."
./dotnet-install.sh --install-dir "$DOTNET_DIR" --version latest

# 3. Clean up the installer script
rm dotnet-install.sh

# 4. Smart .bashrc Update (prevents duplicate entries)
echo "Ensuring .bashrc is configured..."

# Define the configuration block
BLOCK_MARKER="# --- DOTNET SDK CONFIG ---"
BASHRC_CONFIG=$(
  cat <<EOF
$BLOCK_MARKER
export DOTNET_ROOT="\$HOME/.dotnet"
export PATH="\$PATH:\$DOTNET_ROOT:\$DOTNET_ROOT/tools"
# -------------------------
EOF
)

if grep -q "$BLOCK_MARKER" "$HOME/.bashrc"; then
  echo "DOTNET configuration already exists in .bashrc. Skipping."
else
  echo -e "\n$BASHRC_CONFIG" >>"$HOME/.bashrc"
  echo ".bashrc updated with DOTNET_ROOT and PATH."
fi

echo "Done! Run 'source ~/.bashrc' and then 'dotnet --version' to verify."
