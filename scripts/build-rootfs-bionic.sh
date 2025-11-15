#!/usr/bin/env bash
set -euo pipefail

# build-bionic.sh
# - Bootstraps Ubuntu Bionic (arm64)
# - Installs core utilities
# - Patchelf all ELF files to use /lib/ld-linux-aarch64.so.1 and rpath /lib
# - Outputs imagefs_bionic.txz

ARCH="arm64"
ROOTFS_DIR="$PWD/bionic-rootfs"
UBUNTU_RELEASE="bionic"
MIRROR="http://ports.ubuntu.com"

# optional: change to jammy or focal if you prefer
# UBUNTU_RELEASE="bionic"

echo "[0] Ensure script runs as a user with sudo"
if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required. Install sudo or run as root."
  exit 1
fi

echo "[1] Prepare workspace"
rm -rf "$ROOTFS_DIR"
mkdir -p "$ROOTFS_DIR"

echo "[2] Bootstrap minimal Ubuntu $UBUNTU_RELEASE (arm64)"
sudo debootstrap \
  --arch="$ARCH" \
  --variant=minbase \
  --include=ca-certificates \
  "$UBUNTU_RELEASE" \
  "$ROOTFS_DIR" \
  "$MIRROR"

echo "[3] Copy qemu for chrooting arm64 libs"
sudo cp /usr/bin/qemu-aarch64-static "$ROOTFS_DIR/usr/bin/" || true

echo "[4] Ensure apt sources include universe/multiverse"
sudo tee "$ROOTFS_DIR/etc/apt/sources.list" >/dev/null <<EOF
deb $MIRROR $UBUNTU_RELEASE main universe multiverse restricted
deb $MIRROR $UBUNTU_RELEASE-updates main universe multiverse restricted
deb $MIRROR $UBUNTU_RELEASE-security main universe multiverse restricted
EOF

echo "[5] Mount pseudo filesystems for chroot (so apt works properly)"
sudo mount --bind /dev "$ROOTFS_DIR/dev"
sudo mount --bind /sys "$ROOTFS_DIR/sys"
sudo mount --bind /proc "$ROOTFS_DIR/proc"

echo "[6] Install core packages inside the chroot"
sudo chroot "$ROOTFS_DIR" /bin/bash -eux <<'CHROOT_EOF'
export DEBIAN_FRONTEND=noninteractive
apt update
apt -y upgrade

# core tools you asked for
apt install -y \
  bash \
  coreutils \
  tar \
  xz-utils \
  gzip \
  findutils \
  util-linux \
  sed \
  grep \
  wget \
  curl \
  file \
  apt-transport-https \
  ca-certificates \
  sudo \
  locales \
  nano

# setup locale
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

# basic clean
apt clean
CHROOT_EOF

echo "[7] Cleanup chroot mounts"
sudo umount "$ROOTFS_DIR/dev" || true
sudo umount "$ROOTFS_DIR/sys" || true
sudo umount "$ROOTFS_DIR/proc" || true

# remove qemu from rootfs to avoid shipping it
sudo rm -f "$ROOTFS_DIR/usr/bin/qemu-aarch64-static" || true

# Ensure patchelf is available on host (we must run patchelf *outside* the rootfs)
if ! command -v patchelf >/dev/null 2>&1; then
  echo "[8] patchelf not found on host — installing"
  sudo apt-get update
  sudo apt-get install -y patchelf
fi

# Make sure the target loader exists in the rootfs. If glibc installation put loader in lib/, ok.
if [ ! -f "$ROOTFS_DIR/lib/ld-linux-aarch64.so.1" ]; then
  echo "[!] Warning: $ROOTFS_DIR/lib/ld-linux-aarch64.so.1 not found."
  echo "    glibc loader usually present if debootstrap installed libc. Continue anyway."
fi

echo "[9] Running patchelf on ELF files (set interpreter -> /lib/ld-linux-aarch64.so.1, rpath -> /lib)"
# use a safer loop to handle spaces/newlines
sudo bash -c "cd '$ROOTFS_DIR' && \
  find . -type f -exec file --brief --mime-type {} + | sed -n 's|:.*||p' >/tmp/all_files.txt || true"

# The approach above works better if we just run file per-file:
# We'll iterate and patch each ELF found.
sudo bash -c "cd '$ROOTFS_DIR' && \
  find . -type f -print0 | while IFS= read -r -d '' f; do
    if file --brief \"\$f\" | grep -qi 'elf'; then
      # skip symlinks
      if [ -L \"\$f\" ]; then
        continue
      fi
      echo \"Patching \$f ...\"
      # attempt to set interpreter and rpath; if it fails, continue
      patchelf --set-interpreter /lib/ld-linux-aarch64.so.1 --set-rpath /lib \"\$f\" 2>/tmp/patchelf.err || {
        echo \"  warning: patchelf failed on \$f (see /tmp/patchelf.err)\" >&2
        continue
      }
    fi
  done"

echo "[10] Post-patch: ensure executable bits for bin/ sbin/ usr/bin"
sudo find "$ROOTFS_DIR/usr/bin" -type f -exec chmod 755 {} \; || true
sudo find "$ROOTFS_DIR/bin" -type f -exec chmod 755 {} \; || true
sudo find "$ROOTFS_DIR/sbin" -type f -exec chmod 755 {} \; || true

echo "[11] Create version file"
DATE_STR="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
cat > "$ROOTFS_DIR/_version_.txt" <<EOF
Built: $DATE_STR
Base: Ubuntu $UBUNTU_RELEASE (arm64)
Patched interpreter: /lib/ld-linux-aarch64.so.1
EOF

echo "[12] Pack into imagefs_bionic.txz (xz compressed)"
sudo tar -C "$ROOTFS_DIR" -cJf imagefs_bionic.txz .

echo "DONE — imagefs_bionic.txz created in: $(pwd)/imagefs_bionic.txz"
