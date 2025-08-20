{
  config,
  pkgs,
  lib,
  ...
}: {
  # Zsh
  programs.zsh = {
    enable = true;

    # História
    history = {
      size = 100000;
      save = 100000;
      path = "$HOME/.cache/zsh_history";
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      extended = true;
    };

    # Completion
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      strategy = ["history" "completion"];
    };

    historySubstringSearch.enable = true;

    # Syntax highlighting
    syntaxHighlighting = {
      enable = true;
      highlighters = ["main" "brackets" "pattern"];
    };

    # Oh My Zsh
    oh-my-zsh = {
      enable = true;
      theme = lib.mkDefault "catppuccin-mocha";

      plugins = [
        # Aliases
        "common-aliases"
        "alias-finder"

        # Git
        "git"
        "gitfast"

        # Utils
        "sudo"
        "colored-man-pages"
        "extract"
        "copypath"
        "copyfile"
        "copybuffer"

        # Development
        "docker-compose"
        "npm"
        "python"
        "rust"

        # Navigation
        "dirhistory"
        "z"
      ];
    };

    # Aliases
    shellAliases = {
      # System
      rebuild = "nh os switch";
      update = "nh os switch --update";
      clean = "nh clean all";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Safety
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -Iv";

      # Listing
      l = "eza -l";
      la = "eza -la";
      ll = "eza -l";
      ls = "eza";
      tree = "eza --tree";

      # Git shortcuts
      g = "git";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gst = "git status";

      # Nix
      ns = "nix-shell";
      nb = "nix build";
      ne = "nix-env";
      nq = "nix-env -q";

      # Utils
      cat = "bat";
      grep = "rg";
      find = "fd";
      df = "df -h";
      du = "dust";
      free = "free -h";

      # Clipboard
      copy = "wl-copy";
      paste = "wl-paste";

      # Quick edits
      nixconf = "cd $HOME/NixConf && $EDITOR";
      zshrc = "$EDITOR ~/.zshrc";
    };

    # Init extra
    initContent = lib.mkOrder 1200 ''
      # Better cd
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_MINUS

      # Better globbing
      setopt EXTENDED_GLOB
      setopt GLOB_DOTS

      # No beep
      unsetopt BEEP

      # Vi mode
      bindkey -v
      bindkey '^R' history-incremental-search-backward

      # Key bindings
      bindkey '^[[1;5C' forward-word   # Ctrl+Right
      bindkey '^[[1;5D' backward-word  # Ctrl+Left
      bindkey '^[[H' beginning-of-line # Home
      bindkey '^[[F' end-of-line       # End

      # FZF integration
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      # Custom functions
      mkcd() {
        mkdir -p "$1" && cd "$1"
      }

      # Quick backup
      backup() {
        cp -r "$1" "$1.bak.$(date +%Y%m%d-%H%M%S)"
      }

      # Extract any archive
      extract() {
        if [ -f "$1" ]; then
          case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz) tar xzf "$1" ;;
            *.tar.xz) tar xJf "$1" ;;
            *.bz2) bunzip2 "$1" ;;
            *.rar) unrar x "$1" ;;
            *.gz) gunzip "$1" ;;
            *.tar) tar xf "$1" ;;
            *.tbz2) tar xjf "$1" ;;
            *.tgz) tar xzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *.7z) 7z x "$1" ;;
            *) echo "'$1' cannot be extracted" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
      }
    '';
  };

  home.shell.enableZshIntegration = true;

  programs.nix-your-shell = {
    enable = lib.mkBefore true;
    enableZshIntegration = lib.mkBefore true;
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      format = ''
        $username$hostname$directory$git_branch$git_status$cmd_duration
        $character
      '';

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vicmd_symbol = "[❮](bold green)";
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold cyan";
      };

      git_branch = {
        style = "bold purple";
        symbol = " ";
      };

      git_status = {
        style = "bold red";
        ahead = "⇡$count";
        behind = "⇣$count";
        diverged = "⇕⇡$ahead_count⇣$behind_count";
        staged = "+$count";
        modified = "!$count";
        untracked = "?$count";
      };

      cmd_duration = {
        min_time = 500;
        format = "[$duration](bold yellow)";
      };

      username = {
        show_always = false;
        style_user = "bold green";
        format = "[$user]($style)";
      };

      hostname = {
        ssh_only = true;
        format = "[@$hostname](bold green) ";
      };
    };
  };

  # Other shell tools
  programs = {
    # Better cd
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = ["--cmd cd"];
    };

    # Better ls
    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "always";
      git = true;
    };

    # Better cat
    bat = {
      enable = true;
      config = {
        theme = lib.mkDefault "Catppuccin-mocha";
        pager = "less -FR";
      };
    };

    # FZF
    fzf = {
      enable = true;
      enableZshIntegration = true;

      defaultOptions = [
        "--height 40%"
        "--border"
        "--layout=reverse"
        "--inline-info"
      ];

      fileWidgetOptions = [
        "--preview 'bat --color=always --style=numbers --line-range=:100 {}'"
      ];
    };

    # Direnv
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    # Nix integration
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    command-not-found.enable = false;

    # Git integration
    gh = {
      enable = true;
      gitCredentialHelper.enable = true;

      settings = {
        editor = "nvim";
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
  };

  # Shell packages
  home.packages = with pkgs; [
    # Shell utils
    shellcheck
    shfmt

    # Modern Unix tools
    duf # Better df
    dust # Better du
    procs # Better ps
    bottom # Better top
    hyperfine # Benchmarking
    tokei # Code statistics

    # JSON/YAML
    jq
    yq-go

    # Network
    httpie
    curlie

    # Misc
    tealdeer # tldr in Rust
    navi # Interactive cheatsheet
  ];
}
