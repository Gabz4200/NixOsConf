{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.desktop.wayland;
in {
  # Wayland configuration
  # Moved from modules/features/desktop.nix

  options.desktop.wayland = {
    enable = lib.mkEnableOption "Enable Wayland configuration and Wayland-related settings";
    unstable = lib.mkEnableOption "Enable unstable Wayland features and experimental configurations";
  };

  config = lib.mkIf cfg.enable {
    # Enable the X11 windowing system.
    programs.xwayland.enable = true;
    programs.xwayland.package = pkgs.xwayland;

    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;
  };
}
