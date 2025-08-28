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

  # Enable CachyOS perf tweaks for benchmarking (optional)
  features.cachyos.enable = true;

  # Try Intel PSR/GuC (A/B test)
  hardware.intelGPU.enablePSR = false;
  hardware.intelGPU.enableGuC = 0;

  # The stateVersion that my system started with. Cannot change.
  system.stateVersion = "25.05";
}
