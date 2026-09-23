{ config, pkgs, ... }:
{

  programs.zsh.enable = true;

  programs.git = {
    enable = true;
    config.alias = {
      s = "status";
      p = "push";
      pl = "pull";
      ci = "commit";
      co = "checkout";
      df = "diff";
      lg = "log";
      a = "add";
    };

    config.push = {
      autoSetupRemote = true;
    };
  };

}
