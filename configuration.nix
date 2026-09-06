{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/users.nix
    ./modules/services.nix
    ./modules/storage.nix
    ./modules/programs.nix
    ./modules/containers.nix
    ./modules/sops.nix
  ];


  # Bootloader and ZFS kernel support
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" "fuse.mergerfs" ];
  boot.kernelParams = [ "console=tty1" ];
  boot.zfs.forceImportRoot = false;
  boot.initrd.availableKernelModules = ["r8169" "r8152" "e1000e" "igc" "tg3"];

  # Networking and mandatory ZFS Host ID
  networking.hostName = "orpheus-nas";
  networking.hostId = "8425e349";
  networking.useDHCP = true;
  networking.useNetworkd = true;

  systemd.services."getty@tty1".enable = true;

  # Enable Flakes and experimental CLI features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Core System Packages
  environment.systemPackages = with pkgs; [
    git
    vim
    mergerfs
    smartmontools
    compose2nix
    sops
    ssh-to-age
    age
  ];

  system.stateVersion = "24.11";
}
