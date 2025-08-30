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

  # Essential system packages
  # Are these great? Maybe I should change them? Remove some? Add some? -> This is a solid list.
  # I've removed a few that are not strictly necessary or better handled by Home Manager.
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

    # Xdg (I need it? I was thinking on nixpak) -> These are still useful for portal integration.
    # xdg-dbus-proxy # Not needed if using portals correctly
    # wayland-proxy-virtwl # Specific to virt-manager, can be installed with it.
    niri-unstable
    uwsm
    app2unit

    # Help
    man-pages
    tldr

    # GPU validation tools
    libva-utils # vainfo
    mesa-demos # glxinfo/glxgears
    clinfo # OpenCL info
    vulkan-tools # vulkaninfo

    # Benchmarks and power tools (used by Justfile targets)
    sysbench
    stress-ng
    glmark2
    fio
    iperf3
    powertop
    s-tui
    lm_sensors
  ];

  # Set as default shell
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

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

    # Time sync (I dont even know what it does) -> It synchronizes my system's clock with
    # internet time servers, which is crucial for many things like TLS certificates and logging.
    timesyncd = {
      enable = true;
    };
  };

  # Dbus
  services.dbus = {
    implementation = "broker";
    apparmor = "enabled";
    enable = true;
  };

  # I had this on CachyOS. Dont know if I need? -> This is for global menu support in GTK3 apps.
  # Niri doesn't use a global menu, so this is not needed.
  # chaotic.appmenu-gtk3-module.enable = true;

  # Networking and DNS are centralized in modules/core/networking.nix

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
  # Moved to Security

  # SOPS configured in modules/core/secrets.nix

  # Btrfs
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = ["/"];
  };

  # Ollama
  services.ollama.enable = true;

  # Session variables (Do i need to set all these?) -> Yes, these are important for ensuring
  # applications (especially those using Qt, Java, or running in XWayland) render correctly on Wayland.
  environment.sessionVariables = {
    # Wayland
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";

    #todo: make it have a if statement with UWSM being enabled
    # UWSM
    APP2UNIT_SLICES = "a=app-graphical.slice b=background-graphical.slice s=session-graphical.slice";
    APP2UNIT_TYPE = "scope";

    # Qt
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # Java
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };
}
