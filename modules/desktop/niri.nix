{ config, pkgs, lib, ... }:

{
  # Niri window manager configuration
  # Moved from modules/features/desktop.nix

  # UWSM
  # Do I really want to use it with Niri?
  # I came from Hyprland, so it was instinct.
  # But look at: https://yalter.github.io/niri/Example-systemd-Setup.html
  programs.uwsm.enable = true;
  programs.uwsm.waylandCompositors = {
    niri = {
      prettyName = "Niri";
      comment = "Niri compositor managed by UWSM";
      binPath = "${pkgs.niri-unstable}/bin/niri-session";
    };
  };

  # Niri (Love it, but I need to spicy it up a bit)
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };
}
