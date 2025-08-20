{
  config,
  lib,
  pkgs,
  ...
}: {
  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "schedutil";
  };

  services.tlp = {
    enable = lib.mkForce false;
  };

  # Auto-cpufreq
  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        energy_performance_preference = "balance_performance";
        scaling_min_freq = 800000;
        scaling_max_freq = 3400000; # i5-8250U max turbo
        turbo = "auto";
      };

      battery = {
        governor = "powersave";
        energy_performance_preference = "balance_power";
        scaling_min_freq = 800000;
        scaling_max_freq = 2000000; # Limite mais realista
        turbo = "auto";
      };
    };
  };

  # Desabilitar power-profiles-daemon
  services.power-profiles-daemon.enable = lib.mkForce false;

  # Thermald para controle térmico Intel
  services.thermald = {
    enable = true;
    configFile = pkgs.writeText "thermald-config.xml" ''
      <?xml version="1.0"?>
      <ThermalConfiguration>
        <Platform>
          <Name>ASUS VivoBook</Name>
          <ProductName>X540UAR</ProductName>
          <ThermalZones>
            <ThermalZone>
              <Type>auto</Type>
              <TripPoints>
                <TripPoint>
                  <Temperature>85000</Temperature>
                  <Type>passive</Type>
                </TripPoint>
                <TripPoint>
                  <Temperature>95000</Temperature>
                  <Type>critical</Type>
                </TripPoint>
              </TripPoints>
            </ThermalZone>
          </ThermalZones>
        </Platform>
      </ThermalConfiguration>
    '';
  };

  # Undervolt
  services.undervolt = {
    enable = true;

    # Safe
    coreOffset = -50;
    gpuOffset = -30;
    uncoreOffset = -50;
    analogioOffset = -30;

    # Thermal limits
    tempAc = 95;
    tempBat = 85;

    # Power limits (PL1/PL2)
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
    enable = true;
    lidSwitch = "suspend";
    powerKey = "hibernate";
  };

  # Suspend/Hibernate
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
    criticalPowerAction = "hibernate";
  };

  # Power monitoring tools
  environment.systemPackages = with pkgs; [
    powertop
    s-tui
    stress
    intel-gpu-tools
    turbostat
  ];
}
