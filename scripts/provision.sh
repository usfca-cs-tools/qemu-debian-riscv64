#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SSH_KEY="$PROJECT_DIR/image/ssh_user_ed25519_key"

chmod 600 "$SSH_KEY"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 -i $SSH_KEY"
SSH_TARGET="root@localhost"
SSH_PORT=2222

echo "==> Waiting for VM SSH to become available..."
until ssh $SSH_OPTS -p "$SSH_PORT" "$SSH_TARGET" true 2>/dev/null; do
  echo "    Waiting..."
  sleep 5
done
echo "==> SSH is up!"

echo "==> Running provisioning commands..."
ssh $SSH_OPTS -p "$SSH_PORT" "$SSH_TARGET" bash -s <<'PROVISION'
set -euo pipefail

echo "==> Updating package lists..."
apt-get update
apt-get upgrade -y

echo "==> Growing root partition to fill disk..."
apt-get install -y cloud-guest-utils
growpart /dev/vda 1
resize2fs /dev/vda1

echo "==> Installing development tools..."
apt-get install -y \
  build-essential \
  gcc g++ \
  make cmake \
  autoconf automake libtool \
  pkg-config \
  python3 python3-pip python3-venv python3-dev \
  git \
  curl wget \
  vim \
  gdb \
  strace \
  htop \
  tmux \
  openssh-server \
  ca-certificates \
  locales

echo "==> Configuring locale..."
sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen

echo "==> Provisioning complete!"
gcc --version | head -1
python3 --version
PROVISION

echo "==> VM provisioned successfully!"
