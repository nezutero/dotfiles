{ config, pkgs, ... }:
{
  # Link ~/.config/nvim to the Lua config in this repo.
  # mkOutOfStoreSymlink takes a plain string path, so the link points at your
  # real folder instead of a read-only copy in /nix/store. That's what lets
  # edits apply without a rebuild and lets vim.pack write its lockfile.
  # Change this path if your dotfiles live somewhere else (run `pwd` inside nvim/nvim).
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/modules/home/nvim/nvim";

  # Replaces nvf's vimAlias (only works if Home Manager manages your shell)
  home.shellAliases.vim = "nvim";

  home.packages = with pkgs; [
    neovim

    # Used by plugins
    git
    ripgrep      # telescope search
    tree-sitter  # nvim-treesitter builds parsers with this...
    gcc          # ...and a C compiler
    wl-clipboard # "+y / "+p on Wayland

    # Language servers
    bash-language-server
    clang-tools                  # clangd
    gopls
    superhtml
    vscode-langservers-extracted # cssls
    jdt-language-server          # jdtls
    rust-analyzer
    zls
    marksman
    lua-language-server
    basedpyright
    typescript-language-server
    typescript                   # tsserver, which ts_ls runs underneath
    nil
  ];
}
