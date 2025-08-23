{ pkgs, nixosConfig, ... }:

{
  # Application configurations

  # Browser (Floorp via Firedragon package)
  programs.floorp = {
    enable = true;
    package = pkgs.firedragon;
  };

  # Editors and IDEs
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium.fhs;
    mutableExtensionsDir = true;
  };

  programs.zed-editor.enable = true;

  # Containers
  programs.distrobox = {
    enable = true;
    enableSystemdUnit = true;
  };

  # OBS Studio
  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio;
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
        path = nixosConfig.sops.secrets."git".path;
      };
    };
  };
}
