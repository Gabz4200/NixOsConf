# WARN: this file will get overwritten by $ cachix use <name>
{
  pkgs,
  lib,
  ...
}: let
  folder = ./cachix;
  toImport = name: value: folder + ("/" + name);
  filterCaches = key: value: value == "regular" && lib.hasSuffix ".nix" key;
  imports = lib.mapAttrsToList toImport (lib.filterAttrs filterCaches (builtins.readDir folder));
in {
  inherit imports;
  # Ensure the official cache stays present but do NOT override others
  nix.settings.substituters = lib.mkAfter [
    "https://cache.nixos.org"
  ];
}
