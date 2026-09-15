{ config, pkgs, ... }:

{
  imports = [
    ./servarr-project.nix
  ];

  networking.firewall.allowedTCPPorts = [ 8083 ];

  virtualisation.docker.enable = true;
  virtualisation.oci-containers = {
    backend = "docker";

    containers = {

      calibre = {
        image = "lscr.io/linuxserver/calibre-web:latest";
        autoStart = true;
        ports = [ "8083:8083" ];

        environment = {
          PUID = "1000";
          PGID = "992";
          TZ = "America/Chicago";
        };

        volumes = [
          "/mnt/storage/servarr-config/calibre:/config"
          "/mnt/storage/data/media/books:/books"

        ];

      };

    };
  };
}
