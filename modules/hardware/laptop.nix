{
  config,
  pkgs,
  lib,
  ...
}: {
  # Laptop-specific hardware configurations
  # This module contains settings specific to laptop hardware
  # Is a ASUS VivoBook 15 (X540UAR)

  # CPU microcode updates for Intel CPUs
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Platform settings
  # nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Boot modules for laptop hardware
  # boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci"];
  # boot.kernelModules = ["kvm-intel"];
  # boot.extraModulePackages = [];

  # File systems configuration with Btrfs optimizations
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c5627d10-2763-4f71-a4bb-4d55d9ad1354";
    fsType = "btrfs";
    options = ["subvol=@" "defaults" "ssd" "noatime" "discard=async" "compress=zstd:10"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2AA3-26F2";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  # Swap configuration
  swapDevices = [
    {
      device = "/dev/disk/by-uuid/7ce2c6e6-3966-48e3-a2b5-9e2a266beb9b";
      priority = 10; # Low priority so Zram is preferred
    }
  ];
}
