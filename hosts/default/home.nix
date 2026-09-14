{ inputs, ... }:

{
  imports = [
    ../../modules/home
  ];

  home.username = "nezutero";
  home.homeDirectory = "/home/nezutero";
  home.stateVersion = "26.05";
}
