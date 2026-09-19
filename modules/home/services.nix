{
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = [
        {
          monitor = "eDP-1";
          path = "/home/nezutero/Pictures/walls/your_name_sky1.jpg";
          fit_mode = "cover";
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "hyprlock";
        before_sleep_cmd = "hyprlock";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 600;
          on-timeout = "brightnessctl -e4 -s set 25%";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 1200;
          on-timeout = "hyprlock";
        }
        {
          timeout = 1800;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 102400; # see note above — likely meant 2400 (40min)
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 35;
      STOP_CHARGE_THRESH_BAT0 = 85;

      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };

  services.power-profiles-daemon.enable = false;
}
