{ config, ... }:
{
  programs.swaylock = {
    enable = true;
    settings = {
      image = "${config.home.homeDirectory}/Pictures/walls/your_name_sky1.jpg";
      scaling = "fill";

      indicator = true;
      indicator-radius = 100;
      indicator-thickness = 7;

      line-color = "00000000";
      separator-color = "00000000";

      show-failed-attempts = true;
      indicator-idle-visible = false;
    };
  };
}
