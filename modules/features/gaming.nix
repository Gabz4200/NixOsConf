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
    binfmt = true;
    ntsync = true;
  };

  # Gamemode
  programs.gamemode = {
    enable = true;
    enableRenice = true;

    settings = {
      general = {
        renice = 10;
        ioprio = 0;
      };

      # Intel GPU optimizations
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high"; # Ignorado para Intel
      };

      # CPU governor
      cpu = {
        park_cores = "no";
        pin_cores = "yes";
      };

      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'Optimizations activated'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'Optimizations deactivated'";
      };
    };
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
  boot.kernel.sysctl = {
    # Network latency
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_mtu_probing" = 1;

    # Memory
    #"vm.max_map_count" = 2147483642; # For some games
    "vm.swappiness" = 10;

    # File watchers for some games
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
