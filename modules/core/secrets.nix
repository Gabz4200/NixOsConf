{
  config,
  lib,
  ...
}: {
  # Single-source secrets via sops-nix (NixOS). Home Manager reads via nixosConfig.
  # flake.nix already imports inputs.sops-nix.nixosModules.sops

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/home/gabz/.config/sops/age/keys.txt";

    secrets = {
      "git" = {
        owner = "gabz";
        path = "/home/gabz/.config/git/user";
        mode = "0440";
        neededForUsers = true;
      };
      "sync" = {
        owner = "gabz";
        path = "/home/gabz/.local/state/syncthing/config.xml";
        mode = "0440";
        neededForUsers = true;
      };
    };
  };
}
