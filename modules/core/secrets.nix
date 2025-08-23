{ config, lib, ... }:

{
  # Single-source secrets via sops-nix (NixOS). Home Manager reads via nixosConfig.
  # flake.nix already imports inputs.sops-nix.nixosModules.sops

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/home/gabz/.config/sops/age/keys.txt";

    secrets = {
      # Git include file with user-specific config (e.g., signing, email)
      "git" = {
        # Leave default runtime path (/run/secrets/git) and set owner/mode so git can read it
        owner = "gabz";
        mode = "0400";
      };
    };
  };
}
