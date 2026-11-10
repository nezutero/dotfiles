{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./stylix.nix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;

  # Memory: compressed RAM swap first, swapfile as fallback
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    priority = 100;
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 17 * 1024;
      options = [ "pri=10" ];
    }
  ];

  # Network
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "default";
  services.resolved.enable = false;

  # User
  users.users.nezutero = {
    isNormalUser = true;
    description = "nezutero";
    extraGroups = [
      "networkmanager"
      "wheel"
      "kvm"
    ];
    shell = pkgs.zsh;
  };

  # Time and language
  time.timeZone = "Europe/Paris";

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

  # Login screen: tuigreet, then Sway
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
      user = "greeter";
    };
  };

  programs.sway.enable = true;
  programs.zsh.enable = true;
  programs.dconf.enable = true;

  # Screen sharing: always capture the laptop screen, no picker
  xdg.portal.wlr.settings.screencast = {
    output_name = "eDP-1";
    chooser_type = "none";
  };

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Removable drives
  services.udisks2.enable = true;
  services.gvfs.enable = true; # helps GTK apps / file managers see removable media

  # Run prebuilt (non-Nix) binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    icu
  ];

  environment.variables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
    PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
    PASSWORD_STORE_EXTENSIONS_DIR = "/run/current-system/sw/lib/password-store/extensions/";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Neovim and its language servers are in ../home/nvim/default.nix
  environment.systemPackages = with pkgs; [
    # Desktop (Sway)
    sway
    swayidle
    swaybg
    swaylock
    wlsunset
    tuigreet
    foot
    rofi
    rofi-bluetooth
    dunst
    libnotify
    cliphist
    wl-clipboard
    grim
    slurp
    wtype
    wev
    brightnessctl
    pavucontrol
    adwaita-icon-theme
    jetbrains-mono

    # Command line
    zsh
    tmux
    git
    wget
    dig
    jq
    fzf
    fd
    tree
    ncdu
    btop
    fastfetch
    killall
    zip
    unzip
    yazi
    zbar
    imagemagick
    (pass.withExtensions (exts: with exts; [ pass-otp ]))
    gnupg
    pinentry-gnome3

    # Programming
    gcc
    gdb
    glibc
    go
    rustc
    cargo
    nodejs
    python3
    python314
    jdk21
    vscodium
    android-tools

    # Containers and VMs
    podman
    docker
    distrobox
    qemu

    # Documents
    pandoc
    typst
    zathura
    onlyoffice-desktopeditors

    # Media
    imv
    mpv
    drawy
    obs-studio

    # Messaging
    thunderbird
    telegram-desktop
    signal-desktop

    # Other
    tor-browser
  ];

  # Nix settings
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  nixpkgs.config.allowUnfree = true;

  # Automatic upgrades and maintenance
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  # Services
  hardware.bluetooth.enable = false;
  services.blueman.enable = false;

  virtualisation.podman.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  system.stateVersion = "26.05";
}
