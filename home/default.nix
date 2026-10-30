{ ... }:

{
  imports = [
    ./git.nix
    ./ssh.nix
    ./xdg.nix
    ./shell.nix
    ./foot.nix
    ./tmux.nix
    ./yazi.nix
    ./dunst.nix
    ./zathura.nix
    ./fastfetch.nix
    ./scripts.nix
    ./swaylock.nix

    ./nvim
    ./waybar
    ./sway
    ./rofi
    ./zen
  ];

  home.username = "nezutero";
  home.homeDirectory = "/home/nezutero";
  home.stateVersion = "26.05";
}
