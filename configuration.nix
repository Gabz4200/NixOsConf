# Arquivo principal minimalista - tudo modularizado
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Define a user account.
  users.users.gabz = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Gabriel";
    extraGroups = ["networkmanager" "wheel" "podman" "video" "render" "audio" "realtime"];
  };

  system.stateVersion = "25.05";
}
