#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status
set -e

# Ensure the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo." >&2
  exit 1
fi

echo "=== 1. Enabling Nvidia Power Management Services ==="
# Prevent Nvidia driver from dropping video memory on sleep
systemctl enable nvidia-suspend.service
systemctl enable nvidia-hibernate.service
systemctl enable nvidia-resume.service

echo "=== 2. Configuring Nvidia Modprobe Parameters ==="
# Create modprobe file to preserve video memory allocations
MODPROBE_FILE="/etc/modprobe.d/systemd.conf"
echo "Creating/updating $MODPROBE_FILE..."
cat <<'EOF' >"$MODPROBE_FILE"
# Preserve Nvidia video memory on sleep
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF

echo "=== 3. Configuring SDDM for Native Wayland ==="
# Force the SDDM login screen to launch via Wayland to handle session handoffs cleanly
SDDM_DIR="/etc/sddm.conf.d"
mkdir -p "$SDDM_DIR"
cat <<'EOF' >"$SDDM_DIR/10-wayland.conf"
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Wayland]
CompositorCommand=kwin_wayland --no-lockscreen
EOF

echo "=== 4. Forcing Early KMS in Dracut ==="
# Force-loads Nvidia drivers during early boot so they are ready upon wake
DRACUT_CONF="/etc/dracut.conf.d/nvidia.conf"
echo "Creating $DRACUT_CONF..."
mkdir -p /etc/dracut.conf.d
cat <<'EOF' >"$DRACUT_CONF"
force_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "
EOF

echo "=== 5. Updating Bootloader Kernel Parameters ==="
# Detect bootloader and inject both modeset=1 and fbdev=1
PARAMS="nvidia_drm.modeset=1 nvidia_drm.fbdev=1"

if [ -f "/etc/kernel/cmdline" ]; then
  echo "Detected systemd-boot configuration..."
  for param in $PARAMS; do
    if ! grep -q "$param" /etc/kernel/cmdline; then
      sed -i "s/$/ $param/" /etc/kernel/cmdline
      echo "Added $param to /etc/kernel/cmdline"
    else
      echo "$param already exists in /etc/kernel/cmdline"
    fi
  done
elif [ -f "/etc/default/grub" ]; then
  echo "Detected GRUB bootloader configuration..."
  for param in $PARAMS; do
    if ! grep -q "$param" /etc/default/grub; then
      sed -i "s/\(GRUB_CMDLINE_LINUX_DEFAULT=\".*\)\"/\1 $param\"/" /etc/default/grub
      echo "Added $param to /etc/default/grub"
    else
      echo "$param already exists in /etc/default/grub"
    fi
  done
  echo "Regenerating GRUB configuration..."
  grub-mkconfig -o /boot/grub/grub.cfg
else
  echo "Warning: Could not determine bootloader. You may need to add '$PARAMS' manually."
fi

echo "=== 6. Regenerating Initramfs (Kernel Images) ==="
# Rebuild images to embed Early KMS configuration
if command -v reinstall-kernels &>/dev/null; then
  reinstall-kernels
elif command -v dracut &>/dev/null; then
  echo "reinstall-kernels command not found, falling back to dracut..."
  dracut-rebuild
else
  echo "Error: Could not find kernel rebuild tools (reinstall-kernels or dracut)." >&2
  exit 1
fi

echo "===================================================="
echo " All fixes applied successfully!"
echo " Please reboot your computer for changes to take effect."
echo "===================================================="
