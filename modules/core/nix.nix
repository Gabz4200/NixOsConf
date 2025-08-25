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
    overlay.enable = true;
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
