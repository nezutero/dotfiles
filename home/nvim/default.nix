{ config, pkgs, ... }:
{
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/nvim/nvim";

  home.packages = with pkgs; [
    neovim

    # Used by plugins
    ripgrep # telescope search
    tree-sitter # nvim-treesitter builds parsers with this
    # (git, gcc and wl-clipboard are already in your system packages)

    # Language servers
    bash-language-server
    clang-tools # clangd
    gopls
    superhtml
    vscode-langservers-extracted # cssls
    jdt-language-server # jdtls
    rust-analyzer
    zls
    marksman
    lua-language-server
    basedpyright
    typescript-language-server
    typescript # tsserver, which ts_ls runs underneath
    nil
  ];
}
