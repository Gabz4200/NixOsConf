{
  description = "Gabz NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien.url = "github:thiagokokada/nix-alien";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {inherit inputs system;};
      modules = [
        inputs.sops-nix.nixosModules.sops
        inputs.stylix.nixosModules.stylix

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
            system = "x86_64-linux";
          };

          home-manager.sharedModules = [
            inputs.sops-nix.homeManagerModules.sops
            ({system, ...}: {
              home.packages = with inputs.nix-alien.packages.${system}; [
                nix-alien
              ];
            })
            #---> inputs.stylix.homeModules.stylix
          ];

          home-manager.backupFileExtension = "bak";

          home-manager.users.gabz = import ./home.nix;

          # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
        }
      ];
    };
  };
}
