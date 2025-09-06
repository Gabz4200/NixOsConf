{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.displayManager;
in {
  # Display Manager configuration
  # Moved from modules/features/desktop.nix

  options.services.displayManager = {
    enable = lib.mkEnableOption "Enable display manager configuration and display-related services";
    unstable = lib.mkEnableOption "Enable unstable display manager features and experimental configurations";
  };

  config = lib.mkIf cfg.enable {
    # SDDM (Works great)
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      package = pkgs.kdePackages.sddm;
      extraPackages = [
        pkgs.kdePackages.qtsvg
        pkgs.kdePackages.qtmultimedia
        pkgs.kdePackages.qtvirtualkeyboard
        (pkgs.sddm-astronaut.override {embeddedTheme = "black_hole";})
      ];
      theme = "sddm-astronaut-theme";
    };

    # For some unknow reason, if this is not on systemPackages, the theme simply dont work.
    environment.systemPackages = [
      (pkgs.sddm-astronaut.override {embeddedTheme = "black_hole";})
    ];

    # Unlock GNOME Keyring at login (both SDDM and TTY)
    security.pam.services.sddm.enableGnomeKeyring = true;
    security.pam.services.login.enableGnomeKeyring = true;
  };
}
