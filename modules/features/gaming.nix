{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  # Steam configuration
  programs.steam = {
    enable = true;

    # Compatibility tools
    extraCompatPackages = with pkgs; [
      proton-ge-custom
      proton-cachyos_x86_64_v3
    ];

    # Runtime packages necessários
    # The drivers are needed here tho?
    extraPackages = with pkgs; [
      gamemode
      gamescope

      # OpenCL/OpenGL para Intel
      ocl-icd
      intel-compute-runtime

      # Video decode/encode
      intel-media-driver
      libva
      libvdpau-va-gl
    ];

    # Features
    extest.enable = true;
    gamescopeSession.enable = true;
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;

    # Performance optimizations
    # Are these great on my Hardware?
    platformOptimizations.enable = true;
  };

  # Wine
  programs.wine = {
    enable = true;
    package = pkgs.wineWow64Packages.waylandFull;
    ntsync = true;

    # The intention was to be more secure, letting it to bottles. Dont know if needed.
    binfmt = false;
  };

  # Gamemode (Is this a good idea with scx?)
  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };

  # Java moved to Home Manager (per-user). Remove system binfmt to avoid duplication.

  hardware.graphics.enable32Bit = true;

  # User-facing gaming apps (launchers/tools) moved to Home Manager.

  # Firewall rules for gaming
  networking.firewall = {
    # Minecraft (Firewall messed up my Minecraft gameplay via Lan in older system. May this fix it?)
    allowedTCPPorts = [25565];
    allowedUDPPorts = [25565];
  };
}
