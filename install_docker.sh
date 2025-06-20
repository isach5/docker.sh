#!/bin/bash
set -euo pipefail

# === CONFIG ===
DOCKER_GPG_URL="https://download.docker.com/linux/ubuntu/gpg"
DOCKER_APT_URL="https://download.docker.com/linux/ubuntu"
KEYRING_DIR="/etc/apt/keyrings"
KEYRING_FILE="$KEYRING_DIR/docker.gpg"
DOCKER_LIST_FILE="/etc/apt/sources.list.d/docker.list"
ARCH=$(dpkg --print-architecture)
DISTRO=$(lsb_release -cs)

# === CHECK ROOT ===
if [ "$EUID" -ne 0 ]; then
  echo "❌ This script must be run as root. Try: sudo $0"
  exit 1
fi

echo "🚀 Starting Docker & Docker Compose installation for Ubuntu $DISTRO ($ARCH)"

# === REMOVE OLD VERSIONS ===
echo "🧹 Removing old Docker versions (if any)..."
apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# === UPDATE SYSTEM ===
echo "🔄 Updating apt packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y

# === INSTALL DEPENDENCIES ===
echo "📦 Installing required packages..."
apt-get install -y ca-certificates curl gnupg lsb-release

# === ADD DOCKER GPG KEY ===
echo "🔑 Adding Docker GPG key..."
mkdir -p "$KEYRING_DIR"
curl -fsSL "$DOCKER_GPG_URL" | gpg --dearmor -o "$KEYRING_FILE"

# === ADD DOCKER REPO ===
echo "📝 Adding Docker APT repository..."
echo \
  "deb [arch=$ARCH signed-by=$KEYRING_FILE] $DOCKER_APT_URL $DISTRO stable" \
  > "$DOCKER_LIST_FILE"

# === INSTALL DOCKER ===
echo "📥 Installing Docker Engine and Compose plugin..."
apt-get update -y
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin \
  docker-ce-rootless-extras

# === ENABLE AND START DOCKER SERVICE ===
echo "▶️ Enabling and starting Docker service..."
systemctl enable docker
systemctl start docker

# === OPTIONAL: ADD USER TO DOCKER GROUP ===
if [ -t 0 ]; then
  read -rp "👤 Enter a username to add to the 'docker' group (or press Enter to skip): " username
  if [ -n "$username" ]; then
    if id "$username" &>/dev/null; then
      usermod -aG docker "$username"
      echo "✅ User '$username' added to docker group (log out & back in required)."
    else
      echo "⚠️ User '$username' not found, skipping."
    fi
  fi
else
  echo "ℹ️ Skipping user prompt (non-interactive shell)."
fi

# === VERIFY INSTALLATION ===
echo "✅ Installation complete! Versions:"
docker --version || echo "⚠️ Docker not found in PATH"
docker compose version || echo "⚠️ Docker Compose not found"
