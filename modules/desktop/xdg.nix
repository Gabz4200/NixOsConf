{ config, pkgs, lib, ... }:

{
  # XDG Desktop Integration
  # This module will handle XDG-related configurations

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  # When xdg.portal is enabled in Home Manager and home-manager.useUserPackages = true,
  # make sure these paths are linked system-wide so portals and desktop entries are visible.
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];
}
