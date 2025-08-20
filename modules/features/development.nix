{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  # Development tools
  environment.systemPackages = with pkgs; [
    # Nix development
    nixd
    nil
    alejandra
    nixfmt-rfc-style
    nix-prefetch-git
    nix-tree
    nix-diff
    nix-output-monitor
    nix-binary-cache

    # Language servers
    bash-language-server
    yaml-language-server

    # Python
    (pkgs.python3.withPackages (ps:
      with ps; [
        ruff
        pipx
        uv
      ]))

    # Build tools
    gcc
    gnumake
    cmake
    pkg-config
    meson
    ninja

    # Version control
    git
    git-lfs
    gh

    # Debugging
    gdb
    valgrind
    strace
    ltrace

    # Documentation
    man-pages
    man-pages-posix

    # Containers
    podman-compose
    dive
    appimage-run

    # Tools
    jq
    yq-go
    ripgrep
    fd
    bat
    eza
    delta
    hyperfine
    tokei

    # Just
    just
    just-lsp
  ];

  # Git
  programs.git = {
    enable = true;
    lfs.enable = true;

    config = {
      init.defaultBranch = "main";

      # Performance para repos grandes
      core = {
        fsmonitor = true;
        untrackedcache = true;
      };

      # Better diff
      diff.algorithm = "histogram";

      # Fetch optimizations
      fetch = {
        prune = true;
        pruneTags = true;
      };

      # Merge
      merge = {
        conflictstyle = "zdiff3";
        tool = "vimdiff";
      };

      # Rebase
      rebase = {
        autosquash = true;
        autostash = true;
      };

      # Pull
      pull.rebase = true;
    };
  };

  # SSH
  programs.ssh = {
    startAgent = false; # I use goldwarden
    extraConfig = ''
      AddKeysToAgent yes
      IdentityFile ~/.ssh/id_ed25519

      # GitHub
      Host github.com
        HostName github.com
        User git

      # GitLab
      Host gitlab.com
        HostName gitlab.com
        User git
    '';
  };

  # Goldwarden (Bitwarden CLI + SSH)
  programs.goldwarden = {
    enable = true;
    useSshAgent = true;
  };

  # GnuPG
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false; # Using goldwarden
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
      package = pkgs.nix-direnv;
    };
    loadInNixShell = true;
  };

  # FHS environment helper
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Virtualização
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;

    # Auto cleanup
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = ["--all"];
    };

    # Default network
    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };

  # KVM/QEMU
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [pkgs.OVMFFull.fd];
      };
    };
  };

  # Waydroid (Android container)
  virtualisation.waydroid.enable = true;

  # Documentation
  documentation = {
    enable = true;
    dev.enable = true;
    man.enable = true;
    info.enable = true;
    doc.enable = true;

    # Generate man page indexes
    man.generateCaches = true;
  };

  # Development kernel modules
  boot.kernelModules = ["kvm-intel"];
}
