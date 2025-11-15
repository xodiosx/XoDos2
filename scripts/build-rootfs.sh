#!/usr/bin/env bash
set -e

ROOTFS=/tmp/rootfs
UBUNTU_RELEASE=focal
MIRROR=http://ports.ubuntu.com/

echo "[1] Bootstrapping Ubuntu $UBUNTU_RELEASE (arm64)..."

rm -rf "$ROOTFS"
mkdir -p "$ROOTFS"

sudo debootstrap \
    --arch=arm64 \
    --variant=minbase \
    "$UBUNTU_RELEASE" \
    "$ROOTFS" \
    "$MIRROR"

echo "[2] Preparing chroot environment…"

sudo cp /usr/bin/qemu-aarch64-static "$ROOTFS/usr/bin/"
sudo mount --bind /dev "$ROOTFS/dev"
sudo mount --bind /sys "$ROOTFS/sys"
sudo mount --bind /proc "$ROOTFS/proc"

echo "[3] Fixing APT sources (enable universe, multiverse)…"

# Replace sources.list inside rootfs BEFORE installing packages
cat <<EOF | sudo tee "$ROOTFS/etc/apt/sources.list"
deb $MIRROR $UBUNTU_RELEASE main universe multiverse restricted
deb $MIRROR $UBUNTU_RELEASE-updates main universe multiverse restricted
deb $MIRROR $UBUNTU_RELEASE-security main universe multiverse restricted
EOF

echo "[4] Installing packages inside rootfs…"

cat <<'EOF' | sudo chroot "$ROOTFS" /bin/bash
set -e

apt update

# Base required tools
apt install -y \
  coreutils bash tar xz-utils gzip sed wget curl file \
  findutils util-linux diffutils grep procps net-tools \
  pciutils usbutils zip unzip git

# Install XFCE4 (now the repo is enabled → SUCCESS)
apt install -y xfce4 xfce4-goodies

# Install LightDM greeter (safe for Winlator)
apt install -y lightdm-gtk-greeter lightdm

# No audio dependencies (pulseaudio/alsa NOT installed)

# Clean
apt clean
EOF

echo "[5] Cleaning up chroot…"

sudo umount "$ROOTFS/dev" || true
sudo umount "$ROOTFS/sys" || true
sudo umount "$ROOTFS/proc" || true

sudo rm -f "$ROOTFS/usr/bin/qemu-aarch64-static"

echo "[6] Packaging imagefs.txz…"

cd "$ROOTFS"
sudo tar -I "xz -T$(nproc)" -cpf /tmp/imagefs.txz *

echo "Build complete! Output: /tmp/imagefs.txz"
