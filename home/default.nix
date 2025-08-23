{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./modules/shell.nix
    ./modules/terminal.nix
    ./modules/development.nix
    ./modules/desktop.nix
    ./modules/apps.nix
    ./modules/gaming.nix
    ./modules/theming.nix
    ./modules/niri.nix
    ./modules/waybar.nix
    ./modules/flatpak.nix
  ];

  home = {
    username = lib.mkForce "gabz";
    homeDirectory = lib.mkForce "/home/gabz";
    stateVersion = "25.05";

    # Session variables
    # Do I NEED to set all of them?
    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "firedragon";
      # TERMINAL moved to home/modules/terminal.nix

      # Wayland
      CLUTTER_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";

      QT_QPA_PLATFORM = "wayland;xcb";

      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

      GDK_BACKEND = "wayland,x11,*";

      MOZ_ENABLE_WAYLAND = 1;
      GDK_SCALE = 1;
      ELECTRON_OZONE_PLATFORM_HINT = "auto";

      # Paths
      NIXOS_CONFIG = "$HOME/NixConf";
    };

    # Are these packages appropriate? Maybe remove some? Add others?
    packages = with pkgs; [
      # --- System tools ---
      fastfetch
      xdg-utils
      # niri-unstable moved/configured via modules; not needed here
      file
      which
      tree
      gnupg

      # --- Archives ---
      zip
      unzip
      xz
      p7zip
      zstd

      # --- Networking ---
      wget
      curl
      aria2
      dnsutils
      mtr

      # --- Utils ---
      ripgrep
      fd
      bat
      eza
      fzf
      jq
      yq-go
      glow # Markdown previewer in terminal
      tealdeer # Simplified man pages
      obsidian

      # --- Monitoring ---
      btop
      iotop
      iftop
      sysstat
      lm_sensors # for `sensors` command
      ethtool
      pciutils # lspci
      usbutils # lsusb
      # nvtop moved to home/modules/gaming.nix

      # --- Media ---
      mpv
      imv
      eog
      vlc

      # --- Special case for faster refactoring ---
      (windsurf.fhsWithPackages
        (ps:
          with ps; [
            cargo
            uv
            nodejs
            python3
          ]))
      codeium

      # --- Creative / Job ---
      ffmpeg-full
      openusd
      openexr
      gmic
      imagemagick

      blender

      krita
      krita-plugin-gmic

      gimp3-with-plugins

      openai-whisper
      srt
      sox
      soxr

      # --- Gaming ---
      # moved to home/modules/gaming.nix
    ];
  };

  # programs.floorp moved to home/modules/apps.nix
  # nix.settings moved to home/modules/development.nix
  # XDG and portals moved to home/modules/desktop.nix

  # Syncthing
  services.syncthing = {
    settings = {
      devices."celular" = {
        id = "EIDJBPY-QXNRYHF-HC6Q4ER-O5FVG5A-2BZNK4F-Q6DDQC6-744RYJU-4DHZTQR";
        name = "celular";
        autoAcceptFolders = true;
      };
      folders."sync" = {
        enable = true;
        devices = ["celular"];
        id = "default";
        path = "~/Sync";
      };
    };

    enable = true;
    tray.enable = false;
  };

  programs = {
    # Let home-manager manage itself
    home-manager.enable = true;
  };

  # Comp
  programs.man.generateCaches = true;

  # SOPS moved to system (NixOS) single-source; HM reads nixosConfig.sops.secrets.*

  # fuzzel/swaylock and desktop services moved to modules

  # TLDR
  services.tldr-update.enable = true;

  # App configs moved to home/modules/apps.nix and gaming.nix

  # NixGL (Really needed when on NixOS?)
  nixGL.vulkan.enable = true;
  nixGL.prime.installScript = "mesa";
  nixGL.defaultWrapper = "mesa";

  # Terminal
  # Kitty moved to home/modules/terminal.nix
}
