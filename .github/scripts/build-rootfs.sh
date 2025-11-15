#!/usr/bin/env bash
set -e

ROOTFS=/data/data/com.winlator/files/rootfs
ARCH=aarch64
DEBIAN_RELEASE=bookworm

# -------------------------------
#  Create base rootfs using debootstrap
# -------------------------------
mkdir -p "$ROOTFS"

echo "[1] Bootstrapping Debian ($DEBIAN_RELEASE)..."
debootstrap \
  --arch=$ARCH \
  --variant=minbase \
  $DEBIAN_RELEASE \
  "$ROOTFS" \
  http://deb.debian.org/debian

# -------------------------------
#  Configure APT inside rootfs
# -------------------------------
echo "deb http://deb.debian.org/debian $DEBIAN_RELEASE main contrib non-free non-free-firmware" \
  > "$ROOTFS/etc/apt/sources.list"

chroot "$ROOTFS" apt update

# -------------------------------
#  Install core packages (ls, cd, tar, gzip, etc)
# -------------------------------
chroot "$ROOTFS" apt install -y \
  coreutils \
  bash \
  tar \
  gzip \
  xz-utils \
  findutils \
  util-linux \
  sed \
  grep \
  wget \
  ca-certificates \
  file

# -------------------------------
#  Install XFCE4 (minimal, no PulseAudio or ALSA)
# -------------------------------
chroot "$ROOTFS" apt install -y \
  xfce4 \
  xfce4-terminal \
  xfce4-session \
  xfce4-panel \
  xfdesktop4 \
  thunar \
  dbus-x11 \
  lightdm-gtk-greeter \
  gvfs \
  mousepad

# Remove sound deps forced by xfce (pulseaudio, alsa)
chroot "$ROOTFS" apt remove -y \
  pulseaudio* alsa* || true

# -------------------------------
#  Patch ELF files for Winlator
# -------------------------------
echo "[3] Running patchelf pass..."
LD_RPATH="$ROOTFS/lib"
LD_FILE="$ROOTFS/lib/ld-linux-aarch64.so.1"

patch_single() {
    echo "Patching: $1"
    patchelf --set-rpath "$LD_RPATH" --set-interpreter "$LD_FILE" "$1" 2>/dev/null || true
}

export -f patch_single LD_RPATH LD_FILE

find "$ROOTFS" -type f -exec file {} \; \
 | grep ELF \
 | cut -d: -f1 \
 | xargs -I {} bash -c 'patch_single "$@"' _ {}

# -------------------------------
#  Create _version_.txt
# -------------------------------
DATE=$(date "+%Y-%m-%d %H:%M:%S")
cat > "$ROOTFS/_version_.txt" <<EOF
RootFS Created: $DATE
XFCE Version: Minimal Debian XFCE4
Built for: Winlator Environment
EOF

# -------------------------------
#  Package result → rootfs.txz
# -------------------------------
echo "[4] Packaging rootfs.txz"
cd "$ROOTFS"
tar -cJf /tmp/rootfs.txz *

echo "Done!"
echo "Output: /tmp/rootfs.txz"￼Enter
