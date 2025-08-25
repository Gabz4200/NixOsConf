{
  config,
  pkgs,
  lib,
  ...
}: {
  # System security configurations
  # This module will contain security-related settings

  # AppArmor
  security.apparmor = {
    enable = true;
    enableCache = true;
    killUnconfinedConfinables = true;
  };

  boot.kernelParams = ["lsm=landlock,lockdown,yama,integrity,apparmor,bpf"];
}
