{ config, ... }:
{
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/modules/home/nvim/nvim";

  home.shellAliases.vim = "nvim";
}
