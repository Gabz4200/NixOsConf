{
  config,
  lib,
  pkgs,
  ...
}: {
  # Is a Intel Core i5-8250U and Intel UHD Graphics 620

  # Is it really needed?
  boot.initrd.availableKernelModules = ["i915"];
  boot.kernelModules = ["i915" "intel_agp" "coretemp" "kvm-intel"];

  # Is this correct? I have no Idea if the drivers are the expected for my Hardware or not.
  # Do I need any further configuration to use Vulkan and etc?
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    package = pkgs.mesa;
    package32 = pkgs.driversi686Linux.mesa;
    extraPackages = with pkgs; [
      intel-media-driver
      ocl-icd
      intel-ocl
      intel-vaapi-driver
      libvdpau-va-gl
      libva
    ];
  };

  # I have this param set in many files. Will it correctly merge?
  # I also am not sure about the params. Only pcie_aspm=off is something I know for sure.
  boot.kernelParams = [
    "quiet"
    "loglevel=3"

    "pcie_aspm=off"

    "intel_pstate=active"
    "threadirqs"
  ];

  # Is it the best way to use this option tho?
  environment.etc."modprobe.d/i915.conf".text = lib.optionalString true ''
    options i915 enable_guc=0
    options i915 enable_psr=0
    # options i915 enable_fbc=1 # habilite somente se souber que funciona no seu HW
  '';

  services.xserver = {
    enable = true;
    dpi = 140;
  };
}
