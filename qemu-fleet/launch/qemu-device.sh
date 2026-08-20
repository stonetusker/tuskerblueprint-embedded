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
accel="${QEMU_ACCEL:-auto}"
cpu="${QEMU_CPU:-}"
state="$root/qemu-fleet/state/$name"

require_command qemu-system-aarch64
require_file "$kernel"
require_file "$rootfs"
mkdir -p "$state"
require_command flock
exec 9>"$state/lock"
flock -n 9 || die "device already running: $name"
cp --reflink=auto --sparse=always "$rootfs" "$state/rootfs.ext4"

if [[ "$accel" == "auto" ]]; then
  if [[ "$(uname -m)" == "aarch64" && -r /dev/kvm && -w /dev/kvm ]]; then
    accel="kvm"
  else
    accel="tcg"
  fi
fi
case "$accel" in
  kvm)
    [[ "$(uname -m)" == "aarch64" ]] || die "ARM64 KVM acceleration requires an aarch64 host"
    [[ -r /dev/kvm && -w /dev/kvm ]] || die "/dev/kvm is not accessible"
    cpu="${cpu:-host}"
    accel_args=(-accel kvm)
    ;;
  tcg)
    cpu="${cpu:-cortex-a53}"
    accel_args=(-accel tcg,thread=multi)
    ;;
  *) die "unsupported QEMU_ACCEL=$accel; use auto, kvm, or tcg" ;;
esac
info "starting $name using accel=$accel cpu=$cpu app_port=$app_port ssh_port=$ssh_port"

exec qemu-system-aarch64 \
  -name "$name" \
  -pidfile "$state/qemu.pid" \
  -machine virt \
  "${accel_args[@]}" \
  -cpu "$cpu" \
  -smp 2 \
  -m "$memory" \
  -display none \
  -monitor none \
  -kernel "$kernel" \
  -append "root=/dev/vda rw rootwait console=ttyAMA0 ip=dhcp sensornode.device_id=$name" \
  -drive "if=none,file=$state/rootfs.ext4,format=raw,id=hd0" \
  -device virtio-blk-device,drive=hd0 \
  -netdev "user,id=net0,hostfwd=tcp:127.0.0.1:${ssh_port}-:22,hostfwd=tcp:127.0.0.1:${app_port}-:8080" \
  -device virtio-net-device,netdev=net0 \
  -serial "file:$state/serial.log"
