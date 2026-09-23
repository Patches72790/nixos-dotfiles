{
  lib,
  config,
  pkgs,
  ...
}:

{

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  services.cockpit = {
    enable = true;
    port = 9090;
    openFirewall = true;
    plugins = [
      pkgs.cockpit-podman
      pkgs.cockpit-machines
      pkgs.cockpit-files
    ];
    settings = {
      WebService = {
        AllowUnencrypted = true;

        # This tells Cockpit how to handle cookie security flags over unencrypted connections
        ProtocolHeader = "X-Forwarded-Proto"; 
        
        # Use http:// explicitly in your Origins list
        Origins = lib.mkForce "http://127.0.0.1:9090 http://localhost:9090 http://orpheus-nas:9090";
      };
    };
  };

}
