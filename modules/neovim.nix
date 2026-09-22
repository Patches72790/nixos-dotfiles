{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    configure = {
      customRC = ''
	set expandtab
        set number
        set relativenumber
        set list
      '';

      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ ctrlp-vim blink-cmp telescope-nvim ];
      };
    };

  };

}
