{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}: {
  # Bootloader, Kernel, and System Performance Settings

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
    timeout = 5;
  };

  # Kernel
  # The Zen kernel is a great choice for desktop performance.
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  # Fix my WiFI connection:
  boot.blacklistedKernelModules = ["rtw88_8821ce" "iTCO_wdt" "iTCO_vendor_support"];
  boot.extraModulePackages = [
    (config.boot.kernelPackages.rtl8821ce.overrideAttrs (finalAttrs: previousAttrs: {
      src = inputs.rtl8821ce-src;
      meta.broken = false;
    }))
  ];

  # Consolidated Kernel Modules
  # All modules are now managed here to avoid conflicts.
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" "i915"];
  boot.kernelModules = ["kvm-intel" "coretemp" "8821ce"];

  # Consolidated & Optimized Kernel Parameters
  # These are merged from all my old files and new ones added for performance.
  boot.kernelParams = [
    # Boot verbosity
    "quiet"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"

    # Power Management
    # pcie_aspm=off disables PCIe power saving. It can fix instability on some
    # devices but increases power consumption. Kept because wifi.
    "pcie_aspm=off"

    # Performance & Scheduling
    "threadirqs"
    "intel_pstate=active"
    "nmi_watchdog=0" # Saves a bit of power
    "mitigations=off" # Disables CPU mitigations for max performance. Re-enable if I decide I need higher security.
    "nowatchdog" # Disables another watchdog timer

    # Filesystem
    "rootflags=noatime"
  ];

  # Sysctl Optimizations (aligned with CachyOS where applicable)
  boot.kernel.sysctl = {
    # Memory Management
    "vm.swappiness" = lib.mkForce 100;
    "vm.vfs_cache_pressure" = lib.mkForce 50;
    # Use absolute byte thresholds instead of ratios
    "vm.dirty_background_bytes" = lib.mkForce 67108864; # 64 MB
    "vm.dirty_bytes" = lib.mkForce 268435456; # 256 MB
    "vm.dirty_writeback_centisecs" = lib.mkForce 1500; # 15s
    "vm.page-cluster" = lib.mkForce 0; # Prefer smaller swap readahead

    # Network Performance
    "net.core.netdev_max_backlog" = lib.mkForce 4096;
    "net.core.somaxconn" = lib.mkDefault 8192;
    "net.core.default_qdisc" = "fq_codel";
    "net.ipv4.tcp_fastopen" = lib.mkDefault 3;
    "net.ipv4.tcp_congestion_control" = lib.mkDefault "bbr";

    # Security and kernel behavior
    "kernel.printk" = lib.mkForce "3 3 3 3"; # Quiet console
    "kernel.dmesg_restrict" = lib.mkDefault 1;
    "kernel.kptr_restrict" = lib.mkForce 2; # More strict
    "kernel.yama.ptrace_scope" = lib.mkDefault 1;
    "kernel.kexec_load_disabled" = lib.mkForce 1;
    "kernel.unprivileged_userns_clone" = lib.mkForce 1;

    # File handles/inodes cache
    "fs.file-max" = lib.mkForce 2097152;
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
    options = ["defaults" "nosuid" "nodev" "mode=1777" "size=4G"];
  };

  # Zram. Needed in my humble 8 Gb Ram machine.
  zramSwap = {
    enable = true;
    priority = 100; # High priority to be used before disk swap
    memoryPercent = 75;
    algorithm = "zstd";
  };

  # Preload - helps with app startup times
  services.preload.enable = true;

  # Console
  boot.consoleLogLevel = 3;

  # Kernel compression (need?)
  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = ["-19" "-T0"];

  # Preload modules (need?) -> This can slightly speed up boot.
  boot.initrd.preDeviceCommands = ''
    modprobe -q tcp_bbr
  '';

  # Support for additional filesystems (need?) -> Good to have for external drives.
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

  # fwupd is enabled in `modules/core/system.nix` to centralize services configuration.

  # Watchdog (need? maybe remove?) -> Can be disabled if you don't experience system freezes.
  # For now, let's keep it but with relaxed timings.
  systemd.settings.Manager = {
    # KExecWatchdogSec = "10min";
    RebootWatchdogSec = "10min";
    RuntimeWatchdogSec = "5min";
  };
}
