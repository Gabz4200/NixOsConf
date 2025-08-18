{
  pkgs,
  config,
  ...
}: let
  srt_equalizer =
    pkgs.python3Packages.buildPythonPackage
    rec {
      pname = "srt_equalizer";
      version = "0.1.10";
      pyproject = true;

      src = pkgs.fetchPypi {
        inherit pname version;
        sha256 = "sha256-X2sbLEixK7HKqxOCLX3dClSod3K4JKCqK6ZMAz03k1M=";
      };
      doCheck = false;
      nativeBuildInputs = [
        pkgs.python3Packages.poetry-core
      ];
      propagatedBuildInputs = [
        pkgs.python3Packages.srt
      ];
    };
in {
  home.packages = with pkgs; [
    kdePackages.kdenlive
    kdePackages.breeze
    (python3.withPackages (python-pkgs:
      with python-pkgs; [
        pip
        openai-whisper
        srt
        srt_equalizer
        torch
      ]))
  ];
}
