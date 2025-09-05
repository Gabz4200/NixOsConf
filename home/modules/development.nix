{pkgs, ...}: {
  # Development tools and configurations

  # Nix settings (cachix substituters/keys)
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];

    # Performance
    auto-optimise-store = true;

    # Segurança
    sandbox = true;
    trusted-users = ["@wheel" "root" "gabz"];
    allowed-users = ["@wheel" "root" "gabz"];

    # Substituters
    substituters = [
      "https://niri.cachix.org"
      "https://chaotic-nyx.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://nur.cachix.org"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://pre-commit-hooks.cachix.org"
      "https://catppuccin.cachix.org"
    ];

    trusted-public-keys = [
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nur.cachix.org-1:F8+2oprcHLfsYyZBCsVJZJrPyGHwuE+EZBtukwalV7o="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQfFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
    ];
  };

  programs.matplotlib.enable = true;
  programs.ruff.enable = true;
  programs.pylint.enable = true;

  #todo: Use a custom one
  programs.ruff.settings = {
    line-length = 100;
    per-file-ignores = {"__init__.py" = ["F401"];};
    lint = {
      select = ["E4" "E7" "E9" "F"];
      ignore = [];
    };
  };

  # Dev tooling packages
  home.packages = with pkgs; [
    # Linters/formatters
    shfmt
    shellcheck
    bash-language-server
    treefmt
    #! broken> nix-linter
    nixpkgs-lint-community
    nixpkgs-fmt
    alejandra
    nixpkgs-hammering
    nixpkgs-lint
    deadnix

    # Python
    python3

    # Faculdade
    texliveBasic
    texstudio

    # Faculdade: Cálculo Numérico
    octave
    scilab-bin
    geogebra6
    #todo: sageWithDoc

    # Faculdade: Probabilidade e Estatística
    R

    # Faculdade: Excel (para Cálculo Numérico tbm, mas eu não sei qual é melhor)
    libreoffice-fresh
    onlyoffice-bin_latest
    gnumeric
  ];
}
