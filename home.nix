{
  config,
  pkgs,
  pkgs-stable,
  nixosConfigurations,
  system,
  lib,
  ...
}: {
  home.username = "gabz";
  home.homeDirectory = "/home/gabz";

  imports = [./niri.nix];

  # Catppuccin Mocha
  # catppuccin.enable = true;
  # catppuccin.flavor = "mocha";
  # catppuccin.accent = "pink";
  # catppuccin.cache.enable = true;

  # Stylix
  stylix.enable = true;
  stylix.autoEnable = true;
  stylix.icons.enable = true;
  stylix.icons.package = pkgs.papirus-icon-theme;
  stylix.icons.dark = "Papirus-Dark";
  stylix.icons.light = "Papirus-Light";
  stylix.targets.vscode.enable = false;

  services.swww.enable = true;

  qt.enable = true;
  gtk.enable = true;
  gtk.gtk4.enable = true;
  gtk.gtk3.enable = true;
  gtk.gtk2.enable = true;

  # Comp
  programs.man.generateCaches = true;
  programs.bash.enableCompletion = true;

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    nix-direnv.package = pkgs.nix-direnv-flakes;
  };

  # Sops
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    secrets = {
      "git" = {
      };
    };
  };

  # sops.secrets."git".neededForUsers = true;

  # set cursor size and dpi for 1920x1080 monitor
  xresources.properties = {
    "Xcursor.size" = 24;
    "Xft.dpi" = 141.21;
  };

  # Easyeffects
  services.easyeffects.enable = true;

  # Niri
  programs.niriswitcher.enable = true;

  programs.alacritty.enable = true; # Super+T in the default setting (terminal)
  programs.fuzzel.enable = true; # Super+D in the default setting (app launcher)
  programs.swaylock.enable = true; # Super+Alt+L in the default setting (screen locker)
  programs.waybar.enable = true; # launch on startup in the default setting (bar)
  programs.waybar.systemd.enable = true;
  # services.mako.enable = true; # notification daemon
  services.swayidle.enable = true; # idle management daemon
  services.polkit-gnome.enable = true; # polkit

  # XDG
  xdg.enable = true;

  xdg.autostart.enable = true;
  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;

  xdg.terminal-exec.enable = true;

  xdg.portal.xdgOpenUsePortal = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
  ];
  xdg.portal.configPackages = with pkgs; [
    niri-unstable
  ];

  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;

  # VsCodium
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium-fhs;
    mutableExtensionsDir = true;
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
    tray.enable = true;
  };

  programs.distrobox = {
    enable = true;
    enableSystemdUnit = true;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    fastfetch
    pokeget-rs
    swaybg
    

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

    # networking tools
    mtr # A network diagnostic tool
    dnsutils # `dig` + `nslookup`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility

    # misc
    coreutils-full
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # job
    davinci-resolve
    ffmpeg
    kdePackages.kdenlive
    blender
    obs-studio
    krita
    krita-plugin-gmic
    gimp3-with-plugins

    # pessoal
    obsidian

    # nix related
    nix-output-monitor
    nvd

    # productivity
    bat
    glow # markdown previewer in terminal

    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
  ];

  # Neovim
  programs.nvchad = {
    enable = true;
    extraPackages = with pkgs; [
      bash-language-server
      fish-lsp
      hyprls
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

  home.shell.enableZshIntegration = true;
  home.shell.enableFishIntegration = true;

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  # Shell
  programs.bash.enable = true;
  programs.zsh.enable = true;

  programs.fish.enable = true;
  programs.fish.generateCompletions = true;

  programs.nix-your-shell.enable = true;
  programs.nix-your-shell.enableFishIntegration = true;
  programs.nix-your-shell.enableZshIntegration = true;

  programs.zsh.autosuggestion.enable = true;
  programs.zsh.autosuggestion.strategy = ["completion" "history"];
  programs.zsh.enableCompletion = true;
  programs.zsh.historySubstringSearch.enable = true;
  programs.zsh.oh-my-zsh.enable = true;
  programs.zsh.oh-my-zsh.plugins = ["common-aliases" "sudo" "alias-finder" "colored-man-pages" "colorize" "copybuffer" "copyfile" "copypath" "eza" "git" "gh"];
  programs.zsh.syntaxHighlighting.enable = true;

  programs.zoxide.enable = true;
  programs.zoxide.enableZshIntegration = true;
  programs.zoxide.enableFishIntegration = true;

  programs.nix-index.enable = true;
  programs.nix-index.enableBashIntegration = true;
  programs.nix-index.enableZshIntegration = true;
  programs.nix-index.enableFishIntegration = true;

  programs.command-not-found.enable = false;

  programs.eza.enable = true;
  programs.eza.enableZshIntegration = true;
  programs.eza.enableFishIntegration = true;

  programs.gh.enable = true;
  programs.gh.gitCredentialHelper.enable = true;

  # Terminal
  programs.kitty.enable = true;
  programs.kitty.enableGitIntegration = true;
  programs.kitty.shellIntegration.enableZshIntegration = true;
  programs.kitty.shellIntegration.enableBashIntegration = true;
  programs.kitty.shellIntegration.enableFishIntegration = true;

  home.stateVersion = "25.05";
}
