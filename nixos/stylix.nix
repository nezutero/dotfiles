{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts
    jetbrains-mono
    inter
  ];

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";
    polarity = "dark";

    fonts = {
      sansSerif = {
        name = "Inter";
        package = pkgs.inter;
      };
      serif = {
        name = "Noto Serif";
        package = pkgs.noto-fonts;
      };
      monospace = {
        name = "JetBrainsMono Nerd Font Mono";
        package = pkgs.nerd-fonts.jetbrains-mono;
      };
      sizes = {
        applications = 12;
        popups = 24;
      };
    };

    cursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };

    targets = {
      qt.enable = true;
      gtk.enable = true;
    };
  };
}
