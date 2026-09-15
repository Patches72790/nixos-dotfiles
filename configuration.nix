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
    ./modules/samba.nix
  ];

  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = true;

    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      configurationLimit = 5;
      mirroredBoots = [
        {
          path = "/boot";
          devices = [ "/dev/disk/by-uuid/B8CB-5E4B" ];
        }
        {
          path = "/boot-secondary";
          devices = [ "/dev/disk/by-uuid/12CE-A600" ];
        }
      ];
    };
  };

  boot.supportedFilesystems = [
    "zfs"
    "fuse.mergerfs"
  ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.zfs.forceImportRoot = false;
  boot.initrd.availableKernelModules = [
    "r8169"
    "r8152"
    "e1000e"
    "igc"
    "tg3"
  ];

  boot.kernelParams = [
    "console=tty1"
    "fbcon=map:1" # Forces TTY console onto fb1 (AMD GPU) instead of fb0 (BMC)
    "video=HDMI-A-1:1920x1080@60" # Forces active signal out the connected HDMI port
  ];

  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;

  # Networking and mandatory ZFS Host ID
  networking.hostName = "orpheus-nas";
  networking.hostId = "8425e349";
  networking.useDHCP = true;
  networking.useNetworkd = true;

  systemd.services."getty@tty1".enable = true;

  # Enable Flakes and experimental CLI features
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

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
    nixfmt
    tree
    kepubify
  ];

  system.stateVersion = "24.11";
}
