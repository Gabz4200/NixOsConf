{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Core System Modules
  core.boot.enable = true;
  core.networking.enable = true;
  core.nix.enable = true;
  core.secrets.enable = true;
  core.security.enable = true;
  core.system.enable = true;

  # Desktop Environment Modules
  desktop.niri.enable = true;
  desktop.wayland.enable = true;
  desktop.xdg.enable = true;

  # Feature Modules
  features.desktop.enable = true;
  features.development.enable = true;
  features.gaming.enable = true;
  features.music.enable = true;
  features.virtualization.enable = true;

  # Hardware Modules
  hardware.intelGPU.enable = true;
  hardware.intelGPU.enablePSR = false;
  hardware.intelGPU.enableGuC = 0;

  # Service Modules
  services.audio.enable = true;
  services.displayManager.enable = true;
  services.power.enable = true;

  # Theming Modules
  theming.stylix.enable = true;

  # User Modules
  users.gabz.enable = true;

  # Enable CachyOS perf tweaks for benchmarking (optional)
  features.cachyos.enable = true;
  features.cachyos.unstable = true;

  # The stateVersion that my system started with. Cannot change.
  system.stateVersion = "25.05";
}
