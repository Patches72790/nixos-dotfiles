{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  users.users.root.initialPassword = "nixos";

  # Bootloader and ZFS kernel support
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" "fuse.mergerfs" ];
  boot.kernelParams = [ "console=tty1" "video=efifb:off" ];
  boot.zfs.forceImportRoot = false;
  boot.initrd.availableKernelModules = ["r8169" "r8152" "e1000e" "igc" "tg3"];

  # Networking and mandatory ZFS Host ID
  networking.hostName = "orpheus-nas";
  networking.hostId = "8425e349";
  networking.useDHCP = true;
  networking.useNetworkd = true;

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
    ];
  };

  system.stateVersion = "24.11";
}
