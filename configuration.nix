{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/system.nix
    ./modules/users.nix
    ./modules/services.nix
    ./modules/storage.nix
    ./modules/programs.nix
    ./modules/containers.nix
    ./modules/sops.nix
    ./modules/samba.nix
    ./modules/tailscale.nix
  ];

  

  # Enable Flakes and experimental CLI features
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Core System Packages
  environment.systemPackages = with pkgs; [
    git
    vim
	zsh
    mergerfs
    smartmontools
    compose2nix
    sops
    ssh-to-age
    age
    nixfmt
    tree
  ];

programs.zsh.enable = true;

  programs.git = {
    enable = true;
    config.alias = {
	s = "status";
	ci = "commit";
	co = "checkout";
	df = "diff";
	lg = "log";
	a = "add";
	};

      config.push = { autoSetupRemote = true; };
  };

environment.shellAliases = {
	ll = "ls -lh";
	gst = "git s";
	ga = "git a";
	gd = "git df";
	gcam = "git c -am";
	nixflkup = "nix flake update --flake /etc/dotfiles/nixos";
	nixrbsw = "sudo nixos-rebuild switch --flake /etc/dotfiles/nixos#orpheus-nas";
};

  system.stateVersion = "24.11";
}
