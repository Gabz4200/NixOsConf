{
  config,
  pkgs,
  pkgs-stable,
  lib,
  ...
}: let
  cfg = config.features.music;
in {
  options.features.music = {
    enable = lib.mkEnableOption "Enable music production features and audio-related configurations";
    unstable = lib.mkEnableOption "Enable unstable music features and experimental audio configurations";
  };

  # todo: Adress it. Fast.
  # This module should be splited in such a way that
  # the unstable flag uses musnix module (it makes changes on sysctl and etc)
  # and the enable flag with unstable disabled just add the pluginPaths so nothing gets erased if musnix is not used
  # the packages may be added and both cases

  config = lib.mkIf cfg.enable {
    musnix.enable = lib.mkForce true;
    musnix.kernel.realtime = false;

    musnix.soundcardPciId = "00:1f.3";
    musnix.alsaSeq.enable = true;
    musnix.ffado.enable = true;
    musnix.das_watchdog.enable = true;

    # environment.variables = let
    #   makePluginPath = format:
    #     (lib.makeSearchPath format [
    #       "$HOME/.nix-profile/lib"
    #       "/run/current-system/sw/lib"
    #       "/etc/profiles/per-user/$USER/lib"
    #     ])
    #     + ":$HOME/.${format}";
    # in {
    #   DSSI_PATH = makePluginPath "dssi";
    #   LADSPA_PATH = makePluginPath "ladspa";
    #   LV2_PATH = makePluginPath "lv2";
    #   LXVST_PATH = makePluginPath "lxvst";
    #   VST_PATH = makePluginPath "vst";
    #   VST3_PATH = makePluginPath "vst3";
    # };

    environment.systemPackages = with pkgs; [
      dssi
      ladspaPlugins
      lv2
      helm
      vital

      bitwig-studio

      faust
      faust2jack
      faust2lv2
      faust2ladspa
      faust2alsa

      magnetophonDSP.VoiceOfFaust

      pkgs-stable.lmms
      ardour
      tenacity

      openutau

      voicevox-core
      voicevox-engine
      voicevox

      (puredata-with-plugins [
        zexy
        cyclone
        maxlib
        timbreid
      ])
    ];
  };
}
