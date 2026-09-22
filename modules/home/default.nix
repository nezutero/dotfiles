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
    ./nvim.nix
    ./swaylock.nix

    ./waybar
    ./sway
    ./rofi
    ./zen
  ];
}
