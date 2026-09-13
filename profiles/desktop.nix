{ config, pkgs, ... }:

{
  imports = [
    ../modules/nixos/nix.nix
    ../modules/nixos/fonts.nix
    ../modules/nixos/maintenance.nix
    ../modules/nixos/services.nix
    #../modules/nixos/nextdns.nix
  ];

  users.users."nezutero" = {
    isNormalUser = true;
    description = "nezutero";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
  };

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "en_GB.UTF-8/UTF-8"
    "fr_FR.UTF-8/UTF-8"
  ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  programs.hyprland.enable = true;

  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
        user = "greeter";
      };
    };
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # IF SWAY: swayfx wlsunset swayidle swaybg swaylock
  environment.systemPackages = with pkgs; [
    sway
    swayidle
    wlsunset
    neovim
    clang
    clang-tools
    glibc
    lua-language-server
    nil
    wget
    rofi
    python314
    zbar
    libnotify
    wtype
    foot
    (pass.withExtensions (exts: with exts; [ pass-otp ]))
    jq
    dunst
    btop
    wl-clipboard
    grim
    slurp
    gimp
    wev
    tmux
    brightnessctl
    cliphist
    yazi
    ncdu
    podman
    pavucontrol
    fastfetch
    imagemagick
    fzf
    eza
    bat
    rofi-bluetooth
    jetbrains-mono
    zsh
    fd
    adwaita-icon-theme
    ripgrep
    imv
    mpv
    git
    cheese
    jdk
    jdt-language-server
    thunderbird
    protonmail-bridge
    vesktop
    dig
    android-tools
    gdb
    zathura
    obs-studio
    onlyoffice-desktopeditors
    tree
    docker
    distrobox
    tuigreet
    gcc
    rustc
    python3
    cargo
    gnupg
    pinentry-curses
    hyprpaper
    hyprsunset
    hyprlock
    hypridle
    telegram-desktop
    signal-desktop
    nodejs
    go
    unzip
    killall
  ];

  services.udisks2.enable = true;
  services.gvfs.enable = true; # helps GTK apps / file managers see removable media

  hardware.bluetooth.enable = false;
  services.blueman.enable = false;

  environment.variables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
    PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
    PASSWORD_STORE_EXTENSIONS_DIR = "/run/current-system/sw/lib/password-store/extensions/";
  };

  programs.zsh.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    icu
  ];
}
