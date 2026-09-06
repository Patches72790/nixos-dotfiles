{ config, pkgs, ... }: 
{

  programs.git = {
    enable = true;
    config = {
      alias = {
         gd = "diff";
	 gst = "status";
	 gcam = "commit -am";
	 glg = "log --oneline --graph --decorate --all";
      };
    };
  };
  
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
}
