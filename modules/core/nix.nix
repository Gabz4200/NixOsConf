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

      # Segurança
      sandbox = true;
      trusted-users = ["@wheel" "root" "gabz"];
      allowed-users = ["@wheel" "root" "gabz"];
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
  };

  # Nyx (change if readonly package)
  chaotic.nyx = {
    cache.enable = true;
    nixPath.enable = true;
    overlay.enable = lib.mkForce false;
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
