{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./modules/shell.nix
    #TODO: ./modules/terminal.nix
    #TODO: ./modules/development.nix
    #TODO: ./modules/desktop.nix
    #TODO: ./modules/apps.nix
    #TODO: ./modules/gaming.nix
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
      TERMINAL = "kitty";

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
      wl-clipboard
      xdg-utils
      niri-unstable
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
      nvtopPackages.intel

      # --- Media ---
      mpv
      imv
      eog
      vlc

      # --- Development ---
      shfmt
      shellcheck
      bash-language-server

      # --- Special case for faster refactoring ---
      windsurf.fhs
      codeium
      uv
      nodejs

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
      bottles
    ];
  };

  # Install firefox fork of choice. I wanted Zen, but it isnt packaged on nixpkgs yet.
  programs.floorp = {
    enable = true;
    package = pkgs.firedragon;
  };

  # Nix
  nix.settings = {
    # Substituters. Maybe let it be flake only.
    substituters = [
      "https://niri.cachix.org"
      "https://chaotic-nyx.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # XDG. Should I use home-manager or nixos for it?
  # Some options are home-manager only (namely userDirs)
  # How to be sure home-manager will inherit NixOS xdg decisions?
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

  # Sops
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/home/gabz/.config/sops/age/keys.txt";

    secrets = {
      "git" = {
      };
    };
  };

  # Easyeffects
  services.easyeffects.enable = true;

  programs.fuzzel.enable = true;
  programs.swaylock.enable = true;

  services.swaync.enable = true;
  services.swayosd = {
    display = "eDP-1";
    enable = true;
  };

  services.swayidle.enable = true;
  services.polkit-gnome.enable = true;

  # TLDR
  services.tldr-update.enable = true;

  # VsCodium
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium.fhs;
    mutableExtensionsDir = true;
  };

  # Zed
  programs.zed-editor.enable = true;

  # Container distro
  programs.distrobox = {
    enable = true;
    enableSystemdUnit = true;
  };

  # Gaming
  programs.lutris.enable = true;

  # OBS
  programs.obs-studio.enable = true;
  programs.obs-studio.package = pkgs.obs-studio;

  # Neovim
  programs.nvchad = {
    enable = true;
    # Necessary?
    extraPackages = with pkgs; [
      bash-language-server
      kdlfmt
      alejandra
      nixd
      (python3.withPackages (ps:
        with ps; [
          python-lsp-server
          flake8
        ]))
    ];
    hm-activation = true;
    backup = false;
  };

  # Git
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    extraConfig = {
      include = {
        path = config.sops.secrets."git".path;
      };
    };
  };

  # NixGL (Really needed when on NixOS?)
  nixGL.vulkan.enable = true;
  nixGL.prime.installScript = "mesa";
  nixGL.defaultWrapper = "mesa";

  # Terminal
  programs.kitty = lib.mkForce {
    enable = true;
    enableGitIntegration = true;
    shellIntegration.enableZshIntegration = true;
    settings = {
      confirm_os_window_close = 0;
      dynamic_background_opacity = true;
      enable_audio_bell = false;
      mouse_hide_wait = "-1.0";
      window_padding_width = 12;
      background_opacity = "1.0";
      background_blur = 5;
      symbol_map = let
        mappings = [
          "U+23FB-U+23FE"
          "U+2B58"
          "U+E200-U+E2A9"
          "U+E0A0-U+E0A3"
          "U+E0B0-U+E0BF"
          "U+E0C0-U+E0C8"
          "U+E0CC-U+E0CF"
          "U+E0D0-U+E0D2"
          "U+E0D4"
          "U+E700-U+E7C5"
          "U+F000-U+F2E0"
          "U+2665"
          "U+26A1"
          "U+F400-U+F4A8"
          "U+F67C"
          "U+E000-U+E00A"
          "U+F300-U+F313"
          "U+E5FA-U+E62B"
        ];
      in
        (builtins.concatStringsSep "," mappings) + " Symbols Nerd Font";
    };
  };
}
