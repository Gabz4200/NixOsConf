{
  config,
  pkgs,
  lib,
  ...
}: {
  # Virtualization support
  # Moved from modules/features/development.nix

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
}
