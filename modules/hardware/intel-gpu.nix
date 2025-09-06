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
    enable = lib.mkEnableOption "Enable Intel GPU configuration and Intel graphics-related settings";
    unstable = lib.mkEnableOption "Enable unstable Intel GPU features and experimental configurations";
    enablePSR = lib.mkEnableOption "Enable Panel Self Refresh (PSR) for i915. Can improve battery life; disable if you observe flicker.";
    enableGuC = lib.mkOption {
      type = lib.types.enum [0 1 2];
      default = 0;
      description = ''i915 GuC submission: 0=disabled, 1=enable, 2=enable GuC/HuC. Try 2 for power/perf; revert if issues.'';
    };
  };

  config = lib.mkIf cfg.enable {
    # todo: Adress it
    # Is this correct? I have no Idea if the drivers are the expected for my Hardware or not. it is a Intel UHD 620 (8th Gen)
    # Do I need any further configuration to use Vulkan and etc?
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        #todo: intel-compute-runtime # OpenCL support
        intel-ocl
        vulkan-loader
        vulkan-tools
        libvdpau-va-gl
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
