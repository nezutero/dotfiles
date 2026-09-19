{
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 10000;
    baseIndex = 1;
    prefix = "C-a";
    keyMode = "vi";
    mouse = false;

    extraConfig = ''
      set -ga terminal-overrides ",screen-250color*:Tc"
      set-option -g status-position bottom
      set -g status-style "fg=#808080"
      set -g window-style "bg=default"
      set -g window-active-style "bg=default"
      set -g status-left ""
      set -g window-status-format "#I:#W "
      set -g window-status-current-format "#I:#W "
      set -g window-status-current-style "fg=#c5c9c5"
      set -g status-right "#S"
      bind r source-file ~/.config/tmux/tmux.conf
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
      bind -r ^ last-window
      bind -r k select-pane -U
      bind -r j select-pane -D
      bind -r h select-pane -L
      bind -r l select-pane -R
    '';
  };
}
