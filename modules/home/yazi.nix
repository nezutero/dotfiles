{ config, pkgs, lib, ... }:

{
  programs.yazi = {
    enable = true;
    settings = {
      preview = {
        tab_size = 2;
        max_width = 600;
        max_height = 900;
        cache_dir = "";
        image_filter = "triangle";
        image_quality = 75;
        sixel_fraction = 15;
      };
      mgr = {
        show_hidden = true;
      };
    };
  };
}
