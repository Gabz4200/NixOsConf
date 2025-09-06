{
  config,
  lib,
  ...
}: let
  cfg = config.core.secrets;
in {
  # Single-source secrets via sops-nix (NixOS). Home Manager reads via nixosConfig.
  # flake.nix already imports inputs.sops-nix.nixosModules.sops

  #todo: Adress it.
  # Modules that depend on this functionality to exist should also use a `lib.mkIf` guard
  # around their configuration, to avoid evaluation errors when this module is disabled.
  # Example: Using a default alternative when no secrets are defined.

  options.core.secrets = {
    enable = lib.mkEnableOption "Enable secrets management via sops-nix";
    unstable = lib.mkEnableOption "Enable unstable secrets features and experimental configurations";
  };

  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";

      age.keyFile = "/home/gabz/.config/sops/age/keys.txt";

      secrets = {
        "git" = {
          owner = "gabz";
          path = "/home/gabz/.config/git/user";
          # git wasnt having permission to read the file
          mode = "644";
          neededForUsers = true;
        };
        "sync" = {
          owner = "gabz";
          path = "/home/gabz/.local/state/syncthing/config.xml";
          mode = "777";
          neededForUsers = true;
        };
      };
    };
  };
}
