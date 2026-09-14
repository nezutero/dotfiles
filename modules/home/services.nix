{ pkgs, ... }:
{
  services.swayidle =
    let
      lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
      display = status: "swaymsg 'output * power ${status}'";
    in
    {
      enable = true;
      systemdTargets = [ "graphical-session.target" ];
      timeouts = [
        {
          timeout = 300;
          command = lock;
        }
        {
          timeout = 330;
          command = display "off";
          resumeCommand = display "on";
        }
        {
          timeout = 600;
          command = "systemctl suspend";
        }
      ];
      events = [
        {
          event = "before-sleep";
          command = lock;
        }
        {
          event = "lock";
          command = lock;
        }
      ];
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
