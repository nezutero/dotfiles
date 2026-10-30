{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "rofipass" (builtins.readFile ../../scripts/rofipass.sh))
    (pkgs.writeShellScriptBin "rofi-power-menu" (builtins.readFile ../../scripts/rofi-power-menu.sh))
    (pkgs.writeShellScriptBin "volume" (builtins.readFile ../../scripts/volume.sh))
    (pkgs.writeShellScriptBin "backlight" (builtins.readFile ../../scripts/backlight.sh))
    (pkgs.writeShellScriptBin "temperature" (builtins.readFile ../../scripts/temperature.sh))
    (pkgs.writeShellScriptBin "battery-notify" (builtins.readFile ../../scripts/battery-notify.sh))
    (pkgs.writeShellScriptBin "fzfman" (builtins.readFile ../../scripts/fzfman.sh))
    (pkgs.writeShellScriptBin "manga-prep" (builtins.readFile ../../scripts/manga-prep.sh))
    (pkgs.writeShellScriptBin "youtube-mpv" (builtins.readFile ../../scripts/youtube-mpv.sh))
    (pkgs.writeShellScriptBin "zathura-rofi" (builtins.readFile ../../scripts/zathura-rofi.sh))
  ];
}
