#!/usr/bin/env bash
set -Eeuo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
source "$root/scripts/lib/common.sh"

name="${DEVICE_NAME:-sensornode-qemu-01}"
kernel="${KERNEL_IMAGE:-}"
rootfs="${ROOTFS_IMAGE:-}"
ssh_port="${SSH_PORT:-2222}"
app_port="${APP_PORT:-8081}"
memory="${QEMU_MEMORY_MB:-512}"
state="$root/qemu-fleet/state/$name"

require_command qemu-system-aarch64
require_file "$kernel"
require_file "$rootfs"
mkdir -p "$state"
require_command flock
exec 9>"$state/lock"
flock -n 9 || die "device already running: $name"
cp --reflink=auto --sparse=always "$rootfs" "$state/rootfs.ext4"

exec qemu-system-aarch64 \
  -name "$name" \
  -pidfile "$state/qemu.pid" \
  -machine virt \
  -cpu cortex-a53 \
  -smp 2 \
  -m "$memory" \
  -display none \
  -monitor none \
  -kernel "$kernel" \
  -append "root=/dev/vda rw rootwait console=ttyAMA0 ip=dhcp sensornode.device_id=$name" \
  -drive "if=none,file=$state/rootfs.ext4,format=raw,id=hd0" \
  -device virtio-blk-device,drive=hd0 \
  -netdev "user,id=net0,hostfwd=tcp::${ssh_port}-:22,hostfwd=tcp::${app_port}-:8080" \
  -device virtio-net-device,netdev=net0 \
  -serial "file:$state/serial.log"
