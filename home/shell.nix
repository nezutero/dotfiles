{ ... }:
{
  home.sessionVariables = {
    EDITOR = "nvim";
    GIT_EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "foot";
    BROWSER = "zen-beta";
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "fzf"
        "z"
      ];
      theme = "robbyrussell";
    };

    shellAliases = {
      q = "exit";
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      c = "clear";
      gtp = "cd $HOME/projs && clear && ls -a";
      gtd = "cd $HOME/dotfiles";
      gtn = "cd $HOME/notes";
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gcm = "git commit -m";
      gcb = "git checkout -b";
      gco = "git checkout";
      gpl = "git pull";
      gps = "git push";
      gcl = "git clone";
      gbd = "git branch -D";
      gbs = "git switch";
      f = "$HOME/dotfiles/scripts/fzfman.sh";
      timer = "$HOME/dotfiles/scripts/timer.sh";
      mnt = "udisksctl mount -b /dev/sda1";
      umnt = "udisksctl unmount -b /dev/sda1";
      cdf = "cd /run/media/nezutero/KINGSTON";
    };
  };
}
