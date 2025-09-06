{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.features.virtualization;
in {
  # Virtualization support
  # Moved from modules/features/development.nix

  options.features.virtualization = {
    enable = lib.mkEnableOption "Enable virtualization support and container-related configurations";
    unstable = lib.mkEnableOption "Enable unstable virtualization features and experimental configurations";
  };

  config = lib.mkIf cfg.enable {
    # Podman
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;

      # Auto cleanup
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = ["--all"];
      };

      # Default network
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };

    # KVM/QEMU
    virtualisation.libvirtd = {
      enable = true;
      # todo: Adress it
      # Qemu is needed or goodbye? I keep libvirtd here for a fast VM if needed, not using it often
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [pkgs.OVMFFull.fd];
        };
      };
    };

    # Waydroid (Android container)
    virtualisation.waydroid.enable = true;
  };
}
