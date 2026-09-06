{ config, pkgs, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    #sops.age.keyFile = "/home/patroclus/.config/sops/age/keys.txt";
    
    # Explicitly declare host SSH key path for sops-nix service
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };
}
