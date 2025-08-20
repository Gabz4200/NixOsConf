{
  description = "Gabz NixOS system's Modular Configuration";

  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Wayland/Compositor
    niri.url = "github:sodiboo/niri-flake";
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Gaming
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nix-gaming.url = "github:fufexan/nix-gaming";

    # Graphics
    nixgl.url = "github:nix-community/nixGL";

    # Home & System Management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Theming
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";

    # Hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    # Dev Tools
    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien.url = "github:thiagokokada/nix-alien";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    outputs = self;

    # Stable pkgs for downgrade
    pkgs-stable = import inputs.nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };

    # Special args
    specialArgs = {
      inherit inputs outputs system pkgs-stable;
    };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;

      modules = [
        # Hardware & Firmware
        ./hardware-configuration.nix
        ./modules/hardware/intel-gpu.nix
        # Fix: TODO: ./modules/hardware/laptop.nix

        # Core System
        ./modules/core/boot.nix
        # Fix: TODO: ./modules/core/networking.nix
        ./modules/core/nix.nix
        # Fix: TODO: ./modules/core/security.nix
        ./modules/core/system.nix

        # Desktop Environment
        # Fix: TODO: ./modules/desktop/niri.nix
        # Fix: TODO: ./modules/desktop/wayland.nix
        # Fix: TODO: ./modules/desktop/xdg.nix
        ./modules/features/desktop.nix

        # Services
        # Fix: TODO: ./modules/services/audio.nix
        # Fix: TODO: ./modules/services/display-manager.nix
        ./modules/services/power.nix

        # Features
        ./modules/features/gaming.nix
        # Fix: TODO: ./modules/features/virtualization.nix
        ./modules/features/development.nix

        # Theming
        # Fix: TODO: ./modules/theming/stylix.nix

        # Users
        # Fix: TODO: ./modules/users/gabz.nix

        # Secrets
        inputs.sops-nix.nixosModules.sops
        # Fix: TODO: ./modules/core/secrets.nix

        # External Modules
        inputs.nixos-hardware.nixosModules.asus-battery

        inputs.nixos-hardware.nixosModules.common-cpu-intel
        inputs.nixos-hardware.nixosModules.common-gpu-intel

        inputs.nixos-hardware.nixosModules.common-pc-laptop
        inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd

        #inputs.nixos-hardware.nixosModules.common-cpu-intel-kaby-lake

        inputs.nixos-facter-modules.nixosModules.facter
        {config.facter.reportPath = ./facter.json;}

        inputs.stylix.nixosModules.stylix
        inputs.chaotic.nixosModules.default

        inputs.nix-gaming.nixosModules.pipewireLowLatency
        inputs.nix-gaming.nixosModules.platformOptimizations
        inputs.nix-gaming.nixosModules.wine

        ./configuration.nix

        # Home Manager
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            extraSpecialArgs = specialArgs;
            backupFileExtension = "bak";

            sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
              inputs.nix4nvchad.homeManagerModule
              inputs.catppuccin.homeModules.catppuccin
              inputs.niri.homeModules.niri
            ];

            users.gabz = import ./home/default.nix;
          };
        }
      ];
    };
  };
}
