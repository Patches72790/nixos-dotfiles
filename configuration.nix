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
  networking.hostName = "orpheus-nas";
  networking.hostId = "8425e349";

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
