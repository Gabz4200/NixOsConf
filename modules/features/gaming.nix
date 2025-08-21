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
    platformOptimizations.enable = true;
  };

  # Wine
  programs.wine = {
    enable = true;
    package = pkgs.wineWow64Packages.waylandFull;
    ntsync = true;
    binfmt = false;
  };

  # Gamemode
  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };

  # Java for Minecraft
  programs.java = {
    enable = true;
    package = pkgs.zulu17;
    binfmt = true;
  };

  # Chaotic gaming packages
  chaotic.nyx = {
    cache.enable = true;
    overlay.enable = true;
  };

  hardware.graphics.enable32Bit = true;

  # System packages for gaming
  environment.systemPackages = with pkgs; [
    # Launchers
    lutris
    bottles
    heroic

    # Minecraft
    atlauncher
    (prismlauncher.override {
      jdks = [zulu8 zulu17 zulu21];
    })

    # Tools
    mangohud
    vkbasalt
    goverlay

    # Performance monitoring
    nvtopPackages.intel

    # Compatibility
    openal
    glfw-wayland-minecraft

    # Vulkan
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
  ];

  # Kernel optimizations for gaming
  boot.kernel.sysctl = lib.mkMerge {
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_mtu_probing" = 1;

    "vm.swappiness" = 10;

    "fs.file-max" = 524288;
    "fs.inotify.max_user_watches" = 524288;
  };

  # Firewall rules for gaming
  networking.firewall = {
    # Minecraft
    allowedTCPPorts = [25565];
    allowedUDPPorts = [25565];
  };
}
