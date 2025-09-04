{
  config,
  pkgs,
  lib,
  ...
}: {
  # Audio configuration
  # Moved from modules/features/desktop.nix

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
}
