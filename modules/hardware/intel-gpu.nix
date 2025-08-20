{
  config,
  lib,
  pkgs,
  ...
}: {
  # Kernel parameters for Kaby Lake (i5-8250U)
  boot.kernelParams = [
    # GuC/HuC firmware loading
    "i915.enable_guc=0" # Habilita GuC e HuC
    "i915.enable_fbc=1" # Frame buffer compression
    "i915.enable_psr=2" # Panel self refresh v2
    "i915.fastboot=1" # Fastboot para Intel

    # Performance
    "intel_pstate=active"
    "intel_idle.max_cstate=7" # C-states até C7 para economia
    "pcie_aspm=off"

    # Mitigações de segurança (balanceado)
    "mitigations=auto"
  ];

  # Intel
  hardware.intel-gpu-tools.enable = true;

  # Microcode updates
  hardware.cpu.intel.updateMicrocode = true;

  # Graphics stack
  hardware.graphics = {
    enable = true;
    enable32Bit = lib.mkDefault true;

    # Use Mesa estável por padrão
    package = pkgs.mesa;
    package32 = pkgs.driversi686Linux.mesa;

    extraPackages = with pkgs; [
      # OpenCL (CRÍTICO para Davinci Resolve)
      intel-compute-runtime # Neo OpenCL runtime
      ocl-icd # OpenCL ICD loader

      # Video acceleration
      intel-media-driver # VA-API (modern)
      vaapiIntel # VA-API (legacy fallback)
      libvdpau-va-gl # VDPAU via VA-API

      # Vulkan
      vulkan-loader
      vulkan-validation-layers

      # Intel specific
      intel-gmmlib
      intel-graphics-compiler

      # VPL for newer Intel media SDK
      vpl-gpu-rt
      onevpl-intel-gpu
    ];

    extraPackages32 = with pkgs.driversi686Linux; [
      intel-media-driver
      vaapiIntel
      ocl-icd
    ];
  };

  # Environment para OpenCL funcionar corretamente
  environment.variables = {
    # OpenCL
    OCL_ICD_VENDORS = "${pkgs.intel-compute-runtime}/etc/OpenCL/vendors";
    LIBVA_DRIVER_NAME = "iHD"; # Use intel-media-driver

    # Vulkan
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";

    # Performance hints
    INTEL_DEBUG = lib.mkDefault "";
    MESA_LOADER_DRIVER_OVERRIDE = lib.mkDefault "";

    # DPI
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  };

  # Intel GPU tools para debugging
  environment.systemPackages = with pkgs; [
    intel-gpu-tools
    libva-utils
    vdpauinfo
    vulkan-tools
    clinfo # Para verificar OpenCL
  ];

  # Kernel modules
  boot.kernelModules = [
    "i915"
    "intel_agp"
  ];

  boot.initrd.kernelModules = ["i915"];

  # Early KMS
  boot.initrd.availableKernelModules = [
    "i915"
  ];

  # DPI
  services.xserver = {
    enable = true;
    dpi = 141.21;
  };

  # Font config
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
  fonts.fontconfig = {
    hinting = {
      enable = true;
      style = "hintfull";
      autohint = true;
    };
    antialias = true;
    subpixel = {
      rgba = "rgb";
      lcdfilter = "default";
    };
  };
}
