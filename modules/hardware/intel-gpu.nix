{
  config,
  lib,
  pkgs,
  ...
}: {
  # Is a Intel Core i5-8250U and Intel UHD Graphics 620

  # Is this correct? I have no Idea if the drivers are the expected for my Hardware or not.
  # Do I need any further configuration to use Vulkan and etc?
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # Modern VA-API driver
      intel-vaapi-driver # Older VA-API driver, for compatibility
      intel-compute-runtime # OpenCL support
      vulkan-loader
      vulkan-tools
      libvdpau-va-gl # VDPAU backend for VA-API
      libva
    ];
    extraPackages32 = with pkgs.driversi686Linux; [
      intel-media-driver
    ];
  };

  # Using boot.extraModprobeConfig
  boot.extraModprobeConfig = ''
    options i915 enable_guc=0
    options i915 enable_fbc=1
    options i915 enable_psr=0
    options i915 fastboot=1
  '';
}
