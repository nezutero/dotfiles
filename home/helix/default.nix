{ config, pkgs, ... }:
{
  # Link ~/.config/helix to the TOML config in this repo (same idea as nvim/).
  # A live link, not a store copy, so edits apply after :config-reload.
  xdg.configFile."helix".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/helix/helix";

  home.packages = with pkgs; [
    helix

    # Debugger (lldb-dap) for Rust, C, C++, Zig
    lldb

    # Language servers Helix uses by default for your languages.
    # Many are also in ../nvim/default.nix; listing them twice is fine,
    # and it lets you delete either editor's folder on its own.
    bash-language-server
    clang-tools                       # clangd
    gopls
    jdt-language-server               # jdtls
    rust-analyzer
    zls
    lua-language-server
    python3Packages.python-lsp-server # pylsp
    typescript-language-server
    typescript                        # tsserver, which it runs underneath
    vscode-langservers-extracted      # HTML, CSS, JSON
    superhtml
    marksman                          # Markdown
    nil                               # Nix
    taplo                             # TOML, for editing these config files
  ];

  # Stylix themes Helix through programs.helix, which isn't used here.
  # Disabled so it can't override the theme in config.toml later.
  stylix.targets.helix.enable = false;
}
