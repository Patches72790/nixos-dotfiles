#!/usr/bin/env bash
set -e

echo "=== Importing ZFS pool 'rpool'"
sudo zpool import -f -R /mnt rpool 2>/dev/null || true

echo "=== Mounting ZFS root dataset to /mnt"
sudo mountpoint -q /mnt || sudo mount -t zfs rpool/root /mnt

echo "=== Mounting EFI boot partition to /mnt/boot"
sudo mkdir -p /mnt/boot
sudo mountpoint -q /mnt/boot || sudo mount /dev/disk/by-label/NIXBOOT /mnt/boot

echo "System mounted at /mnt"
ls -lah /mnt
