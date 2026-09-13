{ ... }:

{
  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "weekly";

  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 7d";

  nix.settings.auto-optimise-store = true;

  nix.optimise.automatic = true;
  nix.optimise.dates = [ "weekly" ];
}
