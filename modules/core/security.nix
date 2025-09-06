{
  config,
  lib,
  ...
}: let
  cfg = config.core.security;
in {
  # System security configurations
  # This module will contain security-related settings

  options.core.security = {
    enable = lib.mkEnableOption "Enable system security configurations and security-related settings";
    unstable = lib.mkEnableOption "Enable unstable security features and experimental configurations";
  };

  config = lib.mkIf cfg.enable {
    # AppArmor
    security.apparmor = {
      enable = true;
      enableCache = true;
      killUnconfinedConfinables = true;
    };

    boot.kernelParams = ["lsm=landlock,lockdown,yama,integrity,apparmor,bpf"];
  };
}
