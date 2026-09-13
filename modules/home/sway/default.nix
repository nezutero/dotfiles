{ config, ... }:
{
  xdg.configFile."sway/config".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/modules/home/sway/config";
}
