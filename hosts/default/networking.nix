{ ... }:

{
  networking.networkmanager.enable = true;

  networking.networkmanager.dns = "default";

  services.resolved.enable = false;
}
