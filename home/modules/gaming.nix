{ pkgs, ... }:

{
  # Gaming-related configurations and packages

  # Enable gaming launchers/tools managed via HM
  programs.lutris.enable = true;

  # Gaming packages
  home.packages = with pkgs; [
    bottles
  ];
}
