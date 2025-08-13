{
  description = "Gabz NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien.url = "github:thiagokokada/nix-alien";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
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
        inputs.catppuccin.nixosModules.catppuccin

        inputs.chaotic.nixosModules.default

        ({system, ...}: {
          environment.systemPackages = with inputs.nix-alien.packages.${system}; [
            nix-alien
          ];

          programs.nix-ld.enable = true;
        })

        ./configuration.nix

        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs self;
            system = "x86_64-linux";
            pkgs-stable = import inputs.nixpkgs-stable {
              inherit system;
              config.allowUnfree = true;
            };
          };

          home-manager.sharedModules = [
            inputs.sops-nix.homeManagerModules.sops
            inputs.chaotic.homeManagerModules.default
            inputs.nix4nvchad.homeManagerModule
            ({system, ...}: {
              home.packages = with inputs.nix-alien.packages.${system}; [
                nix-alien
              ];
            })
            #---> inputs.stylix.homeModules.stylix
            inputs.catppuccin.homeModules.catppuccin
          ];

          home-manager.backupFileExtension = "bak";

          home-manager.users.gabz = import ./home.nix;

          # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
        }
      ];
    };
  };
}
