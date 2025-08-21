{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
  ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

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
      Context.sockets = ["wayland" "!x11" "fallback-x11"];

      Environment = {
        XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";

        GTK_THEME = "Adwaita:dark";
      };
    };
  };

  home.sessionVariables = {
    XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
  };

  xdg.enable = true;

  home.packages = with pkgs; [
    xdg-dbus-proxy
    wayland-proxy-virtwl
    wayland-protocols

    flatpak
    gnome-software
  ];
}
