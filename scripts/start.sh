#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

exec qemu-system-riscv64 \
  -machine virt \
  -cpu rv64 \
  -m 4G \
  -smp 4 \
  -nographic \
  -kernel "$PROJECT_DIR/image/kernel" \
  -initrd "$PROJECT_DIR/image/initrd" \
  -append "root=LABEL=rootfs console=ttyS0" \
  -device virtio-blk-device,drive=hd0 \
  -drive "file=$PROJECT_DIR/image/image.qcow2,if=none,id=hd0,format=qcow2" \
  -device virtio-net-device,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -object rng-random,filename=/dev/urandom,id=rng0 \
  -device virtio-rng-device,rng=rng0
