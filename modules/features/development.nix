{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.development;
in {
  # Development tools
  # Only the ones that may always be needed even outside development shells on Nix flakes. Are these great tho?

  options.features.development = {
    enable = lib.mkEnableOption "Enable development tools and development-related configurations";
    unstable = lib.mkEnableOption "Enable unstable development features and experimental configurations";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Nix development
      nixd
      nil
      statix
      alejandra
      nixfmt-rfc-style
      nix-prefetch-git
      nix-tree
      nix-diff
      nix-output-monitor
      nix-binary-cache
      just
      nh

      # Language servers
      bash-language-server
      yaml-language-server

      # Python
      (pkgs.python3.withPackages (ps:
        with ps; [
          ruff
          pip
          pipx
          virtualenv
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

      devenv
      devbox

      # Just
      just
      just-lsp
    ];

    # Git
    # Are these configs great? I did not made it.
    programs.git = {
      enable = true;
      lfs.enable = true;
      package = pkgs.gitFull;

      config = {
        init.defaultBranch = "master";

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

      # Correct?
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
    # Should I change to Bitwarden GUI?
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

    # Appimages
    programs.appimage = {
      enable = true;
      binfmt = true;
    };

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

    # Development kernel modules. Will it merge?
    boot.kernelModules = ["kvm-intel"];
  };
}
