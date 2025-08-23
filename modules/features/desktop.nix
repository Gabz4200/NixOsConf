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
  # Moved to modules/desktop/niri.nix

  # Moved to modules/desktop/niri.nix

  # Flatpak
  services.flatpak.enable = true;

  # Dconf
  programs.dconf.enable = true;

  # Security
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = {};

  # Moved to modules/theming/stylix.nix

  # Moved to modules/theming/stylix.nix

  # Moved to modules/desktop/wayland.nix

  # Moved to modules/services/display-manager.nix

  # Moved to modules/desktop/xdg.nix

  # Moved to modules/core/system.nix

  # Moved to modules/services/audio.nix

  # Moved to modules/desktop/wayland.nix

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
    apparmor-profiles

    # Needed for oh-my-zsh plugins
    python313Packages.pygments

    app2unit
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

  # Moved to modules/core/networking.nix

  services.syncthing.openDefaultPorts = true;
  services.minecraft-server.openFirewall = true;
}
