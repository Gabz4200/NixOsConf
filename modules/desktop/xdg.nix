{
  config,
  lib,
  ...
}: let
  cfg = config.desktop.xdg;
in {
  # XDG Desktop Integration
  # This module will handle XDG-related configurations

  options.desktop.xdg = {
    enable = lib.mkEnableOption "Enable XDG desktop integration and XDG-related configurations";
    unstable = lib.mkEnableOption "Enable unstable XDG features and experimental configurations";
  };

  config = lib.mkIf cfg.enable {
    xdg.icons.enable = true;
    xdg.menus.enable = true;
    xdg.sounds.enable = true;
    xdg.terminal-exec.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "br";
      variant = "";
    };
  };
}
