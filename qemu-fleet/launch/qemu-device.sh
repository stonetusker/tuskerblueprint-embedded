#!/usr/bin/env bash
set -Eeuo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
source "$root/scripts/lib/common.sh"

name="${DEVICE_NAME:-sensornode-qemu-01}"
kernel="${KERNEL_IMAGE:-}"
rootfs="${ROOTFS_IMAGE:-}"
# DISK_IMAGE (a Mender .uefiimg) boots through UEFI firmware and GRUB so A/B
# slot switching and rollback work. KERNEL_IMAGE + ROOTFS_IMAGE boots directly.
disk="${DISK_IMAGE:-}"
firmware="${QEMU_EFI_FIRMWARE:-/usr/share/qemu-efi-aarch64/QEMU_EFI.fd}"
reset_disk="${RESET_DISK:-0}"
ssh_port="${SSH_PORT:-2222}"
app_port="${APP_PORT:-8081}"
memory="${QEMU_MEMORY_MB:-512}"
accel="${QEMU_ACCEL:-auto}"
cpu="${QEMU_CPU:-}"
state="$root/qemu-fleet/state/$name"

require_command qemu-system-aarch64
mkdir -p "$state"
require_command flock
exec 9>"$state/lock"
flock -n 9 || die "device already running: $name"

if [[ -n "$disk" ]]; then
  require_file "$disk"
  require_file "$firmware"
  # The disk persists across launches: it holds the installed A/B state.
  if [[ "$reset_disk" == "1" || ! -f "$state/disk.img" ]]; then
    cp --reflink=auto --sparse=always "$disk" "$state/disk.img"
  fi
  # A stable per-device MAC derived from the device name.
  mac="52:54:00:$(printf '%s' "$name" | sha256sum | sed -E 's/^(..)(..)(..).*/\1:\2:\3/')"
  boot_args=(
    -bios "$firmware"
    -smbios "type=1,serial=$name"
    -drive "if=none,file=$state/disk.img,format=raw,id=hd0"
    -device virtio-blk-pci,drive=hd0
    -device "virtio-net-pci,netdev=net0,mac=$mac"
  )
  # UEFI must hand the kernel a device tree; the Yocto kernel has no ACPI support.
  machine="virt,acpi=off"
else
  require_file "$kernel"
  require_file "$rootfs"
  cp --reflink=auto --sparse=always "$rootfs" "$state/rootfs.ext4"
  boot_args=(
    -kernel "$kernel"
    -append "root=/dev/vda rw rootwait console=ttyAMA0 ip=dhcp sensornode.device_id=$name"
    -drive "if=none,file=$state/rootfs.ext4,format=raw,id=hd0"
    -device virtio-blk-device,drive=hd0
    -device virtio-net-device,netdev=net0
  )
  machine="virt"
fi

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
info "starting $name using accel=$accel cpu=$cpu app_port=$app_port ssh_port=$ssh_port disk=${disk:-none}"

exec qemu-system-aarch64 \
  -name "$name" \
  -pidfile "$state/qemu.pid" \
  -machine "$machine" \
  "${accel_args[@]}" \
  -cpu "$cpu" \
  -smp 2 \
  -m "$memory" \
  -display none \
  -monitor none \
  "${boot_args[@]}" \
  -netdev "user,id=net0,hostfwd=tcp:127.0.0.1:${ssh_port}-:22,hostfwd=tcp:127.0.0.1:${app_port}-:8080" \
  -serial "file:$state/serial.log"
