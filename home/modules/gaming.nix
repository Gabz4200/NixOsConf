{pkgs, ...}: {
  # Gaming-related configurations and packages (user scope)

  # Prefer options over plain packages where available
  programs.lutris.enable = true;

  # Java for Minecraft and other launchers (moved from system)
  programs.java = {
    enable = true;
    package = pkgs.zulu17;
  };

  # User-facing gaming apps and tools
  home.packages = with pkgs; [
    # Launchers
    heroic
    (prismlauncher.override {jdks = [zulu8 zulu17 zulu21];})

    # Tools / overlays
    mangohud
    vkbasalt
    goverlay

    # Monitoring
    nvtopPackages.intel

    # Compatibility bits used by some games
    openal
    glfw-wayland-minecraft

    # Vulkan utilities
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
  ];
}
