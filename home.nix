{
  config,
  pkgs,
  lib,
  ...
}: {
  home.username = "gabz";
  home.homeDirectory = "/home/gabz";

  # Stylix
  stylix.enable = true;
  stylix.autoEnable = true;
  stylix.icons.enable = true;
  stylix.icons.package = pkgs.papirus-icon-theme;
  stylix.icons.dark = "Papirus-Dark";
  stylix.icons.light = "Papirus-Light";

  # Sops
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];

    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    age.generateKey = true;

    secrets = {
      "git" = {
      };
    };
  };

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi for 1920x1080 monitor
  xresources.properties = {
    "Xcursor.size" = 24;
    "Xft.dpi" = 141.21;
  };

  # Easyeffects
  services.easyeffects.enable = true;

  services.syncthing.enable = true;
  services.syncthing.tray.enable = true;

  # Hyprland
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.xwayland.enable = true;

  # Niri
  # --> programs.niriswitcher.enable = true;

  # XDG
  xdg.autostart.enable = true;
  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;
  xdg.portal.xdgOpenUsePortal = true;
  xdg.portal.enable = true;
  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;

  # VsCodium
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium-fhs;
    mutableExtensionsDir = true;
  };

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = lib.mkForce true;
    enableZshIntegration = lib.mkForce true;
    enableFishIntegration = lib.mkForce true;
  };

  # Syncthing

  services.syncthing.settings.devices."celular" = {
    id = "EIDJBPY-QXNRYHF-HC6Q4ER-O5FVG5A-2BZNK4F-Q6DDQC6-744RYJU-4DHZTQR";
    name = "celular";
    autoAcceptFolders = true;
  };
  services.syncthing.settings.folders."sync" = {
    enable = true;
    devices = ["celular"];
    id = "default";
    path = "~/Sync";
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    fastfetch

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

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
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

  programs.nix-index.enable = true;
  programs.nix-index.enableBashIntegration = lib.mkForce true;
  programs.nix-index.enableZshIntegration = lib.mkForce true;
  programs.nix-index.enableFishIntegration = lib.mkForce true;

  programs.command-not-found.enable = false;

  #TODO: Set default shell for user

  # Terminal
  programs.kitty.enable = true;
  programs.kitty.enableGitIntegration = lib.mkForce true;
  programs.kitty.shellIntegration.enableZshIntegration = lib.mkForce true;
  programs.kitty.shellIntegration.enableBashIntegration = lib.mkForce true;
  programs.kitty.shellIntegration.enableFishIntegration = lib.mkForce true;

  home.stateVersion = "25.05";
}
