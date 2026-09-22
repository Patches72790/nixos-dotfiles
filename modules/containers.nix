{ config, pkgs, ... }:

{
  imports = [
    ./servarr-project.nix
  ];

  networking.firewall.allowedTCPPorts = [ 8083 ];

  sops.templates."calibre-environment.env".content = ''

    HARDCOVER_TOKEN="${config.sops.placeholder.hardcover_calibre_api_key}"
  '';

  virtualisation.docker.enable = true;
  virtualisation.oci-containers = {
    backend = "docker";

    containers = {

      calibre = {
        image = "crocodilestick/calibre-web-automated:latest";
        autoStart = true;
        ports = [ "8083:8083" ];

        environmentFiles = [
          config.sops.templates."calibre-environment.env".path
        ];

        environment = {
          PUID = "1000";
          PGID = "992";
          TZ = "America/Chicago";
          NETWORK_SHARE_MODE = "false";
          CWA_PORT_OVERRIDE = "8083";
        };

        volumes = [
          "/mnt/storage/servarr-config/calibre:/config"
          "/mnt/storage/servarr-config/calibre-plugins:/config/.config/calibre/plugins"
          "/mnt/storage/data/media/books:/calibre-library"
          "/mnt/storage/data/calibre-books-ingest:/cwa-books-ingest"
        ];
      };
    };
  };
}
