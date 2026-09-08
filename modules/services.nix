{ lib, config, pkgs, ... }:

{

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  services.cockpit = {
    enable = true;
    port = 9090;
    openFirewall = true;
    settings = {
      WebService = {
	AllowUnencrypted = true;
        Origins = lib.mkForce "http://localhost:9090 https://localhost:9090 http://127.0.0.1:9090";
      };
    };
  };

}
