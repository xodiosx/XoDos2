#!/usr/bin/env bash
set -e

ARCH="arm64"
ROOTFS_DIR="$PWD/rootfs"
UBUNTU_RELEASE="jammy"

echo "[1] Bootstrapping Ubuntu $UBUNTU_RELEASE ($ARCH)..."

sudo debootstrap \
  --arch=$ARCH \
  --include=ca-certificates \
  $UBUNTU_RELEASE \
  $ROOTFS_DIR \
  http://ports.ubuntu.com

echo "[2] Copying QEMU..."
sudo cp /usr/bin/qemu-aarch64-static $ROOTFS_DIR/usr/bin/

echo "[3] Fixing apt sources..."
sudo tee $ROOTFS_DIR/etc/apt/sources.list >/dev/null <<EOF
deb http://ports.ubuntu.com/ubuntu-ports $UBUNTU_RELEASE main universe multiverse restricted
deb http://ports.ubuntu.com/ubuntu-ports $UBUNTU_RELEASE-updates main universe multiverse restricted
deb http://ports.ubuntu.com/ubuntu-ports $UBUNTU_RELEASE-security main universe multiverse restricted
EOF

echo "[4] Entering chroot and installing XFCE..."
sudo chroot $ROOTFS_DIR /bin/bash <<'EOF'
set -e
export DEBIAN_FRONTEND=noninteractive

apt update
apt upgrade -y

apt install -y \
  xfce4 \
  xfce4-goodies \
  lightdm \
  lightdm-gtk-greeter \
  xterm \
  dbus-x11 \
  sudo \
  locales

# Setup locales
locale-gen en_US.UTF-8

# Create default user
useradd -m -s /bin/bash ubuntu
echo "ubuntu:ubuntu" | chpasswd
adduser ubuntu sudo

EOF

echo "[5] Cleaning..."
sudo chroot $ROOTFS_DIR apt clean
sudo rm -f $ROOTFS_DIR/usr/bin/qemu-aarch64-static

echo "[6] Packing imagefs.txz..."
sudo tar -cJf imagefs.txz -C $ROOTFS_DIR .

echo "DONE — imagefs.txz created"
