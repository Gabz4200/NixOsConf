{
  description = "Gabz NixOS system's Modular Configuration";

  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Wayland/Compositor
    niri.url = "github:sodiboo/niri-flake";

    # Gaming and Performance
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nix-gaming.url = "github:fufexan/nix-gaming";

    # Sandbox for apps that simply not worky on NixOS
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Wifi Git Src (the version nixpkgs uses is broken. But master has the fix, so I override it)
    rtl8821ce-src = {
      url = "github:tomaspinho/rtl8821ce/master";
      flake = false;
    };

    # Secret
    local = {
      url = "/home/gabz/NixConf/local";
      flake = false;
    };

    # Home & System Management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Theming (having a hard time deciding)
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules = {
      url = "github:numtide/nixos-facter-modules";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    # Dev Tools
    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Utilities and ecosystem
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
  };

  # Maybe is a good Idea to centralize Substituters here? I have to be sure it would apply to the whole Flake.
  # I prefer Cachix, but I dont want to have annoyances about adding Cache before adding the pkg
  nixConfig = {
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

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    outputs = self;

    #Todo: I want to make this pkgs as a "single source of truth", but I know I would need to change things
    # pkgs = import nixpkgs {
    #   inherit system;

    #   config = {
    #     allowUnfree = true;
    #     allowBroken = false;
    #   };

    #   # Overlays
    #   overlays = [
    #     inputs.niri.overlays.niri
    #     inputs.chaotic.overlays.cache-friendly
    #   ];

    #   # Flake settings
    #   flake = {
    #     setFlakeRegistry = true;
    #     setNixPath = true;
    #   };
    # };

    # Stable pkgs for downgrade
    pkgs-stable = import inputs.nixpkgs-stable {
      inherit system;

      config = {
        allowUnfree = true;
        allowBroken = false;
      };

      # Overlays
      overlays = [
        inputs.niri.overlays.niri
        inputs.chaotic.overlays.cache-friendly
        inputs.nur.overlays.default
      ];

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

      # Flake settings
      flake = {
        setFlakeRegistry = true;
        setNixPath = true;
      };
    };

    # todo: Insert pkgs here when the changes are done
    # Special args
    specialArgs = {
      inherit inputs outputs system pkgs-stable;
    };
  in {
    # packages."${system}" = let
    #   inherit pkgs;

    #   mkNixPak = inputs.nixpak.lib.nixpak {
    #     inherit (pkgs) lib;
    #     inherit pkgs;
    #   };
    # in {
    # };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;

      modules = [
        ./cachix.nix

        #todo: Temporary, readOnlyPackages being broken really sucks.
        {
          nixpkgs = {
            inherit system;

            config = {
              allowUnfree = true;
              allowBroken = false;
            };

            # Overlays
            overlays = nixpkgs.lib.mkBefore [
              inputs.niri.overlays.niri
              inputs.chaotic.overlays.cache-friendly
              inputs.nur.overlays.default
            ];

            # Flake settings
            flake = {
              setFlakeRegistry = true;
              setNixPath = true;
            };
          };
        }

        inputs.nur.modules.nixos.default
        # todo: NUR modules to import
        # inputs.nur.legacyPackages."${system}".repos.iopq.modules.xraya

        # Hardware & Firmware
        ./hardware-configuration.nix
        ./modules/hardware/intel-gpu.nix
        ./modules/hardware/cachyos.nix

        # Core System
        ./modules/core/boot.nix
        ./modules/core/networking.nix
        ./modules/core/nix.nix
        ./modules/core/security.nix
        ./modules/core/system.nix

        # Desktop Environment
        ./modules/desktop/niri.nix
        ./modules/desktop/wayland.nix
        ./modules/desktop/xdg.nix
        ./modules/features/desktop.nix

        # Services
        ./modules/services/audio.nix
        ./modules/services/display-manager.nix
        ./modules/services/power.nix

        # Features
        ./modules/features/gaming.nix
        ./modules/features/virtualization.nix
        ./modules/features/development.nix

        # Theming
        ./modules/theming/stylix.nix

        # Users
        ./modules/users/gabz.nix

        # Secrets
        inputs.sops-nix.nixosModules.sops
        ./modules/core/secrets.nix

        # External Modules
        inputs.nixos-hardware.nixosModules.asus-battery

        inputs.nixos-hardware.nixosModules.common-cpu-intel
        inputs.nixos-hardware.nixosModules.common-gpu-intel

        inputs.nixos-hardware.nixosModules.common-pc-laptop
        inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd

        # Para burlar o fato do flake só ver coisas git added e o facter.json não poder estar no Github
        inputs.nixos-facter-modules.nixosModules.facter
        {config.facter.reportPath = "${inputs.local}/facter.json";}

        inputs.stylix.nixosModules.stylix
        inputs.chaotic.nixosModules.default

        inputs.nix-gaming.nixosModules.pipewireLowLatency
        inputs.nix-gaming.nixosModules.platformOptimizations
        inputs.nix-gaming.nixosModules.wine

        # Helpful: enable fast nix-locate with prebuilt DB
        inputs.nix-index-database.nixosModules.nix-index
        {programs.nix-index-database.comma.enable = true;}

        ./configuration.nix

        # Home Manager
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            extraSpecialArgs = specialArgs;
            backupFileExtension = "backup";

            sharedModules = [
              ./cachix.nix
              inputs.nix4nvchad.homeManagerModule
              inputs.catppuccin.homeModules.catppuccin
              inputs.niri.homeModules.niri
              inputs.nix-flatpak.homeManagerModules.nix-flatpak
              # Helpful: enable fast nix-locate in shells too
              inputs.nix-index-database.homeModules.nix-index
              {programs.nix-index.enable = true;}
              #({lib, ...}: {imports = lib.attrValues inputs.nur.repos.moredhel.hmModules.rawModules;})
            ];

            users.gabz = import ./home/default.nix;
          };
        }
      ];
    };

    #todo: Make a backup configuration with the bare minimum and the internet driver. It would help if I ever reformat this computer again.

    # Just in case I need it.
    # devShells."${system}".default = let
    #   inherit pkgs;
    # in
    #   pkgs.mkShell {
    #     packages = with pkgs; [
    #       vscodium-fhs
    #       nixd
    #       zsh
    #       alejandra
    #       just
    #     ];

    #     shellHook = ''
    #       echo "hello"
    #     '';
    #   };
  };
}
