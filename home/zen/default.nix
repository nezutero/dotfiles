{ inputs, pkgs, lib, ... }:
{
  home.packages = [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  home.activation.zenBrowser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ZEN_CONFIG="$HOME/.config/zen"
    
    # Exit gracefully if Zen hasn't been launched yet
    if [ ! -d "$ZEN_CONFIG" ]; then
      echo "Zen Browser config directory not found, skipping..."
      exit 0
    fi
    
    # Find the profile directory (*.Default* pattern)
    PROFILE=$(find "$ZEN_CONFIG" -maxdepth 1 -type d -name "*.Default*" | head -n1)
    
    if [ -z "$PROFILE" ]; then
      echo "Zen Browser profile not found, skipping..."
      exit 0
    fi
    
    mkdir -p "$PROFILE/chrome"
    ln -sf ${./user.js} "$PROFILE/user.js"
    ln -sf ${./chrome/userChrome.css} "$PROFILE/chrome/userChrome.css"
  '';
}
