{
  config,
  pkgs,
  pkgs-stable,
  inputs,
  lib,
  ...
}: {
  # Managing two config frameworks is messy. How should I adress the problems?

  # Catppuccin Mocha
  catppuccin.enable = true;
  catppuccin.flavor = "mocha";
  catppuccin.accent = "pink";
  catppuccin.cache.enable = true;

  # The stylix theme for this was hard to see, dark when shouldnt be.
  catppuccin.zsh-syntax-highlighting.enable = true;

  # All the ones set to false were broken or ugly. Vscode is just a no no for custom.
  catppuccin.kvantum.enable = false;
  catppuccin.kvantum.apply = false;
  catppuccin.vscode.profiles.default.enable = false;
  catppuccin.fuzzel.enable = false;

  gtk.iconTheme.package = lib.mkForce config.stylix.icons.package;
  gtk.iconTheme.name = lib.mkForce config.stylix.icons.dark;

  # Stylix
  stylix.enable = true;
  stylix.icons.enable = true;

  # I would want it enabled. But some themes are not that great (Namely the zsh-syntax-highlighting),
  # so I use it together with catppuccin.nix flake. Dont know how to make it suck less.
  # I think the main problem are
  # # 1- Only 16 colors aint enough for everything.
  # # 2- The catppuccin one may have them ordered in a weird way that makes thing that should be bright, be dark.
  stylix.autoEnable = false;

  stylix.icons.package = pkgs.colloid-icon-theme.override {
    schemeVariants = ["catppuccin"];
    colorVariants = ["pink"];
  };
  stylix.icons.dark = "Colloid-Pink-Catppuccin-Dark";
  stylix.icons.light = "Colloid-Pink-Catppuccin-Light";

  # I theme Vscode with extensions, for better syntax highlighting.
  stylix.targets.vscode.enable = false;

  stylix.targets.gtk.enable = true;
  stylix.targets.qt.enable = true;
  stylix.targets.fuzzel.enable = true;
  stylix.targets.kde.enable = true;
  stylix.targets.nixos-icons.enable = true;

  #todo: Make Colloid-Gtk-Theme be used directly instead of using Stylix to it, but without conflicting with Stylix.
  stylix.targets.gtk.extraCss = "@import ${pkgs.colloid-gtk-theme.override {
    themeVariants = ["pink"];
    colorVariants = ["dark"];
    tweaks = ["catppuccin" "black" "normal"];
  }}/share/themes/Colloid-Pink-Dark-Catppuccin/gtk-3.0/gtk-dark.css";

  stylix.targets.gnome.enable = true;
  stylix.targets.gnome-text-editor.enable = true;

  services.swww.enable = true;

  # Needed?
  services.swww.extraArgs = ["--layer" "bottom"];

  # Qt and GTK
  qt.enable = true;

  gtk.enable = true;

  gtk.gtk4.enable = true;
  gtk.gtk3.enable = true;
  gtk.gtk2.enable = true;

  stylix.targets.gtk.flatpakSupport.enable = lib.mkForce true;

  # Fonts need to be here on home-manager or Waybar and fuzzel suddenly break
  home.packages = with pkgs; [
    # Nerd Fonts
    nerd-fonts.caskaydia-mono
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only

    # System fonts
    liberation_ttf
    dejavu_fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji

    # Icons
    font-awesome
    material-design-icons

    # GTK
    gtk-engine-murrine
    colloid-icon-theme
    (colloid-icon-theme.override {
      schemeVariants = ["catppuccin"];
      colorVariants = ["pink"];
    })
    (pkgs.colloid-gtk-theme.override {
      themeVariants = ["pink"];
      colorVariants = ["dark"];
      tweaks = ["catppuccin" "black" "normal"];
    })
  ];

  # set cursor size and dpi for 1920x1080 monitor
  xresources.properties = {
    "Xcursor.size" = 24;
    "Xft.dpi" = 140;
  };
}
