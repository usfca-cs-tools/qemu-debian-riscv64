#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
IMAGE_DIR="$PROJECT_DIR/image"
ZIP_FILE="$PROJECT_DIR/dqib_riscv64-virt.zip"
DQIB_URL="https://gitlab.com/api/v4/projects/giomasce%2Fdqib/jobs/artifacts/master/download?job=convert_riscv64-virt"

mkdir -p "$IMAGE_DIR"

if [ ! -f "$IMAGE_DIR/image.qcow2" ]; then
  echo "==> Downloading DQIB riscv64-virt image..."
  curl -L -o "$ZIP_FILE" "$DQIB_URL"

  echo "==> Extracting image..."
  unzip -o "$ZIP_FILE" -d "$IMAGE_DIR"

  # The zip extracts into a subdirectory; move files up if needed
  if [ -d "$IMAGE_DIR/dqib_riscv64-virt" ]; then
    mv "$IMAGE_DIR/dqib_riscv64-virt"/* "$IMAGE_DIR/"
    rmdir "$IMAGE_DIR/dqib_riscv64-virt"
  fi

  rm -f "$ZIP_FILE"
else
  echo "==> Image already exists, skipping download"
fi

echo "==> Resizing image to 32 GB..."
qemu-img resize "$IMAGE_DIR/image.qcow2" 32G

echo "==> Image info:"
qemu-img info "$IMAGE_DIR/image.qcow2"
