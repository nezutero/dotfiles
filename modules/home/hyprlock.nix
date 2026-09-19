{ ... }:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 0;
      };

      background = [
        {
          monitor = "";
          path = "$HOME/Pictures/walls/your_name_sky1.jpg";
          blur_size = 4;
          blur_passes = 3;
          noise = 0.0117;
          contrast = 1.3;
          brightness = 0.8;
          vibrancy = 0.21;
          vibrancy_darkness = 0.0;
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "250, 50";
          outline_thickness = 3;
          dots_size = 0.26;
          dots_spacing = 0.15;
          dots_center = true;
          dots_rounding = -1;
          outer_color = "rgb(11111b)";
          inner_color = "rgb(11111b)";
          font_color = "rgb(cdd6f4)";
          fade_on_empty = true;
          placeholder_text = "";
          hide_input = false;
          rounding = -1;
          check_color = "rgb(fab387)";
          fail_color = "rgb(f38ba8)";
          fail_text = "";
          fail_transition = 300;
          position = "0, 75";
          halign = "center";
          valign = "bottom";
        }
      ];

      label = [
        {
          monitor = "";
          text = ''cmd[update:1000] echo $(date +"%H:%M:%S")'';
          color = "rgb(cdd6f4)";
          font_size = 60;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 35";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = ''cmd[update:1000] echo $(date +"%A, %d %B %Y")'';
          color = "rgb(cdd6f4)";
          font_size = 24;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, -35";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = " ❀ ✦ ";
          color = "rgb(cdd6f4)";
          font_size = 15;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 30";
          halign = "center";
          valign = "bottom";
        }
      ];
    };
  };
  stylix.targets.hyprlock.enable = false;
}
