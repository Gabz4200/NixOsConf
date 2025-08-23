{ config, pkgs, lib, ... }:

{
  # Network configuration
  # This module contains network-related settings
  
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s20f0u2.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  # Firewall. Great?
  networking.firewall.enable = true;
  networking.firewall.allowPing = false;
  networking.nftables.enable = true;

  networking.firewall.allowedTCPPorts = [];
  networking.firewall.allowedUDPPorts = [];

  networking.enableIPv6 = true;
}
