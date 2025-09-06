{
  pkgs,
  nixosConfig,
  lib,
  config,
  ...
}: let
  cfg = config.home.apps;
in {
  # Application configurations

  options.home.apps = {
    enable = lib.mkEnableOption "Enable application configurations and app-related settings";
    unstable = lib.mkEnableOption "Enable unstable app features and experimental configurations";
  };

  config = lib.mkIf cfg.enable {
    # I wanted Zen Browser, but it is not on nixpkgs.
    # Browser (Floorp via Firedragon package)
    programs.floorp = {
      enable = true;
      package = pkgs.firedragon;
    };

    #todo: Adress it.
    # I am thinking of making IDEs like VsCode use the following:
    # Make nix-shelss with nixpkgs.vscode.fhsWithPackages and add extensions and needed packages to it.
    # The system vscodium would use a wrapper so "codium ." opens the prebaked nix-shell.
    # But, I could also make multiple combinations, so the withPkgs would be smaller for each.
    # Plus, I could make actual devShells install its own vscodiums too.
    # It is a nice idea or a dumb Idea that would make everything more complex than it needs to be?
    # Of course, this applies to other editors too, like Zed.

    # Editors and IDEs
    programs.vscode = {
      enable = true;
      #todo: Adress it.
      # The problem with this list, is that it repeats in many places on the config, I should make more common vars.
      # So I dont repeat myself.
      package = pkgs.vscodium.fhsWithPackages (
        pkgs:
          with pkgs; [
            codeium
            gemini-cli
            github-copilot-intellij-agent
            mcp-nixos
            qwen-code
            cargo
            uv
            nodejs
            python3
            rustc

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
            lsp-ai
            llm-ls
          ]
      );
      mutableExtensionsDir = true;
    };

    programs.zed-editor.enable = true;

    # Containers
    #todo: Adress it.
    # Should I make a CachyOS distrobox for "free mess" for dev and no-nix packages?
    #Or it is overkill? I dont need it that much as I felt like when I wrote it.
    programs.distrobox = {
      enable = true;
      #todo: enableSystemdUnit = true;
    };

    home.packages = with pkgs; [
      boxbuddy
      bottles
    ];

    # OBS Studio
    programs.obs-studio = {
      enable = true;
      package = pkgs.obs-studio;
      plugins = [pkgs.obs-studio-plugins.wlrobs];
    };

    # Neovim (NvChad)
    programs.nvchad = {
      enable = true;
      # Necessary?
      extraPackages = with pkgs; [
        bash-language-server
        kdlfmt
        alejandra
        nixd
        (python3.withPackages (ps:
          with ps; [
            python-lsp-server
            flake8
          ]))
      ];
      hm-activation = true;
      backup = false;
    };

    # Git
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      extraConfig = {
        include = {
          inherit (nixosConfig.sops.secrets."git") path;
        };
      };
    };
  };
}
