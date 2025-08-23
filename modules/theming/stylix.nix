{ config, pkgs, lib, ... }:

{
  # Styling and theming with Stylix
  # Moved from modules/features/desktop.nix

  # Stylix (aka. theming)
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    image = ../features/wallpaper.jpg;
    polarity = "dark";
    fonts = {
      serif = {
        package = pkgs.nerd-fonts.caskaydia-cove;
        name = "CaskaydiaCove Nerd Font";
      };

      sansSerif = {
        package = pkgs.nerd-fonts.dejavu-sans-mono;
        name = "DejaVuSansMono Nerd Font";
      };

      monospace = {
        package = pkgs.nerd-fonts.caskaydia-mono;
        name = "CaskaydiaMono Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
    cursor.package = pkgs.bibata-cursors;
    cursor.name = "Bibata-Modern-Ice";
    cursor.size = 24;

    # I would want it enabled. But some themes are not that great (mainly the zsh-syntax-highlighting),
    # so I use it together with catppuccin.nix flake. Dont know how to make it suck less.
    # I think the main problem are
    # # 1- Only 16 colors aint enough for everything.
    # # 2- The catppuccin one may have them ordered in a weird way that makes thing that should be bright, be dark.
    autoEnable = false;

    homeManagerIntegration.autoImport = true;
    homeManagerIntegration.followSystem = true;
  };

  # Fonts (font-awesome and dejavu_fonts need to be here so )
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-mono
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.jetbrains-mono
    font-awesome
    dejavu_fonts
    nerd-fonts.symbols-only
  ];
}
