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

    # Maybe it conflicts with auto-cpufreq? It has tmany options:
    /*
    Options:
          --autopilot
              Automatically decide the scheduler's power mode (performance vs. powersave vs. balanced), CPU preference order, etc, based on system load. The options affecting the power mode and the use of
              core compaction (--autopower, --performance, --powersave, --balanced, --no-core-compaction) cannot be used with this option. When no option is specified, this is a default mode

          --autopower
              Automatically decide the scheduler's power mode (performance vs. powersave vs. balanced) based on the system's active power profile. The scheduler's power mode decides the CPU preference order
              and the use of core compaction, so the options affecting these (--autopilot, --performance, --powersave, --balanced, --no-core-compaction) cannot be used with this option

          --performance
              Run the scheduler in performance mode to get maximum performance. This option cannot be used with other conflicting options (--autopilot, --autopower, --balanced, --powersave,
              --no-core-compaction) affecting the use of core compaction

          --powersave
              Run the scheduler in powersave mode to minimize powr consumption. This option cannot be used with other conflicting options (--autopilot, --autopower, --performance, --balanced,
              --no-core-compaction) affecting the use of core compaction

          --balanced
              Run the scheduler in balanced mode aiming for sweetspot between power and performance. This option cannot be used with other conflicting options (--autopilot, --autopower, --performance,
              --powersave, --no-core-compaction) affecting the use of core compaction
    */
    extraArgs = ["--autopilot"];
  };

  # Essential system packages
  # Are these great? Maybe I should change them? Remove some? Add some?
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

    # Xdg (I need it? I was thinking on nixpak)
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

    # System-wide config (I need to keep it here? I am the only user on the machine)
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

  # I accidentally repeated it.
  # Fonts
  fonts = {
    packages = with pkgs; [
      # Nerd Fonts
      nerd-fonts.caskaydia-mono
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.caskaydia-cove
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only

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

    # Font config. Good for my screen and gpu?
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

    # Time sync (I dont even know what it does)
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

  # I had this on CachyOS. Dont know if I need?
  chaotic.appmenu-gtk3-module.enable = true;

  # Network
  networking.networkmanager.enable = true;

  # DNS
  networking.nameservers = ["2606:4700:4700::1111" "1.1.1.1"];

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

  # Environment variables (limit to system-safe ones; user XDG vars handled by Home Manager)
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "firedragon";
    PAGER = "less";
  };

  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];

  # XDG is managed by Home Manager; keep only the required link paths in NixOS (set below)

  # AppArmor (I dont know if it is effective on NixOS, but I want atleast some safety)
  security.apparmor = {
    enable = true;
    enableCache = true;
    killUnconfinedConfinables = true;
  };

  # SOPS configured in modules/core/secrets.nix

  # Btrfs
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = ["/"];
  };

  # Ollama
  services.ollama.enable = true;

  # Session variables (Do i need to set all these?)
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
