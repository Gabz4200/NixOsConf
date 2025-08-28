{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hardware.intelGPU;
in {
  # Is a Intel Core i5-8250U and Intel UHD Graphics 620

  options.hardware.intelGPU = {
    enablePSR = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''Enable Panel Self Refresh (PSR) for i915. Can improve battery life; disable if you observe flicker.'';
    };
    enableGuC = lib.mkOption {
      type = lib.types.enum [0 1 2];
      default = 0;
      description = ''i915 GuC submission: 0=disabled, 1=enable, 2=enable GuC/HuC. Try 2 for power/perf; revert if issues.'';
    };
  };

  config = {
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

    # Using boot.extraModprobeConfig (now parameterized)
    boot.extraModprobeConfig = ''
      options i915 enable_guc=${toString cfg.enableGuC}
      options i915 enable_fbc=1
      options i915 enable_psr=${
        if cfg.enablePSR
        then "1"
        else "0"
      }
      options i915 fastboot=1
    '';
  };
}
