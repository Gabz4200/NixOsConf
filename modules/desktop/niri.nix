{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.desktop.niri;
in {
  # Niri window manager configuration
  # Moved from modules/features/desktop.nix

  options.desktop.niri = {
    enable = lib.mkEnableOption "Enable Niri window manager configuration";
    unstable = lib.mkEnableOption "Enable unstable Niri features and experimental configurations";
  };

  config = lib.mkIf cfg.enable {
    # UWSM
    #todo: Adress it.
    # Do I really want to use it with Niri?
    # I came from Hyprland, so it was instinct.
    # But look at: https://yalter.github.io/niri/Example-systemd-Setup.html
    programs.uwsm.enable = true;
    programs.uwsm.waylandCompositors = {
      niri = {
        prettyName = "Niri";
        comment = "Niri compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/niri-session";
      };
    };

    # Niri (Love it, but I need to spicy it up a bit)
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
  };
}
