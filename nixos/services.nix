{ pkgs, ... }:
{
  hardware.bluetooth.enable = false;
  services.blueman.enable = false;
  virtualisation.podman.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };
}
