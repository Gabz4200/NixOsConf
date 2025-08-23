{ config, pkgs, lib, ... }:

{
  # Display Manager configuration
  # Moved from modules/features/desktop.nix

  # SDDM (Works great)
  services.displayManager.sddm = {
    wayland.enable = true;
    package = pkgs.kdePackages.sddm;
    enable = true;
    extraPackages = [
      pkgs.kdePackages.qtsvg
      pkgs.kdePackages.qtmultimedia
      pkgs.kdePackages.qtvirtualkeyboard
      (pkgs.sddm-astronaut.override {embeddedTheme = "black_hole";})
    ];
    theme = "sddm-astronaut-theme";
  };
}
