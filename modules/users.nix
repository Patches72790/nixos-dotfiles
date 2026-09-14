{ config, pkgs, ... }:

{
  
  users.groups.dotfiles = {};
  users.groups.nas-users = {};
  users.users.root.initialPassword = "nixos";

  users.users.patroclus = {
    isNormalUser = true;
    description = "Orpheus NAS Primary User (Me)";
    extraGroups = [ "wheel" "dotfiles" "nas-users" ];
   # openssh.authorizedKeys.keys = [
   # ];
  }; 

}
