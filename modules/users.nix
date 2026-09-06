{ config, pkgs, ... }:

{
  
  users.groups.dotfiles = {};
  users.users.root.initialPassword = "nixos";

  users.users.patroclus = {
    isNormalUser = true;
    description = "Orpheus NAS Primary User (Me)";
    extraGroups = [ "wheel" "dotfiles" ];
   # openssh.authorizedKeys.keys = [
   # ];
  }; 

}
