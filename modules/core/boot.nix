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
  # Its expected to be override by CachyOS, if enabled.
  boot.kernelPackages = lib.mkDefault pkgs.linuxKernel.packages.linux_zen;

  # Kernel Params
  boot.kernelParams = [
    "quiet"
    "loglevel=3"

    "pcie_aspm=off"

    "intel_pstate=active"
  ];

  # Plymouth
  boot.plymouth = {
    enable = false;
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
}
