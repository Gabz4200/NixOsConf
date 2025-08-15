{
  lib,
  nixosConfig,
  config,
  pkgs,
  ...
}:
with lib; let
  binds = {
    suffixes,
    prefixes,
    substitutions ? {},
  }: let
    replacer = replaceStrings (attrNames substitutions) (attrValues substitutions);
    format = prefix: suffix: let
      actual-suffix =
        if isList suffix.action
        then {
          action = head suffix.action;
          args = tail suffix.action;
        }
        else {
          inherit (suffix) action;
          args = [];
        };

      action = replacer "${prefix.action}-${actual-suffix.action}";
    in {
      name = "${prefix.key}+${suffix.key}";
      value.action.${action} = actual-suffix.args;
    };
    pairs = attrs: fn:
      concatMap (
        key:
          fn {
            inherit key;
            action = attrs.${key};
          }
      ) (attrNames attrs);
  in
    listToAttrs (pairs prefixes (prefix: pairs suffixes (suffix: [(format prefix suffix)])));
in {
  programs.niri.settings = {
    input.keyboard.xkb.layout = "br";
    input.mouse.accel-speed = 0.3;
    input.touchpad.accel-speed = 0.5;
    input.touchpad = {
      tap = true;
      dwt = true;
      natural-scroll = true;
      click-method = "clickfinger";
    };

    input.tablet.map-to-output = "eDP-1";
    input.touch.map-to-output = "eDP-1";

    prefer-no-csd = true;

    layout = {
      gaps = 16;
      struts.left = 64;
      struts.right = 64;
      border.width = 4;
      always-center-single-column = true;
      empty-workspace-above-first = true;

      focus-ring = {
        enable = true;
        width = 2;
        active.color = config.lib.stylix.colors.withHashtag.base0E;
        inactive.color = config.lib.stylix.colors.withHashtag.base00;
      };

      shadow.enable = true;

      #shadow.radius = 12;
      #shadow.opacity = 0.35;

      tab-indicator = {
        position = "top";
        gaps-between-tabs = 10;
      };
    };

    hotkey-overlay.skip-at-startup = true;
    clipboard.disable-primary = true;
    overview.zoom = 0.5;
    screenshot-path = "~/Pictures/Screenshots/%Y-%m-%dT%H:%M:%S.png";

    binds = with config.lib.niri.actions; let
      sh = spawn "sh" "-c";
      screenshot-area-script = pkgs.writeShellScript "screenshot-area" ''
        grim -o $(niri msg --json focused-output | jq -r .name) - | swayimg --config=info.mode=off --fullscreen - &
        SWAYIMG=$!
        niri msg action do-screen-transition -d 1200
        sleep 1.2
        grim -g "$(slurp)" - | wl-copy -t image/png && notify-send 'Screenshot' 'Copy to clipboard!'
        niri msg action do-screen-transition
        kill $SWAYIMG
      '';
      screenshot-area = spawn "${screenshot-area-script}";
    in
      lib.attrsets.mergeAttrsList [
        {
          "Mod+T".action = spawn "app2unit-term-scope";
          "Mod+O".action = show-hotkey-overlay;
          "Mod+D".action = spawn "fuzzel";
          "Mod+W".action = sh "systemctl --user restart waybar.service";
          "Mod+L".action = spawn "swaylock";

          "Mod+Shift+S".action = screenshot-area;
          "Print".action.screenshot-screen = [];
          "Mod+Print".action = screenshot-window;

          "XF86AudioRaiseVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute".action = sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

          "XF86MonBrightnessUp".action = sh "brightnessctl set 5%+";
          "XF86MonBrightnessDown".action = sh "brightnessctl set 5%-";

          "Mod+Q".action = close-window;
          "Mod+Ctrl+L".action = sh "playerctl pause; wpctl set-mute @DEFAULT_AUDIO_SINK@ 1; swaylock";
          "Mod+Space".action = toggle-column-tabbed-display;
          "Mod+Tab".action = focus-window-down-or-column-right;
          "Mod+Shift+Tab".action = focus-window-up-or-column-left;
        }
        (binds {
          suffixes."Left" = "column-left";
          suffixes."Down" = "window-down";
          suffixes."Up" = "window-up";
          suffixes."Right" = "column-right";
          prefixes."Mod" = "focus";
          prefixes."Mod+Ctrl" = "move";
          prefixes."Mod+Shift" = "focus-monitor";
          prefixes."Mod+Shift+Ctrl" = "move-window-to-monitor";
          substitutions."monitor-column" = "monitor";
          substitutions."monitor-window" = "monitor";
        })
        {
          "Mod+V".action = switch-focus-between-floating-and-tiling;
          "Mod+Shift+V".action = toggle-window-floating;
        }
        (binds {
          suffixes."Home" = "first";
          suffixes."End" = "last";
          prefixes."Mod" = "focus-column";
          prefixes."Mod+Ctrl" = "move-column-to";
        })
        (binds {
          suffixes."U" = "workspace-down";
          suffixes."I" = "workspace-up";
          prefixes."Mod" = "focus";
          prefixes."Mod+Ctrl" = "move-window-to";
          prefixes."Mod+Shift" = "move";
        })
        (binds {
          suffixes = builtins.listToAttrs (
            map (n: {
              name = toString n;
              value = ["workspace" (n + 1)];
            }) (range 1 9)
          );
          prefixes."Mod" = "focus";
          prefixes."Mod+Ctrl" = "move-window-to";
        })
        {
          "Mod+R".action = switch-preset-column-width;
          "Mod+F".action = maximize-column;
          "Mod+Shift+F".action = fullscreen-window;
          "Mod+C".action = center-column;
          "Mod+Minus".action = set-column-width "-10%";
          "Mod+Plus".action = set-column-width "+10%";
          "Mod+Shift+E".action = quit;
          "Mod+Shift+P".action = power-off-monitors;
        }
      ];

    animations.window-resize.custom-shader = builtins.readFile ./resize.glsl;

    window-rules = let
      colors = config.lib.stylix.colors.withHashtag;
    in [
      {
        draw-border-with-background = false;
        clip-to-geometry = true;
      }
      {
        matches = [
          {
            app-id = "^kitty$";
            title = ''^\[oxygen\]'';
          }
        ];
        border.active.color = colors.base0B;
      }
      {
        matches = [
          {
            app-id = "^(firefox|floorp|firedragon|zen)$";
            title = "(Private Browsing|Navegação Privada)";
          }
        ];
        border.active.color = colors.base0E;
      }
    ];
    gestures.dnd-edge-view-scroll = {
      trigger-width = 64;
      delay-ms = 250;
      max-speed = 12000;
    };

    layer-rules = [
      {
        matches = [{namespace = "^swaync-notification-window$";}];

        block-out-from = "screencast";
      }
      {
        matches = [{namespace = "^swww-daemonoverview$";}];

        place-within-backdrop = true;
      }
    ];
    xwayland-satellite.enable = true;
  };

  #TODO: xwayland-satellite.path = "${lib.getExe pkgs.xwayland-satellite-unstable}";
  programs.niriswitcher.enable = true;

  home.packages = with pkgs; [
    # Dependências do sistema e UWSM
    app2unit
    uwsm
    xwayland-satellite-unstable

    # Ferramentas de screenshot
    grim
    slurp
    swayimg
    wl-clipboard

    # Utilitários de atalhos
    libnotify # Para `notify-send`
    brightnessctl
    playerctl # Para o atalho de lock
    jq # Usado no script de screenshot
    swaylock # Ou outro locker, como 'blurred-locker'
  ];

  xdg.terminal-exec.enable = true;
  xdg.terminal-exec.settings = {default = ["kitty.desktop"];};
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/terminal" = "kitty.desktop";
  };
  home.sessionVariables = {
    TERMINAL = "kitty";
  };

  programs.kitty = {
    enable = true;
    settings = {
      window_border_width = "8px";
      tab_bar_edge = "top";
      tab_bar_margin_width = "0.0";
      tab_bar_style = "fade";
      placement_strategy = "top-left";
      hide_window_decorations = true;
    };
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        launch-prefix = "niri msg action spawn -- app2unit --fuzzel-compat --";
        terminal = "${pkgs.app2unit}/bin/app2unit-term-scope";
        layer = "overlay";
      };
      colors.background = "ffffffff";
    };
  };

  services.swaync.enable = true;
}
