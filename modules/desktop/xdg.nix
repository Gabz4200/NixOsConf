{
  config,
  pkgs,
  lib,
  ...
}: {
  # XDG Desktop Integration
  # This module will handle XDG-related configurations

  xdg.icons.enable = true;
  xdg.menus.enable = true;
  xdg.sounds.enable = true;
  xdg.terminal-exec.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };
}
