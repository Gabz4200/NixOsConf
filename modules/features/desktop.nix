{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}: {
  imports = [
  ];

  # UWSM
  # Do I really want to use it with Niri?
  # I came from Hyprland, so it was instinct.
  # But look at: https://yalter.github.io/niri/Example-systemd-Setup.html
  programs.uwsm.enable = true;
  programs.uwsm.waylandCompositors = {
    niri = {
      prettyName = "Niri";
      comment = "Niri compositor managed by UWSM";
      binPath = "${pkgs.niri-unstable}/bin/niri-session";
    };
  };

  # Niri (Love it, but I need to spicy it up a bit)
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  # Flatpak
  services.flatpak.enable = true;

  # Dconf
  programs.dconf.enable = true;

  # Security
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = {};

  # Stylix (aka. theming)
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    image = ./wallpaper.jpg;
    polarity = "dark";
    fonts = {
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
    cursor.package = pkgs.bibata-cursors;
    cursor.name = "Bibata-Modern-Ice";
    cursor.size = 24;

    # I would want it enabled. But some themes are not that great (mainly the zsh-syntax-highlighting),
    # so I use it together with catppuccin.nix flake. Dont know how to make it suck less.
    # I think the main problem are
    # # 1- Only 16 colors aint enough for everything.
    # # 2- The catppuccin one may have them ordered in a weird way that makes thing that should be bright, be dark.
    autoEnable = false;

    homeManagerIntegration.autoImport = true;
    homeManagerIntegration.followSystem = true;
  };

  # Fonts (font-awesome and dejavu_fonts need to be here so )
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-mono
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.jetbrains-mono
    font-awesome
    dejavu_fonts
    nerd-fonts.symbols-only
  ];

  # Enable the X11 windowing system.
  programs.xwayland.enable = true;
  programs.xwayland.package = pkgs.xwayland;

  # SDDM (Works great)
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

    # Dont know if really needed. But if dont hurting, can let it.
    lowLatency = {
      enable = true;
      # defaults
      quantum = 64;
      rate = 48000;
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  programs = {
    # File manager integration
    nautilus-open-any-terminal = {
      enable = true;
      terminal = "kitty";
    };
  };

  appstream.enable = true;

  # pathsToLink
  # Dont know if all of them are really needed. i think some are not.
  environment.pathsToLink = [
    "/share/zsh"
    "/share/applications"
    "/share/xdg-desktop-portal"
    "/share/fonts"
    "/share/icons"
    "/share/man"
    "/share/info"
    "/libexec" #<--- Maybe a bad Idea?
    "/share/apparmor"
    "/share/wayland-sessions"
    "/etc/systemd/user"
    "/share/glib-2.0/"
  ];

  environment.systemPackages = with pkgs; [
    (pkgs.sddm-astronaut.override {embeddedTheme = "black_hole";})
    apparmor-profiles

    # Needed for oh-my-zsh plugins
    python313Packages.pygments

    app2unit
    uwsm
    niri-unstable
    wget

    # Create an FHS environment using the command `fhs`, enabling the execution of non-NixOS packages in NixOS!
    # Maybe could be better made tho?
    (let
      base = pkgs.appimageTools.defaultFhsEnvArgs;
    in
      pkgs.buildFHSEnv (base
        // {
          name = "fhs";
          targetPkgs = pkgs:
            (base.targetPkgs pkgs)
            ++ (config.programs.nix-ld.libraries)
            ++ (
              with pkgs; [
                bash
                zsh
              ]
            );
          profile = "export FHS=1";
          runScript = "zsh";
          extraOutputsToInstall = ["dev"];
        }))

    # Can it be better than the handmade?
    steam-run

    sops
    cachix

    # It isnt working. It installs, but that is it.
    outputs.packages.x86_64-linux.davinci-resolve

    libsecret
    nix-your-shell

    appimageupdate
    gearlever

    nautilus

    gamemode
    gamescope

    inputs.nix-alien.packages.${system}.nix-alien

    # Gnome apps
    # I want default desktop apps on my Niri. Gnome was the ones I knew would be good enough.
    # Maybe change a bit?
    baobab
    decibels
    epiphany
    gnome-text-editor
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-clocks
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-music
    gnome-system-monitor
    loupe
    nautilus
    gnome-connections
    simple-scan
    snapshot
    totem
    yelp
    gnome-software
  ];

  # Firewall. Great?
  networking.firewall.enable = true;
  networking.firewall.allowPing = false;
  networking.nftables.enable = true;

  networking.firewall.allowedTCPPorts = [];
  networking.firewall.allowedUDPPorts = [];

  networking.enableIPv6 = true;

  services.syncthing.openDefaultPorts = true;
  services.minecraft-server.openFirewall = true;
}
