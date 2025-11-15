#!/usr/bin/env bash
set -e

ARCH="arm64"
ROOTFS_DIR="$PWD/bionic-rootfs"
UBUNTU_RELEASE="bionic"

echo "[1] Bootstrapping Ubuntu $UBUNTU_RELEASE ($ARCH)..."

sudo debootstrap \
  --arch=$ARCH \
  --variant=minbase \
  --include=ca-certificates \
  $UBUNTU_RELEASE \
  $ROOTFS_DIR \
  http://ports.ubuntu.com

echo "[2] Copying QEMU..."
sudo cp /usr/bin/qemu-aarch64-static $ROOTFS_DIR/usr/bin/

echo "[3] Fixing sources.list..."
sudo tee $ROOTFS_DIR/etc/apt/sources.list >/dev/null <<EOF
deb http://ports.ubuntu.com/ubuntu-ports bionic main universe multiverse restricted
deb http://ports.ubuntu.com/ubuntu-ports bionic-updates main universe multiverse restricted
deb http://ports.ubuntu.com/ubuntu-ports bionic-security main universe multiverse restricted
EOF

echo "[4] Installing core packages (coreutils, bash, apt, nano)..."

sudo chroot $ROOTFS_DIR /bin/bash <<'EOF'
set -e
export DEBIAN_FRONTEND=noninteractive

apt update
apt upgrade -y

apt install -y \
  bash \
  coreutils \
  nano \
  tar \
  xz-utils \
  gzip \
  sudo \
  wget \
  curl \
  locales \
  apt-transport-https \
  ca-certificates

# Locale setup
locale-gen en_US.UTF-8

# Make root environment normal
echo "export LANG=en_US.UTF-8" >> /root/.bashrc
echo "export LC_ALL=en_US.UTF-8" >> /root/.bashrc

EOF

echo "[5] Cleaning..."
sudo chroot $ROOTFS_DIR apt clean
sudo rm -f $ROOTFS_DIR/usr/bin/qemu-aarch64-static

echo "[6] Packing rootfs to imagefs.txz..."
sudo tar -C $ROOTFS_DIR -cJf imagefs_bionic.txz .

echo "DONE — saved as imagefs_bionic.txz"￼Enter
