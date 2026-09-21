{ pkgs, ... }:

# modules/home/dwl/default.nix
#
# Replaces both modules/home/hyprland and modules/home/waybar.
# Home-manager options only. Everything else these scripts call
# (dwlb, wbg, swayidle, swaylock, rofi, foot, dunst, grim, slurp,
# cliphist, wl-clipboard, yazi, zathura, mpv, brightnessctl,
# pavucontrol, rofi-bluetooth) is already in your systemPackages.

{
  home.packages = with pkgs; [
    # the compositor, built with the config.h next to this file
    (dwl.override { configH = ./config.h; })

    # needed by the swayidle line in dwl-start (screen off / on)
    wlr-randr

    (writeShellApplication {
      name = "dwl-status";
      runtimeInputs = [ coreutils gawk wireplumber ];
      text = builtins.readFile ../../../scripts/dwl-status.sh;
    })
    (writeShellApplication {
      name = "dwl-start";
      runtimeInputs = [
        coreutils
        dwlb
        wbg
        dunst
        swayidle
        swaylock
        wlr-randr
        cliphist
        wl-clipboard
      ];
      text = builtins.readFile ../../../scripts/dwl-start.sh;
    })
  ];
}
