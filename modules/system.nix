{
  config,
  pkgs,
  lib,
  ...
}:

{
  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;

  # Networking and mandatory ZFS Host ID
  networking.hostName = "orpheus-nas";
  networking.hostId = "8425e349";
  networking.useDHCP = true;
  networking.useNetworkd = true;

  systemd.services."getty@tty1".enable = true;

  boot = {
    initrd = {
        kernelModules = [ "amdgpu" ];
        availableKernelModules = ["r8169" "r8152" "e1000e" "igc" "tg3"];
    };

    kernelParams = [
      "console=tty1"
      "fbcon=map:1"
      "video=HDMI-A-1:1920x1080@60"
    ];

    zfs.forceImportRoot = false;

    supportedFilesystems = [
      "zfs"
      "fuse.mergerfs"
    ];

    loader = {
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
  };

}
