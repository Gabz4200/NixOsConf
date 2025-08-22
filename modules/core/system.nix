{
  config,
  lib,
  pkgs,
  ...
}: {
  # System version
  system.stateVersion = "25.05";

  # Hostname
  networking.hostName = "nixos";

  # Timezone and locale
  time.timeZone = "America/Bahia";

  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };
  };

  # Console
  console = {
    keyMap = "br-abnt2";
    font = "Lat2-Terminus16";
    earlySetup = true;
  };

  # Scx
  services.scx = {
    enable = true;
    package = pkgs.scx_git.full;
    scheduler = "scx_lavd";
    extraArgs = ["--autopilot"];
  };

  # Essential system packages
  environment.systemPackages = with pkgs; [
    # Core utils
    coreutils-full
    util-linux
    procps
    psmisc

    # System monitoring
    htop
    btop
    iotop
    iftop

    # Hardware info
    pciutils
    usbutils
    lshw
    dmidecode

    # Network tools
    iproute2
    iputils
    dnsutils
    nettools

    # File management
    file
    tree
    ncdu
    du-dust

    # Text processing
    gnused
    gawk
    gnugrep

    # Archives
    gnutar
    gzip
    bzip2
    xz
    zip
    unzip
    p7zip

    # Essentials
    wget
    curl
    rsync
    openssh

    # Xdg
    xdg-dbus-proxy
    wayland-proxy-virtwl
    niri-unstable

    # Help
    man-pages
    tldr
  ];

  # Shell
  programs.zsh = {
    enable = true;

    # System-wide config
    interactiveShellInit = ''
      # Better history
      setopt EXTENDED_HISTORY
      setopt HIST_EXPIRE_DUPS_FIRST
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_VERIFY
      setopt SHARE_HISTORY

      # Better completion
      setopt COMPLETE_IN_WORD
      setopt ALWAYS_TO_END
      setopt AUTO_MENU
      setopt COMPLETE_ALIASES

      # Better navigation
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_MINUS
    '';
  };

  # Set as default shell
  users.defaultUserShell = pkgs.zsh;

  # Fonts
  fonts = {
    packages = with pkgs; [
      # Nerd Fonts
      nerd-fonts.caskaydia-mono
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.caskaydia-cove
      nerd-fonts.jetbrains-mono

      # System fonts
      liberation_ttf
      dejavu_fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji

      # Icons
      font-awesome
      material-design-icons
    ];

    # Font config
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["DejaVu Serif" "Noto Serif"];
        sansSerif = ["DejaVu Sans" "Noto Sans"];
        monospace = ["CaskaydiaCove Nerd Font" "DejaVu Sans Mono"];
        emoji = ["Noto Color Emoji"];
      };

      # Hinting
      hinting = {
        enable = true;
        style = "slight";
      };

      # Subpixel rendering
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
    };
  };

  # Services
  services = {
    # Firmware updates
    fwupd.enable = true;

    # SSD optimization
    fstrim = {
      enable = true;
      interval = "weekly";
    };

    # System monitoring
    smartd = {
      enable = true;
      autodetect = true;
    };

    # Printing
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        hplip
      ];
    };

    # Time sync
    timesyncd = {
      enable = true;
      servers = [
        "0.br.pool.ntp.org"
        "1.br.pool.ntp.org"
        "2.br.pool.ntp.org"
        "3.br.pool.ntp.org"
      ];
    };
  };

  # Dbus
  services.dbus = {
    implementation = "broker";
    apparmor = "enabled";
    enable = true;
  };

  chaotic.appmenu-gtk3-module.enable = true;

  # DNS
  networking.nameservers = ["2606:4700:4700::1111" "1.1.1.1"];

  networking.networkmanager.enable = true;

  services.resolved = {
    enable = true;
    dnsovertls = "true";
    dnssec = "true";
    fallbackDns = [
      "2606:4700:4700::1001"
      "1.0.0.1"
      "2001:4860:4860::8888"
      "8.8.8.8"
      "2001:4860:4860::8844"
      "8.8.4.4"
    ];
  };

  # Environment variables
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "firedragon";
    PAGER = "less";

    # XDG Base Directories
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];

  # XDG
  xdg.mime.enable = true;

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

  xdg.terminal-exec.enable = true;

  xdg.icons.enable = true;
  xdg.menus.enable = true;
  xdg.sounds.enable = true;

  xdg.autostart.enable = true;

  # AppArmor
  security.apparmor = {
    enable = true;
    enableCache = true;
    killUnconfinedConfinables = true;
  };

  # Sops
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/home/gabz/.config/sops/age/keys.txt";
  };

  # Btrfs
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = ["/"];
  };

  # Ollama
  services.ollama.enable = true;

  # Session variables
  environment.sessionVariables = {
    # Wayland
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";

    # Qt
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # Java
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };
}
