{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: {
  # Network configuration
  # This module contains network-related settings

  networking.useNetworkd = lib.mkForce false;
  networking.networkmanager.enable = lib.mkForce true;
  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";

  networking.useDHCP = lib.mkDefault true;

  programs.nm-applet.enable = true;

  # Firewall. Great?
  networking.firewall.enable = true;
  networking.firewall.allowPing = false;
  networking.nftables.enable = true;

  networking.firewall.allowedTCPPorts = [];
  networking.firewall.allowedUDPPorts = [];

  networking.enableIPv6 = true;

  # Fix my WiFI connection:
  boot.blacklistedKernelModules = ["rtw88_8821ce"];
  boot.kernelModules = ["8821ce"];
  boot.extraModulePackages = [
    (config.boot.kernelPackages.rtl8821ce.overrideAttrs (finalAttrs: previousAttrs: {
      src = inputs.rtl8821ce-src;
      meta.broken = false;
    }))
  ];
}
