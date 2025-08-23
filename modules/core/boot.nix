{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}: {
  # I am not sure about ANYTHING here. I need help.

  # Bootloader
  boot.loader = {
    # Systemd-boot (UEFI)
    systemd-boot = {
      enable = true;
      editor = false;
      consoleMode = "max";
      configurationLimit = 10;

      # Entry naming
      memtest86.enable = true;
      netbootxyz.enable = false;
    };

    # EFI
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    # Timeout
    timeout = 10;
  };

  # Kernel
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  # Fix my WiFI connection:
  boot.blacklistedKernelModules = ["rtw88_8821ce"];
  boot.extraModulePackages = [
    (config.boot.kernelPackages.rtl8821ce.overrideAttrs (finalAttrs: previousAttrs: {
      src = inputs.rtl8821ce-src;
      meta.broken = false;
    }))
  ];

  # Kernel modules (Need? Really? Only sure about "8821ce")
  boot.initrd.kernelModules = ["xhci_pci" "ahci" "sd_mod" "sdhci_pci" "i915"];
  boot.initrd.availableKernelModules = ["usb_storage" "usbhid"];
  boot.kernelModules = ["kvm-intel" "coretemp" "8821ce"];

  # Kernel parameters
  # Are they great? Will them correctly merge?
  boot.kernelParams = [
    # Silent boot
    "quiet"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"

    "pcie_aspm=off"

    # Performance
    "threadirqs"
    "nmi_watchdog=0" # Salva energia

    # Filesystem
    "rootflags=noatime"
  ];

  # Sysctl
  # Are they great? Will them correctly merge?
  boot.kernel.sysctl = {
    # Memory
    "vm.swappiness" = lib.mkDefault 10; # Laptop com SSD
    "vm.vfs_cache_pressure" = lib.mkDefault 50;
    "vm.dirty_background_ratio" = lib.mkDefault 5;
    "vm.dirty_ratio" = lib.mkDefault 10;

    # Network performance
    "net.core.netdev_max_backlog" = lib.mkDefault 16384;
    "net.core.somaxconn" = lib.mkDefault 8192;
    "net.ipv4.tcp_fastopen" = lib.mkDefault 3;
    "net.ipv4.tcp_congestion_control" = lib.mkDefault "bbr";
    "net.ipv4.tcp_notsent_lowat" = lib.mkDefault 16384;

    # Will these conflict with NixOS defauts?
    # Security
    /*
    "kernel.dmesg_restrict" = lib.mkDefault 1;
     "kernel.kptr_restrict" = lib.mkDefault 2;
     "kernel.yama.ptrace_scope" = lib.mkDefault 1;
    */

    # SSD
    "vm.dirty_expire_centisecs" = lib.mkDefault 3000;
  };

  # Plymouth (boot splash) - optional
  boot.plymouth = {
    enable = false;
    theme = "breeze";
  };

  # Tmp on tmpfs. Do I need it? Will it take much space?
  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = ["mode=1777" "size=4G"];
  };

  # Zram. Needed in my humble 8 Gb Ram machine.
  zramSwap = {
    enable = true;
    priority = 200;
    memoryPercent = 75;
    algorithm = "zstd";
  };

  # Preload
  services.preload.enable = true;

  # Console
  boot.consoleLogLevel = 3;

  # Kernel compression (need?)
  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = ["-19" "-T0"];

  # Preload modules (need?)
  boot.initrd.preDeviceCommands = ''
    modprobe -q tcp_bbr || true
    modprobe -q i915 || true
  '';

  # Support for additional filesystems (need?)
  boot.supportedFilesystems = [
    "btrfs"
    "ntfs"
    "vfat"
    "exfat"
  ];

  # BTRFS specific (need?)
  boot.initrd.supportedFilesystems = ["btrfs"];

  # Hardware and Firmware
  hardware = {
    enableAllFirmware = true;
    enableAllHardware = true;
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  services.fwupd.enable = true;

  # Watchdog (need? maybe remove?)
  systemd.settings.Manager = {
    KExecWatchdogSec = "10min";
    RebootWatchdogSec = "10min";
    RuntimeWatchdogSec = "30s";
  };
}
