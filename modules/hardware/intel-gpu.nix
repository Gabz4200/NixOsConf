{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.initrd.availableKernelModules = ["i915"];

  boot.kernelModules = ["i915" "intel_agp" "coretemp" "kvm-intel"];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.graphics.package = pkgs.mesa;
  hardware.graphics.package32 = pkgs.driversi686Linux.mesa;
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-ocl
    intel-vaapi-driver
    libva
  ];

  boot.kernelParams = [
    "quiet"
    "loglevel=3"

    "intel_pstate=active"
    "threadirqs"
  ];

  environment.etc."modprobe.d/i915.conf".text = lib.optionalString true ''
    options i915 enable_guc=0
    options i915 enable_psr=0
    # options i915 enable_fbc=1 # habilite somente se souber que funciona no seu HW
  '';

  services.xserver = {
    enable = true;
    dpi = 142;
  };
}
