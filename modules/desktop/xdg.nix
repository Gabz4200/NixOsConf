{ config, pkgs, lib, ... }:

{
  # XDG Desktop Integration
  # This module will handle XDG-related configurations

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };
}
