{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.home.flatpak;
in {
  imports = [
  ];

  options.home.flatpak = {
    enable = lib.mkEnableOption "Enable Flatpak configuration and Flatpak-related settings";
    unstable = lib.mkEnableOption "Enable unstable Flatpak features and experimental configurations";
  };

  #todo: Adress it.
  # Nice, but easyness of use and less space consume would be appreciated.

  config = lib.mkIf cfg.enable {
    # Great, because some packages are not on nixpkgs or are broke there.
    services.flatpak.enable = true;
    services.flatpak.update.onActivation = false;

    services.flatpak.restartOnFailure = {
      enable = true;
      restartDelay = "60s";
      exponentialBackoff = {
        enable = false;
        steps = 10;
        maxDelay = "1h";
      };
    };

    services.flatpak.remotes = lib.mkOptionDefault [
      {
        name = "flathub-beta";
        location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
      }
    ];

    services.flatpak.packages = [
      "com.github.tchx84.Flatseal"
      "org.vinegarhq.Sober"
      "io.github.OpenToonz"
      "org.kde.kdenlive"
      "org.freedesktop.LinuxAudio.Plugins.Calf"
      "org.freedesktop.LinuxAudio.Plugins.LSP"
      "org.freedesktop.LinuxAudio.Plugins.InfamousPlugins"
      "org.freedesktop.LinuxAudio.Plugins.noise-repellent"
      "org.freedesktop.LinuxAudio.Plugins.master_me"
    ];

    services.flatpak.overrides = {
      global = {
        Context = {
          sockets = ["wayland" "!x11" "fallback-x11"];
          filesystems = ["${config.home.homeDirectory}/.themes/adw-gtk3:ro"];
        };

        Environment = {
          XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
          GTK_THEME = "adw-gtk3";
        };
      };
    };

    home.sessionVariables = {
      XDG_DATA_DIRS = lib.mkAfter "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
    };

    xdg.enable = true;
    # Is this okay?
    home.packages = with pkgs; [
      xdg-dbus-proxy
      wayland-proxy-virtwl
      wayland-protocols

      flatpak
      gnome-software
    ];
  };
}
