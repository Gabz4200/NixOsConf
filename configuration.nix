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

  # The stateVersion that my system started with. Cannot change.
  system.stateVersion = "25.05";
}
