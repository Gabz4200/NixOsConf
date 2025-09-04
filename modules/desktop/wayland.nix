{
  config,
  pkgs,
  lib,
  ...
}: {
  # Wayland configuration
  # Moved from modules/features/desktop.nix

  # Enable the X11 windowing system.
  programs.xwayland.enable = true;
  programs.xwayland.package = pkgs.xwayland;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
}
