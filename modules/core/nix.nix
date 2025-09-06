{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.core.nix;
in {
  # I am not sure about ANYTHING here. I need help.

  options.core.nix = {
    enable = lib.mkEnableOption "Enable Nix configuration and package management settings";
    unstable = lib.mkEnableOption "Enable unstable Nix features and experimental configurations";
  };

  config = lib.mkIf cfg.enable {
    # Nix daemon configuration
    nix = {
      # De-duplicate: global settings (experimental features, caches, trusted keys, users)
      # are defined once in flake.nix.nixConfig. Keep only host-specific bits here.
      settings = {
        experimental-features = ["nix-command" "flakes"];

        # Performance
        auto-optimise-store = true;

        # Segurança
        sandbox = true;
        trusted-users = ["@wheel" "root" "gabz"];
        allowed-users = ["@wheel" "root" "gabz"];

        # Substituters
        substituters = [
          "https://niri.cachix.org"
          "https://chaotic-nyx.cachix.org"
          "https://nix-gaming.cachix.org"
          "https://nur.cachix.org"
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://pre-commit-hooks.cachix.org"
          "https://catppuccin.cachix.org"
        ];

        trusted-public-keys = [
          "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
          "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
          "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
          "nur.cachix.org-1:F8+2oprcHLfsYyZBCsVJZJrPyGHwuE+EZBtukwalV7o="
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
          "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
        ];
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
  };
}
