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
        { timeout = 300; command = lock; }
        { timeout = 330; command = display "off"; resumeCommand = display "on"; }
        { timeout = 600; command = "systemctl suspend"; }
      ];
      events = [
        { event = "before-sleep"; command = lock; }
        { event = "lock"; command = lock; }
      ];
    };
}
