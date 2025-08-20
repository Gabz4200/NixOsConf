{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.initrd.availableKernelModules = ["i915"];

  boot.kernelModules = ["i915" "intel_agp" "coretemp" "kvm-intel"];

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
