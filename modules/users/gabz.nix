{ config, pkgs, lib, ... }:

{
  # Define my user account.
  users.users.gabz = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Gabriel";
    extraGroups = ["networkmanager" "wheel" "podman" "video" "render" "audio" "realtime"];
  };
}
