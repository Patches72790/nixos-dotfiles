{ config, pkgs, ... }:

{
  # MergerFS mount pooling disk1 and disk2 into /storage
  fileSystems."/mnt/storage" = {
    fsType = "fuse.mergerfs";
    device = "/mnt/disks/disk1:/mnt/disks/disk2";
    options = [
      "defaults"
      "nonempty"
      "allow_other"
      "use_ino"
      "cache.files=off"
      "drop_cache_on_close=true"
      "category.create=mfs"
      "x-systemd.after=mnt-disks-disk1.mount"
      "x-systemd.after=mnt-disks-disk2.mount"
      "x-systemd.automount"
      "nofail"
    ];
  };

  fileSystems."/mnt/disks/disk1" = {
    device = "/dev/disk/by-label/storage1";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  }; 

  fileSystems."/mnt/disks/disk2" = {
    device = "/dev/disk/by-label/storage2";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  }; 

}
