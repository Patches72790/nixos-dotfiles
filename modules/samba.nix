{ config, pkgs, ... }:

{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "orpheus-samba-nix";
        "netbios name" = "orpheus-samba-nix";
        "security" = "user";
        "use sendfile" = "yes";
        #"max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "192.168.1.0/24 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "map to guest" = "bad user";
      };
      public = {
        "path" = "/mnt/storage/samba-share/public";
        "browseable" = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "valid users" = "@nas-users";
      };
      private = {
        "path" = "/mnt/storage/samba-share/private";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "ea support" = "yes";
        "create mask" = "0660";
        "directory mask" = "0770";
        "valid users" = "@nas-users";
        "force group" = "nas-users";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [
    445
    139
  ];
  networking.firewall.allowedUDPPorts = [
    137
    138
  ];
}
