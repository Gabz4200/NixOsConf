{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  # I am not sure about ANYTHING here. I need help.

  # Nix daemon configuration
  nix = {
    # Features
    settings = {
      experimental-features = ["nix-command" "flakes"];

      # Performance
      auto-optimise-store = true;
      max-jobs = lib.mkDefault 8;
      cores = lib.mkDefault 8;

      # Segurança
      sandbox = true;
      trusted-users = ["@wheel" "gabz"];
      allowed-users = ["@wheel" "gabz"];

      # Substituters
      substituters = [
        "https://niri.cachix.org"
        "https://chaotic-nyx.cachix.org"
        "https://nix-gaming.cachix.org"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      # Garbage collection
      keep-outputs = true;
      keep-derivations = true;

      # Fallback
      fallback = true;
      connect-timeout = 5;

      # Baixar em paralelo
      http-connections = 50;

      # Warn sobre dirty git trees
      warn-dirty = false;
    };

    # Automatic optimization
    optimise = {
      automatic = true;
      dates = ["03:00"];
    };

    #todo: Automatic mapping of my flake inputs to here.
    # Registry and channels
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];

    channel.enable = false;

    # Extra config ( Wtf is happening here?)
    extraOptions = ''
      min-free = ${toString (1024 * 1024 * 1024)}
      max-free = ${toString (5 * 1024 * 1024 * 1024)}
    '';
  };

  # Nyx (change if readonly package)
  chaotic.nyx = {
    cache.enable = true;
    nixPath.enable = true;
    overlay.enable = true;
  };

  # Nixpkgs config
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = false;
    };

    # Overlays (change if readonly package)
    overlays = [
      inputs.niri.overlays.niri
      inputs.chaotic.overlays.default
    ];

    # Flake settings
    flake = {
      setFlakeRegistry = true;
      setNixPath = true;
    };
  };

  # NH - Nix Helper (Some config else?)
  programs.nh = {
    enable = true;
    flake = "/home/gabz/NixConf";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 7d";
    };
  };

  # Nix-ld (To help with foreign pkgs on NixOS)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Core system libraries
      glibc
      glib
      stdenv.cc.cc.lib

      # Basic Linux libraries
      zlib
      zstd
      bzip2
      xz
      openssl
      curl
      libxml2

      # Graphics (OpenGL/Vulkan)
      libGL
      libGLU
      vulkan-loader
      vpl-gpu-rt

      # X11/Wayland
      xorg.libX11
      xorg.libXext
      xorg.libXrender
      xorg.libXtst
      xorg.libXi
      wayland

      # GTK/Qt
      gtk3
      gtk4
      libadwaita

      # Multimedia
      alsa-lib
      pipewire
      libxkbcommon
      libxcrypt-legacy
      libGLU
      fuse

      # Common dependencies
      dbus
      libusb1
      systemd
      xdg-dbus-proxy
      xdg-utils
      libportal

      # Intel specific
      intel-compute-runtime
      ocl-icd
      intel-media-driver
    ];
  };

  # Nix-index
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  # Conflicts with nix-index
  programs.command-not-found.enable = false;

  # Packages
  environment.systemPackages = with pkgs; [
    nyx-generic-git-update
    cachix
  ];

  # Sandboxing compat
  programs.nix-required-mounts.enable = true;
}
