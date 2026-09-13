{ config, ... }:
{
  programs.swaylock = {
    enable = true;
    settings = {
      image = "${config.home.homeDirectory}/Pictures/walls/your_name_sky1.jpg";
      scaling = "fill";
      font = "JetBrainsMono Nerd Font";
      font-size = 24;

      indicator = true;
      indicator-radius = 100;
      indicator-thickness = 7;

      ring-color = "11111b";
      inside-color = "11111b";
      text-color = "cdd6f4";
      line-color = "00000000";
      separator-color = "00000000";

      key-hl-color = "fab387";

      ring-wrong-color = "f38ba8";
      inside-wrong-color = "11111b";
      text-wrong-color = "f38ba8";

      show-failed-attempts = true;
      indicator-idle-visible = false;
    };
  };
}
