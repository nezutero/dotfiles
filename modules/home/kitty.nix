{
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 16.5;
    };

    settings = {
      window_padding_width = 1;

      scrollback_lines = 10000;
      wheel_scroll_multiplier = "1.0";

      cursor_shape = "block";

      background_opacity = "0.8";
      background = "#000000";
      foreground = "#c5c9c5";

      # normal colors (regular0-7 -> color0-7)
      color0 = "#090618";
      color1 = "#c34043";
      color2 = "#76946a";
      color3 = "#c0a36e";
      color4 = "#7e9cd8";
      color5 = "#957fb8";
      color6 = "#6a9589";
      color7 = "#c8c093";

      # bright colors (bright0-7 -> color8-15)
      color8 = "#727169";
      color9 = "#e82424";
      color10 = "#98bb6c";
      color11 = "#e6c384";
      color12 = "#7fb4ca";
      color13 = "#938aa9";
      color14 = "#7aa89f";
      color15 = "#dcd7ba";

      # selection
      selection_background = "#2d4f67";
      selection_foreground = "#c8c093";
    };
  };

  stylix.targets.kitty.enable = false;
}
