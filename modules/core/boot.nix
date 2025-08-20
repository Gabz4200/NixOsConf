{
  config,
  lib,
  pkgs,
  ...
}: {
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

  # Kernel modules
  boot.initrd.kernelModules = ["xhci_pci" "ahci" "sd_mod" "sdhci_pci" "i915"];
  boot.initrd.availableKernelModules = ["usb_storage" "usbhid"];
  boot.kernelModules = ["kvm-intel" "coretemp"];

  # Kernel parameters (hardware specific em intel-gpu.nix)
  boot.kernelParams = [
    # Silent boot
    "quiet"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"

    # Performance
    "threadirqs"
    "nmi_watchdog=0" # Salva energia

    # Filesystem
    "rootflags=noatime"
  ];

  # Sysctl
  boot.kernel.sysctl = {
    # Memory
    "vm.swappiness" = 10; # Laptop com SSD
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;

    # Network performance
    "net.core.netdev_max_backlog" = 16384;
    "net.core.somaxconn" = 8192;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_notsent_lowat" = 16384;

    # Security
    "kernel.dmesg_restrict" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.yama.ptrace_scope" = 1;

    # SSD
    "vm.dirty_expire_centisecs" = 3000;
  };

  # Plymouth (boot splash) - opcional
  boot.plymouth = {
    enable = false;
    theme = "breeze";
  };

  # Tmp on tmpfs
  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = ["mode=1777" "size=4G"];
  };

  # Zram
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

  # Kernel compression
  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = ["-19" "-T0"];

  # Preload modules
  boot.initrd.preDeviceCommands = ''
    modprobe -q tcp_bbr || true
    modprobe -q i915 || true
  '';

  # Support for additional filesystems
  boot.supportedFilesystems = [
    "btrfs"
    "ntfs"
    "vfat"
    "exfat"
  ];

  # BTRFS specific
  boot.initrd.supportedFilesystems = ["btrfs"];

  # Hardware and Firmware
  hardware = {
    enableAllFirmware = true;
    enableAllHardware = true;
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  services.fwupd.enable = true;

  # CPU microcode updates (em intel-gpu.nix)

  # Watchdog
  systemd.watchdog = {
    runtimeTime = "30s";
    rebootTime = "10min";
    kexecTime = "10min";
  };
}
