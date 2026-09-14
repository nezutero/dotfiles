{ config, pkgs, lib, ... }:
{
  programs.rofi = {
    enable = true;
    extraConfig = {
      modi = "drun";
      show-icons = false;
      display-drun = ">";
    };
  };

  xdg.configFile."rofi/config.rasi".force = true;
  xdg.configFile."rofi/config.rasi".text = ''
    ${builtins.readFile ./theme.rasi}
  '';
}
