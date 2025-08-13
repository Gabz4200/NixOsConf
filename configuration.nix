# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Dbus
  services.dbus.implementation = "broker";
  services.dbus.enable = true;

  services.resolved.enable = true;

  # UWSM
  programs.uwsm.enable = true;

  # Wayland
  #---> programs.waybar.enable = true;

  # Hyprland
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;
  programs.hyprland.withUWSM = true;

  # Niri
  programs.niri.enable = true;
  programs.niri.package = pkgs.niri_git;

  # Apparmor
  services.dbus.apparmor = "enabled";
  security.apparmor.enable = true;
  security.apparmor.killUnconfinedConfinables = true;
  security.apparmor.enableCache = true;

  security.polkit.enable = true;

  # Catppuccin Mocha
  # catppuccin.enable = true;
  # catppuccin.flavor = "mocha";
  # catppuccin.accent = "pink";
  # catppuccin.cache.enable = true;

  # catppuccin.sddm.enable = false;

  # Stylix
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  stylix.image = ./wallpaper.jpg;
  stylix.polarity = "dark";
  #TODO: Use my beloved Nerd Fonts like Fira and Caskadya
  stylix.fonts = {
    serif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Serif";
    };

    sansSerif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Sans";
    };

    monospace = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Sans Mono";
    };

    emoji = {
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };
  };
  stylix.autoEnable = true;
  stylix.cursor.package = pkgs.bibata-cursors;
  stylix.cursor.name = "Bibata-Modern-Ice";
  stylix.cursor.size = 24;
  stylix.homeManagerIntegration.autoImport = true;
  stylix.homeManagerIntegration.followSystem = true;

  # Sops
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = ["/home/${config.users.users.gabz.name}/.ssh/id_ed25519"];

    age.keyFile = "/home/${config.users.users.gabz.name}/.config/sops/age/keys.txt";
    age.generateKey = true;

    # I am still learning how to properly manage these secrets with nix-sops
    secrets = {
      "git" = {
        owner = config.users.users.gabz.name;
      };
    };
  };

  # Hardware and Firmware
  hardware.enableAllFirmware = true;
  hardware.enableAllHardware = true;
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  services.fwupd.enable = true;

  # Asus
  services.asusd.enable = true;

  # Zram
  zramSwap.enable = true;
  zramSwap.priority = 200;
  zramSwap.memoryPercent = 100;
  zramSwap.algorithm = "zstd";

  # Preload
  services.preload.enable = true;

  # KabyLake GPU
  boot.kernelParams = [
    "i915.enable_guc=2"
    "i915.enable_fbc=1"
    "i915.enable_psr=2"
    "pcie_aspm=off"
  ];

  hardware.intel-gpu-tools.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  chaotic.nyx.cache.enable = true;
  chaotic.nyx.nixPath.enable = true;
  chaotic.nyx.overlay.enable = true;

  chaotic.mesa-git.enable = true;
  chaotic.mesa-git.extraPackages = with pkgs; [
    mesa_git.opencl
    intel-media-driver
    intel-ocl
    vaapiIntel
  ];
  chaotic.mesa-git.extraPackages32 = with pkgs.pkgsi686Linux; [
    pkgs.mesa32_git.opencl
    intel-media-driver
    vaapiIntel
  ];

  # Scx
  services.scx.enable = true;
  services.scx.package = pkgs.scx_git.full;
  services.scx.scheduler = "scx_lavd";
  services.scx.extraArgs = ["--autopilot"];

  # Auto Cpu Freq
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
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
  services.power-profiles-daemon.enable = false;

  # Undervolt
  services.undervolt.enable = true;
  services.undervolt.uncoreOffset = -80;
  services.undervolt.turbo = 0;
  services.undervolt.tempBat = 85;
  services.undervolt.tempAc = 95;
  services.undervolt.p2.window = 1;
  services.undervolt.p2.limit = 40;
  services.undervolt.p1.window = 28;
  services.undervolt.p1.limit = 30;
  services.undervolt.gpuOffset = -40;
  services.undervolt.coreOffset = -80;
  services.undervolt.analogioOffset = -40;

  hardware.graphics.package = pkgs.mesa_git;
  hardware.graphics.package32 = pkgs.mesa32_git;

  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-ocl
    vulkan-loader
  ];

  hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
    intel-media-driver
    intel-vaapi-driver
    vulkan-loader
  ];

  # Dconf
  programs.dconf.enable = true;

  # Hibernate
  powerManagement.enable = true;

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Kernel
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  # Wifi driver
  boot.kernelModules = ["8821ce"];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl8821ce
  ];

  # Btrfs
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = ["/"];
  };

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
  # services.xserver.enable = true;
  programs.xwayland.enable = true;

  # Enable the Cinnamon Desktop Environment.
  # services.xserver.displayManager.lightdm.enable = true;
  # services.xserver.desktopManager.cinnamon.enable = true;

  # Use Cosmic as a fallback to Hyprland or Niri
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = false;
  services.desktopManager.cosmic.xwayland.enable = true;

  # SDDM
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.package = pkgs.kdePackages.sddm;
  services.displayManager.sddm.enable = true;
  #services.displayManager.sddm.enableHidpi = true;
  #services.displayManager.sddm.wayland.compositor = "kwin";
  services.displayManager.sddm.extraPackages = [
    pkgs.kdePackages.qtsvg
    pkgs.kdePackages.qtmultimedia
    pkgs.kdePackages.qtvirtualkeyboard
    (pkgs.sddm-astronaut.override {embeddedTheme = "black_hole";})
  ];
  services.displayManager.sddm.theme = "sddm-astronaut-theme";

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

  #--> sops.secrets."initial_hashed_password".neededForUsers = true;

  # Not sure if this below is really needed, its called on home-manager.
  sops.secrets."git".neededForUsers = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gabz = {
    isNormalUser = true;
    #TODO: Choose between Zsh and Fish
    shell = pkgs.zsh;
    #---> hashedPasswordFile = config.sops.secrets."initial_hashed_password".path;
    description = "Gabriel";
    extraGroups = ["networkmanager" "wheel" "podman"];
    #packages = with pkgs; [
    #  #  thunderbird
    #];
  };

  # Install firefox.
  programs.firefox.enable = true;
  programs.firefox.package = pkgs.firedragon;

  # NH
  programs.nh.enable = true;
  programs.nh.flake = "/home/${config.users.users.gabz.name}/NixConf";
  programs.nh.clean.enable = true;
  programs.nh.clean.dates = "weekly";
  programs.nh.clean.extraArgs = "--keep 5 --keep-since 3d";

  nixpkgs.flake.setFlakeRegistry = true;
  nixpkgs.flake.setNixPath = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.trusted-users = ["@wheel" "root" "${config.users.users.gabz.name}"];

  nix.settings.sandbox = true;
  programs.nix-required-mounts.enable = true;

  nix.settings.auto-optimise-store = true;

  nix.optimise.automatic = true;
  nix.optimise.persistent = true;
  nix.optimise.dates = ["19:00"];

  # NvChad
  # nixpkgs = {
  #   overlays = [
  #     (final: prev: {
  #       nvchad = inputs.nix4nvchad.packages."${pkgs.system}".nvchad;
  #     })
  #   ];
  # };

  #TODO: Learn to decide when something
  # is defined on NixOS and when on Home-Manager

  # Zsh setup
  programs.zsh.syntaxHighlighting.highlighters = ["main"];
  programs.zsh.enableCompletion = true;
  programs.zsh.zsh-autoenv.enable = true;
  programs.zsh.ohMyZsh.enable = true;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.autosuggestions.strategy = ["completion" "history"];
  programs.zsh.syntaxHighlighting.enable = true;

  programs.zsh.ohMyZsh.plugins = ["common-aliases" "sudo" "alias-finder" "colored-man-pages" "colorize" "copybuffer" "copyfile" "copypath" "eza" "git" "gh"];
  programs.zsh.enableLsColors = true;

  # Zoxide
  programs.zoxide.enable = true;
  programs.zoxide.enableZshIntegration = true;
  programs.zoxide.enableFishIntegration = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Zsh over bash
  programs.zsh.enable = true;
  programs.fish.enable = true;

  # AppImage
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.gnome.gnome-keyring.enable = true;

  # Nix-Ld
  programs.nix-index.enable = true;
  programs.nix-index.enableBashIntegration = true;
  programs.nix-index.enableZshIntegration = true;
  programs.nix-index.enableFishIntegration = true;
  programs.command-not-found.enable = false;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    zlib
    zstd
    libcxxStdenv
    gccStdenv
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
    coreutils-full
    xz
    systemd
    glibc
    bash
    pkg-config
    libsecret
    python313Packages.pygments
    lan-mouse_git
  ];

  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  nix.settings.substituters = ["https://chaotic-nyx.cachix.org" "https://nix-community.cachix.org" "https://hyprland.cachix.org" "https://numtide.cachix.org" "https://cache.nixos.org/" ];
  nix.settings.trusted-public-keys = [ "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  

  # XDG
  xdg.terminal-exec.enable = true;
  #---> xdg.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-cosmic
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gnome
  ];
  xdg.portal.configPackages = with pkgs; [
    niri
    hyprland
    cosmic-session
  ];

  xdg.portal.xdgOpenUsePortal = true;

  xdg.sounds.enable = true;
  xdg.mime.enable = true;
  xdg.menus.enable = true;
  xdg.icons.enable = true;
  xdg.autostart.enable = true;

  environment.pathsToLink = ["/share/fish" "/share/zsh" "/share/xdg-desktop-portal" "/share/applications" "/share"];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  environment.systemPackages = with pkgs; [
    (pkgs.sddm-astronaut.override {embeddedTheme = "black_hole";})
    apparmor-profiles
    python313Packages.pygments
    distrobox
    app2unit
    wget
    vscodium-fhs
    nixd
    alejandra
    neovim
    #--> nvchad
    sops
    easyeffects
    cachix
    libsecret
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

  #---> programs.ssh.startAgent = true;

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    loadInNixShell = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  networking.firewall.enable = true;
  services.syncthing.openDefaultPorts = true;

  system.stateVersion = "25.05";
}
