{
  config,
  pkgs,
  pkgs-stable,
  inputs,
  lib,
  ...
}: {
  # Catppuccin Mocha
  catppuccin.enable = true;
  catppuccin.flavor = "mocha";
  catppuccin.accent = "pink";
  catppuccin.cache.enable = true;

  catppuccin.zsh-syntax-highlighting.enable = true;

  catppuccin.kvantum.enable = false;
  catppuccin.kvantum.apply = false;
  catppuccin.vscode.profiles.default.enable = false;
  catppuccin.fuzzel.enable = false;

  gtk.iconTheme.package = lib.mkForce pkgs.papirus-icon-theme;

  # Stylix
  stylix.enable = true;
  stylix.icons.enable = true;

  stylix.autoEnable = false;

  stylix.icons.package = pkgs.papirus-icon-theme;
  stylix.icons.dark = "Papirus-Dark";
  stylix.icons.light = "Papirus-Light";

  stylix.targets.vscode.enable = false;

  stylix.targets.gtk.enable = true;
  stylix.targets.qt.enable = true;
  stylix.targets.fuzzel.enable = true;

  stylix.targets.gnome.enable = true;

  services.swww.enable = true;
  services.swww.extraArgs = ["--layer" "bottom"];

  qt.enable = true;

  gtk.enable = true;

  gtk.gtk4.enable = true;
  gtk.gtk3.enable = true;
  gtk.gtk2.enable = true;

  # set cursor size and dpi for 1920x1080 monitor
  xresources.properties = {
    "Xcursor.size" = 24;
    "Xft.dpi" = 141.21;
  };
}
