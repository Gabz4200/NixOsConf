{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.users.gabz;
in {
  # Define my user account.

  options.users.gabz = {
    enable = lib.mkEnableOption "Enable gabz user account and user-related configurations";
    unstable = lib.mkEnableOption "Enable unstable user features and experimental configurations";
  };

  config = lib.mkIf cfg.enable {
    users.users.gabz = {
      isNormalUser = true;
      shell = pkgs.zsh;
      description = "Gabriel";
      extraGroups = ["networkmanager" "wheel" "podman" "video" "render" "audio" "realtime"];
    };

    programs.zsh.enable = lib.mkForce true;
  };
}
