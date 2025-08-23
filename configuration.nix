{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Define my user account.
  users.users.gabz = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Gabriel";
    extraGroups = ["networkmanager" "wheel" "podman" "video" "render" "audio" "realtime"];
  };

  # The stateVersion that my system started with. Cannot change.
  system.stateVersion = "25.05";
}
