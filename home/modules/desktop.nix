{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.home.desktop;
in {
  # Desktop environment configs: XDG and session services

  options.home.desktop = {
    enable = lib.mkEnableOption "Enable desktop environment configurations and desktop-related settings";
    unstable = lib.mkEnableOption "Enable unstable desktop features and experimental configurations";
  };

  config = lib.mkIf cfg.enable {
    # XDG base and user dirs
    xdg = {
      enable = true;

      userDirs = {
        enable = true;
        createDirectories = true;

        desktop = "$HOME/Desktop";
        documents = "$HOME/Documents";
        download = "$HOME/Downloads";
        music = "$HOME/Music";
        pictures = "$HOME/Pictures";
        videos = "$HOME/Videos";

        # Custom
        extraConfig = {
          XDG_PROJECTS_DIR = "$HOME/Projects";
          XDG_SCREENSHOTS_DIR = "$HOME/Pictures/Screenshots";
        };
      };

      mime.enable = true;
    };

    # XDG portals for Wayland/Niri
    xdg.portal.enable = true;
    xdg.portal.xdgOpenUsePortal = true;
    xdg.portal.config = {
      niri = {
        "default" = ["gnome" "gtk"];
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
        "org.freedesktop.impl.portal.Access" = ["gtk"];
        "org.freedesktop.impl.portal.Notification" = ["gtk"];
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
      };
    };
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      gnome-keyring
    ];
    xdg.portal.configPackages = with pkgs; [
      niri-unstable
    ];

    xdg.autostart.enable = true;
    xdg.mimeApps.enable = true;
    xdg.terminal-exec.enable = true;

    # Desktop services
    services.gnome-keyring.enable = true;
    services.easyeffects.enable = true;
    services.swayosd = {
      enable = true;
    };
    services.swayidle.enable = true;
    services.polkit-gnome.enable = true;
  };
}
