{
  description = "Gabz NixOS flake";

  inputs = {
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    niri.url = "github:sodiboo/niri-flake";
    #--> zen-browser.url = "github:MarceColl/zen-browser-flake";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";

    nix-alien.url = "github:thiagokokada/nix-alien";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs self system;
        pkgs-stable = import inputs.nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      modules = [
        inputs.sops-nix.nixosModules.sops

        inputs.nixos-hardware.nixosModules.asus-battery
        inputs.nixos-hardware.nixosModules.common-cpu-intel
        inputs.nixos-hardware.nixosModules.common-gpu-intel
        inputs.nixos-hardware.nixosModules.common-pc-laptop
        inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
        inputs.nixos-hardware.nixosModules.common-hidpi

        inputs.nixos-facter-modules.nixosModules.facter
        {config.facter.reportPath = ./facter.json;}

        inputs.stylix.nixosModules.stylix

        inputs.chaotic.nixosModules.default
        inputs.niri.nixosModules.niri

        ./configuration.nix

        ({config, ...}:
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs self;
              nixosConfigurations = config;
              system = "x86_64-linux";
              pkgs-stable = import inputs.nixpkgs-stable {
                inherit system;
                config.allowUnfree = true;
              };
            };

            home-manager.sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
              inputs.nix4nvchad.homeManagerModule
              inputs.catppuccin.homeModules.catppuccin
              inputs.niri.homeModules.niri
            ];

            home-manager.backupFileExtension = "bak";

            home-manager.users.gabz = import ./home.nix;
          })
      ];
    };
  };
}
