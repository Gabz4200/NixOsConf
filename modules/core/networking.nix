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
  networking.networkmanager.dns = "systemd-resolved";

  # Single source of truth for DNS: systemd-resolved with DoT/DNSSEC
  services.resolved = {
    enable = true;
    dnssec = "true";
    dnsovertls = "true";
    fallbackDns = [
      "2606:4700:4700::1111"
      "1.1.1.1"
      "2606:4700:4700::1001"
      "1.0.0.1"
      "2001:4860:4860::8888"
      "8.8.8.8"
      "2001:4860:4860::8844"
      "8.8.4.4"
    ];
  };

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
    config.boot.kernelPackages.rtl8821ce
    # (config.boot.kernelPackages.rtl8821ce.overrideAttrs (finalAttrs: previousAttrs: {
    #   src = inputs.rtl8821ce-src;
    #   meta.broken = false;
    # }))
  ];
}
