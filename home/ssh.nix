{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };
      "codeberg.org" = {
        HostName = "codeberg.org";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
      };

    };
  };

  home.activation.sshKeygen = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    KEY="${config.home.homeDirectory}/.ssh/id_ed25519"

    if [ ! -f "$KEY" ]; then
      mkdir -p "${config.home.homeDirectory}/.ssh"
      chmod 700 "${config.home.homeDirectory}/.ssh"

      ${pkgs.openssh}/bin/ssh-keygen -q \
        -t ed25519 \
        -C "me@nezutero.dev" \
        -f "$KEY" \
        -N ""

      ${pkgs.wl-clipboard}/bin/wl-copy < "$KEY.pub" 2>/dev/null || true

      echo "SSH key generated (copied to clipboard)"
      cat "$KEY.pub"
    fi
  '';
}
