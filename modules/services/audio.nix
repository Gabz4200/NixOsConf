{
  config,
  lib,
  ...
}: let
  cfg = config.services.audio;
in {
  # Audio configuration
  # Moved from modules/features/desktop.nix

  options.services.audio = {
    enable = lib.mkEnableOption "Enable audio configuration and audio-related services";
    unstable = lib.mkEnableOption "Enable unstable audio features and experimental configurations";
  };

  config = lib.mkIf cfg.enable {
    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;

      # Dont know if really needed. But if dont hurting, can let it.
      lowLatency = {
        enable = true;
        # defaults
        quantum = 64;
        rate = 48000;
      };
    };
  };
}
