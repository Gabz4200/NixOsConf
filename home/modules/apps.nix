{
  pkgs,
  nixosConfig,
  ...
}: {
  # Application configurations

  # Browser (Floorp via Firedragon package)
  programs.floorp = {
    enable = true;
    package = pkgs.firedragon;
  };

  # Editors and IDEs
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium.fhsWithPackages (
      pkgs:
        with pkgs; [
          cargo
          uv
          nodejs
          python3
          rustc
          nix
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
        ]
    );
    mutableExtensionsDir = true;
  };

  programs.zed-editor.enable = true;

  # Containers
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
}
