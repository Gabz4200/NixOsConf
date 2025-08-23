{
  config,
  lib,
  pkgs,
  ...
}: {
  # Power management (It is needed for Hibernate)
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "schedutil";
  };

  services.tlp = {
    enable = lib.mkForce false;
  };

  # Auto-cpufreq (I am used to it.)
  services.auto-cpufreq = {
    enable = lib.mkForce true;
    settings = {
      charger = {
        governor = "performance";
        energy_performance_preference = "balance_performance";
        scaling_min_freq = 800000;
        scaling_max_freq = 3400000;
        turbo = "auto";
      };

      battery = {
        governor = "powersave";
        energy_performance_preference = "balance_power";
        scaling_min_freq = 800000;
        scaling_max_freq = 2000000;
        turbo = "auto";
      };
    };
  };

  # Desabilitar power-profiles-daemon (It conflicts with auto-cpufreq)
  services.power-profiles-daemon.enable = lib.mkForce false;

  # Thermald (It conflicts with Undervolt)
  services.thermald.enable = false;

  # Undervolt (My laptop was overheating, this helped a lot to reduce it and the early throttling)
  services.undervolt = {
    enable = true;

    # Works greats
    coreOffset = -60;
    gpuOffset = -30;
    uncoreOffset = -60;
    analogioOffset = -30;

    # Thermal limits
    tempAc = 95;
    tempBat = 85;

    # Power limits (PL1/PL2)
    # Is this good?
    p1 = {
      limit = 25;
      window = 28;
    };
    p2 = {
      limit = 35;
      window = 1;
    };
  };

  # ACPI event handling
  services.acpid.enable = true;
  services.logind = {
    lidSwitch = "suspend";
    powerKey = "hibernate";
  };

  # Suspend/Hibernate. Is this correct?
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30min
    SuspendState=mem
    HibernateState=disk
    HybridSleepState=disk
  '';

  # Battery management
  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 5;
    percentageAction = 3;
    criticalPowerAction = "Hibernate";
  };

  # Power monitoring tools
  environment.systemPackages = with pkgs; [
    powertop
    s-tui
    stress
    intel-gpu-tools
  ];
}
