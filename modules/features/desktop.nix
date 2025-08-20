{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
  ];

  # UWSM
  programs.uwsm.enable = true;
  programs.uwsm.waylandCompositors = {
    niri = {
      prettyName = "Niri";
      comment = "Niri compositor managed by UWSM";
      binPath = "${pkgs.niri-unstable}/bin/niri-session";
    };
  };

  # Niri
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

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

    autoEnable = false;
    homeManagerIntegration.autoImport = true;
    homeManagerIntegration.followSystem = true;
  };

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

  # Enable the X11 windowing system.
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

  #services.gnome.core-apps.enable = true;

  # Share
  environment.pathsToLink = [
    "/share/zsh"
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
    "/share/glib-2.0/"
  ];

  environment.systemPackages = with pkgs; [
    (pkgs.sddm-astronaut.override {embeddedTheme = "black_hole";})
    apparmor-profiles
    python313Packages.pygments

    app2unit
    uwsm
    niri-unstable
    wget

    # Create an FHS environment using the command `fhs`, enabling the execution of non-NixOS packages in NixOS!
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
    steam-run

    sops
    cachix

    libsecret
    nix-your-shell

    appimageupdate
    gearlever

    nautilus

    gamemode
    gamescope

    inputs.nix-alien.packages.${system}.nix-alien
  ];

  networking.firewall.enable = true;
  networking.firewall.allowPing = false;
  networking.nftables.enable = true;

  networking.firewall.allowedTCPPorts = [];
  networking.firewall.allowedUDPPorts = [];

  networking.enableIPv6 = true;

  services.syncthing.openDefaultPorts = true;
  services.minecraft-server.openFirewall = true;
}
