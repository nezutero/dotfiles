{ pkgs, ... }:
{
  gtk = {
    enable = true;
    font.name = "Inter";
    font.size = 12;

    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
  };
}
