#!/usr/bin/env bash
set -e

### ------------------------------------------------------------
### SETTINGS
### ------------------------------------------------------------

ROOTFS=/tmp/rootfs
UBUNTU_RELEASE=focal   # You can change to jammy if needed
MIRROR=http://ports.ubuntu.com/

### ------------------------------------------------------------
### CLEAN WORK DIR
### ------------------------------------------------------------

rm -rf "$ROOTFS"
mkdir -p "$ROOTFS"

echo "[1] Bootstrapping Ubuntu $UBUNTU_RELEASE (arm64)..."

### ------------------------------------------------------------
### DEBOOTSTRAP ROOTFS (Ubuntu arm64)
### ------------------------------------------------------------

sudo debootstrap \
    --arch=arm64 \
    --variant=minbase \
    "$UBUNTU_RELEASE" \
    "$ROOTFS" \
    "$MIRROR"

echo "[2] Installing required packages inside rootfs..."

### ------------------------------------------------------------
### PREPARE CHROOT ENVIRONMENT
### ------------------------------------------------------------

sudo cp /usr/bin/qemu-aarch64-static "$ROOTFS/usr/bin/"
sudo mount --bind /dev "$ROOTFS/dev"
sudo mount --bind /sys "$ROOTFS/sys"
sudo mount --bind /proc "$ROOTFS/proc"

### ------------------------------------------------------------
### INSTALL BASE SYSTEM INSIDE ROOTFS
### ------------------------------------------------------------

cat <<'EOF' | sudo chroot "$ROOTFS" /bin/bash
set -e

apt update

# Essential tools (ls, cd is built-in, tar, xz, gzip, sed, coreutils etc.)
apt install -y \
    coreutils \
    bash \
    tar \
    xz-utils \
    gzip \
    sed \
    wget \
    curl \
    file \
    findutils \
    util-linux \
    diffutils \
    grep \
    procps

# XFCE4 desktop (without pulseaudio/alsa)
apt install -y \
    xfce4 \
    xfce4-goodies \
    lightdm-gtk-greeter \
    xorg \
    x11-xserver-utils \
    dbus-x11

apt clean
EOF

echo "[3] Cleaning chroot…"

### ------------------------------------------------------------
### CLEAN UP BINDS
### ------------------------------------------------------------

sudo umount "$ROOTFS/dev" || true
sudo umount "$ROOTFS/sys" || true
sudo umount "$ROOTFS/proc" || true

### ------------------------------------------------------------
### REMOVE qemu-aarch64-static
### ------------------------------------------------------------

sudo rm -f "$ROOTFS/usr/bin/qemu-aarch64-static"

echo "[4] Packaging final rootfs as imagefs.txz..."

### ------------------------------------------------------------
### PACK INTO TXZ FOR WINLATOR
### ------------------------------------------------------------

cd "$ROOTFS"
sudo tar -I "xz -T$(nproc)" -cpf /tmp/imagefs.txz *

echo "Done!"
echo "Output: /tmp/imagefs.txz"
