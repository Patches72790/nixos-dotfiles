#!/usr/bin/env bash
set -e

echo "=== Umounting /mnt recursively..."
sudo umount -R /mnt 2>/dev/null || true

echo "Export ZFS pool 'rpool' ... "
sudo zpool export rpool 2>/dev/null || true

echo "Cleaned up. Ready to reboot."
