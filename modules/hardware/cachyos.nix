{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.features.cachyos;
in {
  # Copying CachyOS optimizations and features that I got used to

  options.features.cachyos = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''Enable CachyOS kernel and sysctl/udev tweaks. Default off to avoid risky defaults.'';
    };
    unstable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''Enable the most unstable features of CachyOS.'';
    };
  };

  config = lib.mkIf cfg.enable {
    # Use CachyOS Kernel from Chaotic-Nyx
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_cachyos;

    # CachyOS sysctl rules
    boot.kernel.sysctl = {
      "vm.swappiness" = lib.mkIf cfg.unstable lib.mkForce 80;

      "vm.vfs_cache_pressure" = 50;

      "vm.dirty_bytes" = 268435456; # 256 MB
      "vm.dirty_background_bytes" = 67108864; # 64 MB

      "vm.page-cluster" = 0;

      "vm.dirty_writeback_centisecs" = 1500;

      # "kernel.nmi_watchdog" = 0;

      "kernel.unprivileged_userns_clone" = 1;

      "kernel.printk" = "3 3 3 3";

      "kernel.kptr_restrict" = 2;

      "kernel.kexec_load_disabled" = 1;

      "net.core.netdev_max_backlog" = 4096;

      "fs.file-max" = 2097152;

      "kernel.sched_rt_runtime_us" = lib.mkIf cfg.unstable lib.mkForce 950000;
      "dev.rtc.max-user-freq" = 3072;

      "vm.max_ptes_none" = 409;
    };

    # CachyOS udev rules
    services.udev.enable = true;
    services.udev.extraRules = ''
      # Permite controle de latência de CPU pro grupo audio
      DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"

      # SSD SATA → usar scheduler mq-deadline
      ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", \
          ATTR{queue/scheduler}="mq-deadline"

      # SATA Active Link Power Management (força performance)
      ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", \
          ATTR{link_power_management_policy}="max_performance"

      # Clocks de alta resolução pro grupo audio
      KERNEL=="rtc0", GROUP="audio"
      KERNEL=="hpet", GROUP="audio"

      # Evita estalos no áudio → desliga powersave em AC, ativa na bateria
      SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", TEST=="/sys/module/snd_hda_intel", \
          RUN+="/bin/sh -c 'echo $$(cat /run/udev/snd-hda-intel-powersave 2>/dev/null || echo 10) > /sys/module/snd_hda_intel/parameters/power_save'"

      SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", TEST=="/sys/module/snd_hda_intel", \
          RUN+="/bin/sh -c '[[ $$(cat /sys/module/snd_hda_intel/parameters/power_save) != 0 ]] && \
              echo $$(cat /sys/module/snd_hda_intel/parameters/power_save) > /run/udev/snd-hda-intel-powersave; \
              echo 0 > /sys/module/snd_hda_intel/parameters/power_save'"
    '';

    # NTP
    services.timesyncd.servers = [
      "time.cloudflare.com"
      "time.google.com"
      "time.archlinux.org"
    ];

    # Journald Limit
    services.journald.extraConfig = ''
      SystemMaxUse=50M
    '';

    # Tmp on tmpfs. Do I need it? Will it take much space?
    fileSystems."/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["defaults" "rw" "nosuid" "nodev" "mode=1777" "size=6G"];
    };

    # Zram. Needed in my humble 8 Gb Ram machine.
    zramSwap = {
      enable = true;
      priority = 100; # High priority to be used before disk swap
      memoryPercent = 75;
      algorithm = "zstd";
    };

    # Scx - A process scheduler for Linux. Instead of Ananicy-Cpp
    services.scx = {
      enable = true;
      #todo: package = pkgs.scx_git.full;
      scheduler = "scx_lavd";
      extraArgs = ["--autopilot"]; # or --autopower
    };

    # Using libs avaliable on by default CachyOS (base, base-devel, etc...)
    # Nix-ld (To help with foreign pkgs on NixOS)
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        # Core C/C++ runtime & basic compression (roughly Arch base/base-devel)
        stdenv.cc.cc
        glibc
        zlib
        zstd
        xz
        bzip2
        attr
        acl
        util-linux
        systemd
        curl
        openssl
        libssh
        libxml2
        libsodium
        libelf
        expat
        e2fsprogs
        coreutils
        pciutils
        libudev0-shim

        # IPC, crypto, misc system libs
        dbus
        libcap

        # Graphics & GPU stack
        libGL
        libGLU
        libdrm
        libgbm
        vulkan-loader
        libva
        libvdpau
        intel-ocl
        intel-media-driver

        # todo: Adress it
        # Zlude should be behind unstable
        zluda

        # X11 client libraries commonly expected by binaries
        xorg.libX11
        xorg.libXext
        xorg.libXrender
        xorg.libXrandr
        xorg.libXfixes
        xorg.libXcomposite
        xorg.libXdamage
        xorg.libxshmfence
        xorg.libxcb
        xorg.libXxf86vm
        xorg.libXi
        xorg.libXcursor
        xorg.libXinerama
        xorg.libXScrnSaver
        xorg.libSM
        xorg.libICE
        xorg.libXt
        xorg.libXmu
        xorg.libXft
        libxkbcommon

        # Desktop/GUI stack (GTK apps and general rendering)
        glib
        pango
        cairo
        gdk-pixbuf
        fontconfig
        freetype
        gtk3
        gtk4
        libadwaita
        gsettings-desktop-schemas
        libnotify
        icu

        # Audio stacks
        alsa-lib
        pipewire

        # Browser/SSL stacks some apps expect
        nspr
        nss

        # Printing & USB
        cups
        libusb1

        # Multimedia codecs (helps with electron/games/tools)
        ffmpeg-full

        # SDL family commonly expected by games/tools
        SDL
        SDL_image
        SDL_ttf
        SDL_mixer
        SDL2
        SDL2_image
        SDL2_ttf
        SDL2_mixer

        # Legacy compatibility sometimes required by older binaries
        libxcrypt
        libxcrypt-legacy

        # AppImage support (many AppImages expect FUSE2 at runtime)
        fuse
        libappimage
      ];
    };
  };
}
