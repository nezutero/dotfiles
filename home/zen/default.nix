{ inputs, pkgs, lib, ... }:
{
  home.packages = [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  home.activation.zenBrowser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    PROFILE=""
    if [ -d "$HOME/.config/zen" ]; then
      PROFILE=$(find "$HOME/.config/zen" -maxdepth 1 -type d -name "*.Default*" | head -n1)
    fi

    if [ -n "$PROFILE" ]; then
      mkdir -p "$PROFILE/chrome"
      ln -sf ${./user.js} "$PROFILE/user.js"
      ln -sf ${./chrome/userChrome.css} "$PROFILE/chrome/userChrome.css"
      ln -sf ${./chrome/userContent.css} "$PROFILE/chrome/userContent.css"
    else
      echo "Zen profile not found (open Zen once, then rebuild); skipping"
    fi
  '';
}
