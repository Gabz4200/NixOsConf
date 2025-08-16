# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  self,
  pkgs-stable,
  lib,
  system,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  home-manager.extraSpecialArgs = {
    inherit inputs self;
    nixosConfigurations = config;
    system = "x86_64-linux";
    pkgs-stable = import inputs.nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };
  };

  # Dbus
  services.dbus = {
    implementation = "broker";
    apparmor = "enabled";
    enable = true;
  };

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

  # UWSM
  programs.uwsm.enable = true;
  programs.uwsm.waylandCompositors = {
    niri = {
      prettyName = "Niri";
      comment = "Niri compositor managed by UWSM";
      binPath = "/run/current-system/sw/bin/niri-session";
    };
  };

  # Niri
  nixpkgs.overlays = [inputs.niri.overlays.niri];
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  # XDG
  xdg.icons.enable = true;
  xdg.menus.enable = true;
  xdg.sounds.enable = true;

  # Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1";

  # Dconf
  programs.dconf.enable = true;

  # Apparmor
  security.apparmor = {
    enable = true;
    enableCache = true;
    killUnconfinedConfinables = true;
  };

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = {};

  # Steam
  programs.steam.enable = true;
  programs.steam.extraCompatPackages = with pkgs; [
    proton-ge-custom
    proton-cachyos_x86_64_v3
  ];
  programs.steam.extraPackages = with pkgs; [
    gamescope
    gamemode
    #khronos-ocl-icd-loader
    ocl-icd
    intel-compute-runtime
    mesa.opencl
    intel-media-driver
    intel-ocl
    vaapiIntel
    vulkan-loader
    vpl-gpu-rt
  ];
  programs.steam.extest.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.steam.localNetworkGameTransfers.openFirewall = true;
  programs.steam.protontricks.enable = true;

  # Stylix
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  stylix.image = ./wallpaper.jpg;
  stylix.polarity = "dark";
  #TODO: Use my beloved Nerd Fonts like Fira and Caskadya
  stylix.fonts = {
    serif = {
      package = pkgs.nerd-fonts.caskaydia-cove;
      name = "CaskaydiaCove Nerd Font";
    };

    sansSerif = {
      package = pkgs.nerd-fonts.dejavu-sans-mono;
      name = "DejaVuSansMono Nerd Font";
    };

    monospace = {
      package = pkgs.nerd-fonts.caskaydia-mono;
      name = "CaskaydiaMono Nerd Font";
    };

    emoji = {
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };
  };
  stylix.autoEnable = false;
  stylix.cursor.package = pkgs.bibata-cursors;
  stylix.cursor.name = "Bibata-Modern-Ice";
  stylix.cursor.size = 24;
  stylix.homeManagerIntegration.autoImport = true;
  stylix.homeManagerIntegration.followSystem = true;

  # Sops
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/home/${config.users.users.gabz.name}/.config/sops/age/keys.txt";
  };

  # Hardware and Firmware
  hardware = {
    enableAllFirmware = true;
    enableAllHardware = true;
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  services.fwupd.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-mono
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.jetbrains-mono
    font-awesome
    dejavu_fonts
    nerd-fonts.symbols-only
  ];

  # Zram
  zramSwap = {
    enable = true;
    priority = 200;
    memoryPercent = 100;
    algorithm = "zstd";
  };

  # Preload
  services.preload.enable = true;

  # Nyx
  chaotic.nyx = {
    cache.enable = true;
    nixPath.enable = true;
    overlay.enable = true;
  };

  # Graphics setup for KabyLake GPU
  boot.kernelParams = [
    "i915.enable_guc=2"
    "i915.enable_fbc=1"
    "i915.enable_psr=2"
    "pcie_aspm=off"
  ];

  hardware.intel-gpu-tools.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    package = pkgs.mesa;
    package32 = pkgs.driversi686Linux.mesa;

    extraPackages = with pkgs; [
      #khronos-ocl-icd-loader
      ocl-icd
      intel-compute-runtime
      mesa.opencl
      intel-media-driver
      intel-ocl
      vaapiIntel
      vulkan-loader
      vpl-gpu-rt
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      mesa.opencl
      #khronos-ocl-icd-loader
      ocl-icd
      intel-media-driver
      intel-vaapi-driver
      vaapiIntel
      vulkan-loader
    ];
  };

  # hardware.opengl.enable = true;

  # chaotic.mesa-git = {
  #   enable = false;
  #   # extraPackages = with pkgs; [
  #   #   mesa_git.opencl
  #   #   intel-media-driver
  #   #   intel-ocl
  #   #   vaapiIntel
  #   #   vpl-gpu-rt
  #   # ];
  #   # extraPackages32 = with pkgs.pkgsi686Linux; [
  #   #   pkgs.mesa32_git.opencl
  #   #   intel-media-driver
  #   #   vaapiIntel
  #   # ];
  # };

  # Scx
  services.scx = {
    enable = true;
    package = pkgs.scx_git.full;
    scheduler = "scx_lavd";
    extraArgs = ["--autopilot"];
  };

  # Auto Cpu Freq
  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        energy_performance_preference = "balance_performance";
        energy_perf_bias = "balance_performance";
        scaling_min_freq = 800000;
        scaling_max_freq = 3200000;
        turbo = "auto";
      };
      battery = {
        governor = "powersave";
        energy_performance_preference = "power";
        energy_perf_bias = "balance_power";
        scaling_min_freq = 800000;
        scaling_max_freq = 1600000;
        turbo = "auto";
      };
    };
  };
  services.power-profiles-daemon.enable = false;

  # Undervolt
  services.undervolt = {
    enable = true;
    uncoreOffset = -80;
    turbo = 0;
    tempBat = 85;
    tempAc = 95;
    p2.window = 1;
    p2.limit = 40;
    p1.window = 28;
    p1.limit = 30;
    gpuOffset = -40;
    coreOffset = -80;
    analogioOffset = -40;
  };

  # Hibernate
  powerManagement.enable = true;

  # Minecraft
  programs.java.enable = true;
  programs.java.package = pkgs.jdk21;
  programs.java.binfmt = true;

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Kernel
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  # Wifi driver
  # boot.kernelModules = ["8821ce"];
  # boot.extraModulePackages = with config.boot.kernelPackages; [
  #   rtl8821ce
  # ];

  # Btrfs
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = ["/"];
  };

  # Host Name
  networking.hostName = "nixos";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Bahia";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  # Enable the X11 windowing system.
  # # services.xserver.enable = true;
  programs.xwayland.enable = true;

  # SDDM
  services.displayManager.sddm = {
    wayland.enable = true;
    package = pkgs.kdePackages.sddm;
    enable = true;
    extraPackages = [
      pkgs.kdePackages.qtsvg
      pkgs.kdePackages.qtmultimedia
      pkgs.kdePackages.qtvirtualkeyboard
      (pkgs.sddm-astronaut.override {embeddedTheme = "black_hole";})
    ];
    theme = "sddm-astronaut-theme";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account.
  users.users.gabz = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Gabriel";
    extraGroups = ["networkmanager" "wheel" "podman"];
    #---> hashedPasswordFile = config.sops.secrets."initial_hashed_password".path;
  };

  # Install firefox.
  programs.firefox = {
    enable = true;
    package = pkgs.firedragon;
  };

  # NH
  programs.nh = {
    enable = true;
    flake = "/home/${config.users.users.gabz.name}/NixConf";
    clean.enable = true;
    clean.dates = "weekly";
    clean.extraArgs = "--keep 6 --keep-since 3d";
  };

  # Nix
  nixpkgs.flake = {
    setFlakeRegistry = true;
    setNixPath = true;
  };
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["@wheel" "root" "${config.users.users.gabz.name}"];
      auto-optimise-store = true;
      sandbox = true;
      substituters = ["https://niri.cachix.org" "https://chaotic-nyx.cachix.org" "https://nix-community.cachix.org" "https://hyprland.cachix.org" "https://numtide.cachix.org" "https://cache.nixos.org/"];
      trusted-public-keys = ["niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
    };

    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
    channel.enable = false;

    optimise = {
      automatic = true;
      persistent = true;
      dates = ["19:00"];
    };
  };

  programs.nix-required-mounts.enable = true;

  # Shell
  programs.zsh.enable = true;
  programs.fish.enable = true;
  #programs.bash.enable = true;

  # AppImage
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Nix-Ld
  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # List by default
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd

      # My own additions
      python313Packages.pygments
      xorg.libXcomposite
      xorg.libXtst
      xorg.libXrandr
      xorg.libXext
      xorg.libX11
      xorg.libXfixes
      libGL
      libva
      pipewire
      xorg.libxcb
      xorg.libXdamage
      xorg.libxshmfence
      xorg.libXxf86vm
      libelf
      wayland

      # More graphics
      mesa
      #khronos-ocl-icd-loader
      ocl-icd
      intel-compute-runtime
      mesa.opencl
      intel-media-driver
      intel-ocl
      vaapiIntel
      vpl-gpu-rt

      # Required
      glib
      gtk2
      pkg-config

      # Inspired by steam
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/st/steam/package.nix#L36-L85
      networkmanager
      vulkan-loader
      libgbm
      libdrm
      libxcrypt
      coreutils
      pciutils
      zenity
      # glibc_multi.bin # Seems to cause issue in ARM

      # # Without these it silently fails
      xorg.libXinerama
      xorg.libXcursor
      xorg.libXrender
      xorg.libXScrnSaver
      xorg.libXi
      xorg.libSM
      xorg.libICE
      gnome2.GConf
      nspr
      nss
      cups
      libcap
      SDL2
      libusb1
      dbus-glib
      ffmpeg
      # Only libraries are needed from those two
      libudev0-shim

      # needed to run unity
      gtk3
      icu
      libnotify
      gsettings-desktop-schemas
      # https://github.com/NixOS/nixpkgs/issues/72282
      # https://github.com/NixOS/nixpkgs/blob/2e87260fafdd3d18aa1719246fd704b35e55b0f2/pkgs/applications/misc/joplin-desktop/default.nix#L16
      # log in /home/leo/.config/unity3d/Editor.log
      # it will segfault when opening files if you don’t do:
      # export XDG_DATA_DIRS=/nix/store/0nfsywbk0qml4faa7sk3sdfmbd85b7ra-gsettings-desktop-schemas-43.0/share/gsettings-schemas/gsettings-desktop-schemas-43.0:/nix/store/rkscn1raa3x850zq7jp9q3j5ghcf6zi2-gtk+3-3.24.35/share/gsettings-schemas/gtk+3-3.24.35/:$XDG_DATA_DIRS
      # other issue: (Unity:377230): GLib-GIO-CRITICAL **: 21:09:04.706: g_dbus_proxy_call_sync_internal: assertion 'G_IS_DBUS_PROXY (proxy)' failed

      # Verified games requirements
      xorg.libXt
      xorg.libXmu
      libogg
      libvorbis
      SDL
      SDL2_image
      glew110
      libidn
      tbb

      # Other things from runtime
      flac
      freeglut
      libjpeg
      libpng
      libpng12
      libsamplerate
      libmikmod
      libtheora
      libtiff
      pixman
      speex
      SDL_image
      SDL_ttf
      SDL_mixer
      SDL2_ttf
      SDL2_mixer
      libappindicator-gtk2
      libdbusmenu-gtk2
      libindicator-gtk2
      libcaca
      libcanberra
      libgcrypt
      libvpx
      librsvg
      xorg.libXft
      libvdpau
      # ...
      # Some more libraries that I needed to run programs
      pango
      cairo
      atk
      gdk-pixbuf
      fontconfig
      freetype
      dbus
      alsa-lib
      expat
      # for blender
      libxkbcommon

      libxcrypt-legacy # For natron
      libGLU # For natron

      # Appimages need fuse, e.g. https://musescore.org/fr/download/musescore-x86_64.AppImage
      fuse
      e2fsprogs
      libappimage
    ];
  };

  # Share
  environment.pathsToLink = [
    "/share/fish"
    "/share/zsh"
    "/share/bash-completion"
    "/share/applications"
    "/share/xdg-desktop-portal"
    "/share/fonts"
    "/share/icons"
    "/share/man"
    "/share/info"
    "/libexec"
    "/share/apparmor"
    "/share/wayland-sessions"
    "/etc/systemd/user"
  ];

  # Virtualisation
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    autoPrune.enable = true;
    dockerSocket.enable = true;
  };
  virtualisation.kvmgt.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu_kvm;
  };
  virtualisation.waydroid.enable = true;

  environment.systemPackages = with pkgs; [
    (pkgs.sddm-astronaut.override {embeddedTheme = "black_hole";})
    apparmor-profiles
    python313Packages.pygments

    app2unit
    wget

    nixd
    alejandra
    sops
    cachix
    libsecret
    nix-your-shell

    wl-clipboard
    wayland-utils
    libsecret
    cage
    gamescope
    xwayland-satellite-unstable

    inputs.nix-alien.packages.${system}.nix-alien
  ];

  # Git
  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  services.openssh.enable = true;

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
  };

  # Goldwarden (Password Manager and SSH)
  programs.goldwarden = {
    enable = true;
    useSshAgent = true;
  };

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    nix-direnv.package = pkgs.nix-direnv-flakes;
    loadInNixShell = true;
  };

  networking.firewall.enable = true;
  services.syncthing.openDefaultPorts = true;

  system.stateVersion = "25.05";
}
