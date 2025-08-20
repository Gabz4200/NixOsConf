{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./modules/shell.nix
    # Fix: TODO: ./modules/terminal.nix
    # Fix: TODO: ./modules/development.nix
    # Fix: TODO: ./modules/desktop.nix
    # Fix: TODO: ./modules/apps.nix
    # Fix: TODO: ./modules/gaming.nix
    ./modules/theming.nix
    ./modules/niri.nix
    ./modules/waybar.nix
  ];

  home = {
    username = lib.mkForce "gabz";
    homeDirectory = lib.mkForce "/home/gabz";
    stateVersion = "25.05";

    # Session variables
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

      #QT_QPA_PLATFORMTHEME = "qt6ct";

      GDK_BACKEND = "wayland,x11,*";

      MOZ_ENABLE_WAYLAND = 1;
      GDK_SCALE = 1;
      ELECTRON_OZONE_PLATFORM_HINT = "auto";

      # Paths
      NIXOS_CONFIG = "$HOME/NixConf";
    };

    packages = with pkgs; [
      # --- System tools ---
      fastfetch
      wl-clipboard
      xdg-utils
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
      tldr # Simplified man pages

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
      python3
      uv
      pipx
      virtualenv
      ruff

      windsurf
      codeium

      # --- Creative / Job ---
      ffmpeg-full
      openusd
      openexr
      blender
      krita
      (let
        kdenlive = kdePackages.kdenlive;
        kdenlivePython = pkgs.python3.withPackages (ps:
          with ps; [
            pip
            openai-whisper
            srt
            opencv4
            torch
          ]);
      in
        pkgs.symlinkJoin {
          name = "kdenlive-with-whisper-${kdenlive.version}";
          # mantém o kdenlive original intacto (benefício do cache)
          paths = [kdenlive kdenlivePython];

          # preciso do makeWrapper para criar o wrapper no postBuild
          nativeBuildInputs = [pkgs.makeWrapper];

          postBuild = ''
            # cria um wrapper simples para que, ao executar kdenlive,
            # o PATH e o PYTHONPATH apontem para o python com os pacotes
            wrapProgram $out/bin/kdenlive \
              --prefix PATH : ${kdenlivePython}/bin \
              --set PYTHONPATH ${kdenlivePython}/${kdenlivePython.sitePackages}
          '';
        })
      (pkgs.symlinkJoin {
        name = "davinci-resolve-fixed-${davinci.version}";
        paths = [
          davinci
          pkgs.bwrap
          pkgs.intel-compute-runtime
          pkgs.libGL
        ];
        nativeBuildInputs = [pkgs.makeWrapper];

        postBuild = ''
                mkdir -p $out/bin

                # caminho para o binário original (conforme o pacote no nixpkgs)
                ORIGINAL_BIN=${davinci}/bin/resolve

                cat > $out/bin/davinci-resolve <<'EOF'
          #!/bin/sh
          # launcher leve que rodará o resolve dentro de bwrap com binds necessários
          exec ${pkgs.bwrap}/bin/bwrap \
            --ro-bind /run/opengl-driver /run/opengl-driver \
            --ro-bind ${pkgs.intel-compute-runtime}/lib /run/opengl-driver/lib \
            --setenv LD_LIBRARY_PATH ${davinci}/libs:$LD_LIBRARY_PATH \
            --setenv QT_PLUGIN_PATH ${davinci}/libs/plugins:$QT_PLUGIN_PATH \
            --setenv XDG_DATA_DIRS ${davinci}/share:$XDG_DATA_DIRS \
            "${ORIGINAL_BIN}" "$@"
          EOF

                chmod +x $out/bin/davinci-resolve

                # opcional: expõe o desktop file e ícone (link simbólico)
                mkdir -p $out/share/applications $out/share/icons/hicolor/128x128/apps
                ln -s ${davinci}/share/applications/*.desktop $out/share/applications/ || true
                if [ -f ${davinci}/graphics/DV_Resolve.png ]; then
                  ln -s ${davinci}/graphics/DV_Resolve.png $out/share/icons/hicolor/128x128/apps/davinci-resolve.png || true
                fi
        '';
      })
      krita-plugin-gmic
      gmic
      imagemagick
      gimp3-with-plugins

      obsidian

      openai-whisper
      srt
      sox
      soxr

      # --- Gaming ---
      (prismlauncher.override {jdks = [zulu8 zulu17];})
      bottles
    ];
  };

  # Install firefox.
  programs.floorp = {
    enable = true;
    package = pkgs.firedragon;
  };

  # Nix
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://niri.cachix.org"
      "https://chaotic-nyx.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # XDG
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

    mimeApps = {
      enable = true;

      defaultApplications = {
        # Browser
        "text/html" = ["firedragon.desktop"];
        "x-scheme-handler/http" = ["firedragon.desktop"];
        "x-scheme-handler/https" = ["firedragon.desktop"];

        # Terminal
        "x-scheme-handler/terminal" = ["kitty.desktop"];

        # Files
        "inode/directory" = ["nautilus.desktop"];

        # Images
        "image/png" = ["imv.desktop"];
        "image/jpeg" = ["imv.desktop"];
        "image/gif" = ["imv.desktop"];

        # Video
        "video/mp4" = ["mpv.desktop"];
        "video/x-matroska" = ["mpv.desktop"];

        # Text
        "text/plain" = ["nvim.desktop"];

        # PDF
        "application/pdf" = ["org.kde.okular.desktop"];
      };
    };

    configFile = {
      # git
      "git/config".enable = false;

      # Important
      "niri/.keep".text = "";
      "waybar/.keep".text = "";
    };
  };

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

  programs.zed-editor.enable = true;

  # Container

  programs.distrobox = {
    enable = true;
    enableSystemdUnit = true;
  };

  programs.lutris.enable = true;

  # OBS
  programs.obs-studio.enable = true;

  # Neovim
  programs.nvchad = {
    enable = true;
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
