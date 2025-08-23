{
  description = "Gabz NixOS system's Modular Configuration";

  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Wayland/Compositor
    niri.url = "github:sodiboo/niri-flake";

    # Gaming
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nix-gaming.url = "github:fufexan/nix-gaming";

    # Sandbox for apps that simply not worky on NixOS
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Wifi Git Src (the version nixpkgs uses is broken. But master has the fix, so I override it)
    rtl8821ce-src = {
      url = "github:tomaspinho/rtl8821ce/master";
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

  # Maybe is a good Idea to centralize Substituters here? I have to be sure it would apply to the whole Flake.
  nixConfig = {
    allowUnfree = true;

    sandbox = true;
    trusted-users = ["@wheel" "gabz"];
    allowed-users = ["@wheel" "gabz"];

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
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    outputs = self;

    #Todo: I want to make this pkgs as a "single source of truth", but I know I would need to change things
    # pkgs
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      sandbox = true;
      trusted-users = ["@wheel" "gabz"];
      allowed-users = ["@wheel" "gabz"];
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
      overlays = [
        inputs.niri.overlays.niri
        inputs.chaotic.overlays.default
      ];
    };

    # Stable pkgs for downgrade
    pkgs-stable = import inputs.nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
      sandbox = true;
      trusted-users = ["@wheel" "gabz"];
      allowed-users = ["@wheel" "gabz"];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://niri.cachix.org"
        "https://chaotic-nyx.cachix.org"
        "https://nix-gaming.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];
    };

    # todo: Insert pkgs here when the changes are done
    # Special args
    specialArgs = {
      inherit inputs outputs system pkgs-stable;
    };
  in {
    #todo: I tryed to fix Davinci Resolve (It doesnt recognize my GPU), but it didnt work
    packages."${system}" = let
      inherit pkgs;

      mkNixPak = inputs.nixpak.lib.nixpak {
        inherit (pkgs) lib;
        inherit pkgs;
      };

      davinci-resolve-with-deps = pkgs.buildEnv {
        name = "davinci-resolve-with-intel-drivers";

        paths = [
          pkgs.davinci-resolve
          pkgs.intel-compute-runtime
          pkgs.intel-ocl
          pkgs.intel-media-driver
          pkgs.libva
        ];
      };

      sandboxed-davinci-resolve = mkNixPak {
        config = {sloth, ...}: {
          app.package = davinci-resolve-with-deps;
          app.binPath = "bin/resolve";
          flatpak.appId = "com.blackmagicdesign.Resolve";

          dbus.enable = true;
          dbus.policies = {
            "org.freedesktop.DBus" = "talk";
            "org.freedesktop.login1" = "see";
          };

          bubblewrap = {
            network = true;

            bind.rw = [
              (sloth.env "XDG_RUNTIME_DIR")
              (sloth.concat' sloth.homeDir "/Videos")
              (sloth.concat' sloth.homeDir "/Documents")
              (sloth.concat' sloth.homeDir "/.local/state/nixpak/resolve-runtime")
            ];

            bind.ro = [
              (sloth.concat' sloth.homeDir "/Downloads")
              (sloth.concat' sloth.homeDir "/.config")
            ];

            bind.dev = [
              "/dev/dri"
              "/dev/snd"
            ];
          };
        };
      };
    in {
      davinci-resolve = sandboxed-davinci-resolve.config.env;
    };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;

      modules = [
        # Hardware & Firmware
        ./hardware-configuration.nix
        ./modules/hardware/intel-gpu.nix
        ./modules/hardware/laptop.nix

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
            backupFileExtension = "backup";

            sharedModules = [
              inputs.nix4nvchad.homeManagerModule
              inputs.catppuccin.homeModules.catppuccin
              inputs.niri.homeModules.niri
              inputs.nix-flatpak.homeManagerModules.nix-flatpak
            ];

            users.gabz = import ./home/default.nix;
          };
        }
      ];
    };

    #todo: Make a backup configuration with the bare minimum and the internet driver. It would help if I ever reformat this computer again.

    # Just in case I need it.
    devShells."${system}".default = let
      inherit pkgs;
    in
      pkgs.mkShell {
        packages = with pkgs; [
          vscodium-fhs
          nixd
          zsh
          alejandra
          just
        ];

        shellHook = ''
          echo "hello"
        '';
      };
  };
}
