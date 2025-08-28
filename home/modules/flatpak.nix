{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
  ];

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
      Context.sockets = ["wayland" "!x11" "fallback-x11"];

      Environment = {
        XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";

        # GTK_THEME = "Adwaita:dark";  # Commented: let Stylix/Catppuccin drive GTK theme
      };
    };
    # "org.kde.kdenlive".Context = {
    #   filesystems = [
    #     # Previously used to expose Python toolchain to Kdenlive Flatpak. Commented to avoid brittle path mappings.
    #     # If you still need Whisper/SRT inside Kdenlive, we can package them in a Flatpak extension or use a Nix-based workflow.
    #     "${pkgs.python3.withPackages (ps: with ps; [pip openai-whisper virtualenv srt opencv4 torch])}/bin:/app/python:rw"
    #   ];
    # };
  };

  home.sessionVariables = {
    XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
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
}
