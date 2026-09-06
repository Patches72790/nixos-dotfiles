#!/usr/bin/env bash
# ==============================================================================
# Idempotent Flake-Based NixOS NAS Installation & Provisioning Script
# ==============================================================================
# Features:
#   - Idempotent: Safely skips disk formatting & ZFS creation if already present
#   - Custom Dotfiles Path: Writes flake files to /etc/dotfiles/nixos
#   - ZFS Mirror OS boot pool + MergerFS ext4 data pool
#   - Flake-native declarative system definition with Git tracking
# ==============================================================================

set -euo pipefail

# --- CONFIGURATION VARIABLES ---
NVME_PRIMARY="/dev/nvme0n1"
NVME_SECONDARY="/dev/nvme1n1"
HDD_1="/dev/sda"
HDD_2="/dev/sdb"
HOSTNAME="orpheus-nas"
ZFS_HOST_ID="8425e349"
POOL_NAME="rpool"

# Target configuration path inside mounted environment (/mnt/etc/dotfiles/nixos)
DOTFILES_DIR="/mnt/etc/dotfiles/nixos"

echo "=== [1/5] Checking and Setting up ZFS Storage Pool ==="
if zpool list -H "${POOL_NAME}" >/dev/null 2>&1; then
  echo "--> ZFS pool '${POOL_NAME}' is already active."
elif zpool import -f "${POOL_NAME}" 2>/dev/null; then
  echo "--> Successfully imported existing ZFS pool '${POOL_NAME}'."
else
  echo "--> No active pool found. Partitioning NVMe drives and building '${POOL_NAME}'..."
  
  # Clear existing labels and partition structures
  zpool labelclear -f "${NVME_PRIMARY}" 2>/dev/null || true
  zpool labelclear -f "${NVME_SECONDARY}" 2>/dev/null || true
  sgdisk --zap-all "${NVME_PRIMARY}" "${NVME_SECONDARY}"
  wipefs -a -f "${NVME_PRIMARY}" "${NVME_SECONDARY}"

  # Create GPT Partitions: 1GB Boot (ef00), Remaining ZFS Pool (bf01)
  sgdisk -n 1:1M:+1G -t 1:ef00 "${NVME_PRIMARY}"
  sgdisk -n 2:0:0    -t 2:bf01 "${NVME_PRIMARY}"
  sgdisk -n 1:1M:+1G -t 1:ef00 "${NVME_SECONDARY}"
  sgdisk -n 2:0:0    -t 2:bf01 "${NVME_SECONDARY}"
  partprobe "${NVME_PRIMARY}" "${NVME_SECONDARY}"

  # Format primary EFI boot partition
  mkfs.fat -F 32 -n NIXBOOT "${NVME_PRIMARY}p1"

  # Create mirrored ZFS pool and root dataset
  zpool create -O mountpoint=none \
               -O acltype=posixacl \
               -O xattr=sa \
               -O compression=on \
               "${POOL_NAME}" mirror "${NVME_PRIMARY}p2" "${NVME_SECONDARY}p2"

  zfs create -o mountpoint=legacy "${POOL_NAME}/root"
fi

echo "=== [2/5] Checking and Setting up ext4 Storage Drives ==="
if ! blkid -L "storage1" >/dev/null 2>&1; then
  echo "--> Formatting storage drive 1 (${HDD_1})..."
  parted -s "${HDD_1}" mklabel gpt mkpart primary ext4 0% 100%
  partprobe "${HDD_1}"
  mkfs.ext4 -F -L storage1 "${HDD_1}1"
else
  echo "--> Storage drive 1 ('storage1') is already formatted."
fi

if ! blkid -L "storage2" >/dev/null 2>&1; then
  echo "--> Formatting storage drive 2 (${HDD_2})..."
  parted -s "${HDD_2}" mklabel gpt mkpart primary ext4 0% 100%
  partprobe "${HDD_2}"
  mkfs.ext4 -F -L storage2 "${HDD_2}1"
else
  echo "--> Storage drive 2 ('storage2') is already formatted."
fi

echo "=== [3/5] Mounting File System Hierarchy ==="
# Mount root ZFS dataset if not mounted
if ! mountpoint -q /mnt; then
  mount -t zfs "${POOL_NAME}/root" /mnt
fi

# Create mount point directories
mkdir -p /mnt/boot
mkdir -p /mnt/mnt/disks/disk1
mkdir -p /mnt/mnt/disks/disk2
mkdir -p /mnt/mnt/storage

# Mount partitions conditionally
mountpoint -q /mnt/boot || mount /dev/disk/by-label/NIXBOOT /mnt/boot
mountpoint -q /mnt/mnt/disks/disk1 || mount /dev/disk/by-label/storage1 /mnt/mnt/disks/disk1
mountpoint -q /mnt/mnt/disks/disk2 || mount /dev/disk/by-label/storage2 /mnt/mnt/disks/disk2

echo "=== [4/5] Provisioning Dotfiles & Flake Configuration ==="
mkdir -p "${DOTFILES_DIR}"

# Generate hardware file inside custom dotfiles path if not present
if [ ! -f "${DOTFILES_DIR}/hardware-configuration.nix" ]; then
  nixos-generate-config --dir "${DOTFILES_DIR}" --root /mnt || true
fi

# Write system configuration.nix
cat <<NIX > "${DOTFILES_DIR}/configuration.nix"
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader and ZFS kernel support
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" "fuse.mergerfs" ];

  # Networking and mandatory ZFS Host ID
  networking.hostName = "${HOSTNAME}";
  networking.hostId = "${ZFS_HOST_ID}";

  # Enable Flakes and experimental CLI features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Core System Packages
  environment.systemPackages = with pkgs; [
    git
    vim
    mergerfs
    smartmontools
  ];

  # MergerFS mount pooling disk1 and disk2 into /storage
  fileSystems."/storage" = {
    fsType = "fuse.mergerfs";
    device = "/disks/disk1:/disks/disk2";
    options = [
      "defaults"
      "nonempty"
      "allow_other"
      "use_ino"
      "cache.files=off"
      "drop_cache_on_close=true"
      "category.create=mfs"
    ];
  };

  system.stateVersion = "24.11";
}
NIX

# Write flake.nix entrypoint
cat <<NIX > "${DOTFILES_DIR}/flake.nix"
{
  description = "NixOS Flake Configuration for DIY NAS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations."${HOSTNAME}" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };
  };
}
NIX

# Symlink /etc/nixos -> /etc/dotfiles/nixos on target system for standard paths
mkdir -p /mnt/etc
ln -sfn "${DOTFILES_DIR#"/mnt"}" /mnt/etc/nixos

# Initialize and stage Git repo (required for Flakes)
cd "${DOTFILES_DIR}"
if [ ! -d ".git" ]; then
  git init
fi
git add .

echo "=== [5/5] Executing Flake Installation ==="
nixos-install --flake "${DOTFILES_DIR}#${HOSTNAME}"

echo "=== Flake Installation Complete! Unmount media and type 'reboot'. ==="
