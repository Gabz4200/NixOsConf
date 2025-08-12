# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
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
  programs.waybar.enable = true;

  # Hyprland
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;
  programs.hyprland.withUWSM = true;

  # Niri
  programs.niri.enable = true;

  # Apparmor
  services.dbus.apparmor = "enabled";
  security.apparmor.enable = true;
  security.apparmor.killUnconfinedConfinables = true;
  security.apparmor.enableCache = true;

  security.polkit.enable = true;

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
  stylix.cursor.name = "Bibata Modern Ice";
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

  # Dconf
  programs.dconf.enable = true;

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
  services.xserver.enable = true;
  programs.xwayland.enable = true;

  # Enable the Cinnamon Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

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
    #---> hashedPasswordFile = config.sops.secrets."initial_hashed_password".path;
    description = "Gabriel";
    extraGroups = ["networkmanager" "wheel"];
    #packages = with pkgs; [
    #  #  thunderbird
    #];
  };

  # Install firefox.
  programs.firefox.enable = true;
  programs.firefox.package = pkgs.firefox-bin;

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
  ];

  # XDG
  xdg.terminal-exec.enable = true;
  #---> xdg.enable = true;
  xdg.portal.enable = true;
  xdg.portal.xdgOpenUsePortal = true;
  xdg.sounds.enable = true;
  xdg.mime.enable = true;
  xdg.menus.enable = true;
  xdg.icons.enable = true;
  xdg.autostart.enable = true;

  environment.systemPackages = with pkgs; [
    apparmor-profiles
    #--> app2unit
    wget
    vscodium-fhs
    nixd
    alejandra
    neovim
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

  networking.firewall.enable = true;
  services.syncthing.openDefaultPorts = true;

  system.stateVersion = "25.05";
}
