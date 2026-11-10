{ config, ... }:

{
  home.sessionPath = [
    "${config.home.homeDirectory}/dotfiles/scripts"
  ];

  xdg.desktopEntries.nvim = {
    name = "Neovim";
    exec = "nvim %F";
    terminal = true;
    type = "Application";
    mimeType = [
      "text/plain"
      "text/markdown"
      "application/json"
    ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "zen-beta.desktop";

      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/bmp" = "imv.desktop";

      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/webm" = "mpv.desktop";

      "audio/mpeg" = "rmpc.desktop";
      "audio/flac" = "rmpc.desktop";
      "audio/ogg" = "rmpc.desktop";
      "audio/wav" = "rmpc.desktop";

      "text/plain" = "nvim.desktop";
      "text/markdown" = "nvim.desktop";
      "application/json" = "nvim.desktop";
      "text/xml" = "nvim.desktop";
      "application/xml" = "nvim.desktop";

      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
        "onlyoffice-impress.desktop";
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
        "onlyoffice-impress.desktop";
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "onlyoffice-calc.desktop";
      "application/vnd.ms-word.document.macroEnabled.12" = "onlyoffice-impress.desktop";
      "application/vnd.ms-powerpoint.presentation.macroEnabled.12" = "onlyoffice-impress.desktop";
      "application/msword" = "onlyoffice-impress.desktop";
      "application/vnd.ms-powerpoint" = "onlyoffice-impress.desktop";
      "application/vnd.ms-excel" = "onlyoffice-calc.desktop";
    };
  };

  xdg.configFile."mimeapps.list".force = true;
}
