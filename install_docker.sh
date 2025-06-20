#!/bin/bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "❌ This script must be run as root. Try: sudo $0"
  exit 1
fi

echo "🚀 Starting Docker and Docker Compose installation..."

echo "🧹 Removing any old Docker packages..."
apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

echo "🔄 Updating package index..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y

echo "📦 Installing prerequisites..."
apt-get install -y ca-certificates curl gnupg lsb-release

DOCKER_KEYRING_PATH="/etc/apt/keyrings/docker.gpg"
if [ ! -f "$DOCKER_KEYRING_PATH" ]; then
  echo "🔑 Adding Docker's official GPG key..."
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o "$DOCKER_KEYRING_PATH"
else
  echo "🔑 Docker GPG key already exists, skipping."
fi

DOCKER_SOURCE_LIST="/etc/apt/sources.list.d/docker.list"
DISTRO=$(lsb_release -cs)
ARCH=$(dpkg --print-architecture)
if [ ! -f "$DOCKER_SOURCE_LIST" ]; then
  echo "📁 Setting up Docker repository for $DISTRO..."
  echo "deb [arch=$ARCH signed-by=$DOCKER_KEYRING_PATH] https://download.docker.com/linux/ubuntu $DISTRO stable" > "$DOCKER_SOURCE_LIST"
fi

apt-get update -y

echo "⚙️ Installing Docker Engine and Compose plugin..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

read -rp "👤 Enter a username to add to the 'docker' group (or press Enter to skip): " username
if [ -n "$username" ]; then
  if id "$username" &>/dev/null; then
    usermod -aG docker "$username"
    echo "✅ User '$username' added to the docker group. Please log out and back in."
  else
    echo "⚠️ User '$username' does not exist. Skipping group addition."
  fi
fi

echo "✅ Docker installation completed!"
echo "🔍 Verifying installed versions:"
docker --version || echo "Docker not found"
docker compose version || echo "Docker Compose not found"
