{ config, pkgs, ... }:

{
  programs.zathura = {
    enable = true;
    options = {
      recolor = true;
      selection-clipboard = "clipboard";
      copy-select = false;
      selection-notification = false;
    };
    mappings = {
      "+" = "zoom in";
      "-" = "zoom out";
      "=" = "zoom in";
      "zi" = "zoom in";
      "zo" = "zoom out";
      "z0" = "zoom default";
      "j" = "scroll down";
      "k" = "scroll up";
      "h" = "scroll left";
      "l" = "scroll right";
      "gg" = "goto top";
      "G" = "goto bottom";
      "<C-d>" = "scroll half-down";
      "<C-u>" = "scroll half-up";
      "<C-f>" = "scroll full-down";
      "<C-b>" = "scroll full-up";
      "r" = "reload";
      "R" = "rotate rotate-cw";
      "i" = "recolor";
      "f" = "toggle_fullscreen";
      "<Tab>" = "toggle_index";
    };
  };
}
