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
  # This configuration works. And I like it.
  # BUT IT IS A MESS!!
  #TODO: Organize it!
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
      struts.left = 8;
      struts.right = 8;
      border.width = 4;
      always-center-single-column = true;
      empty-workspace-above-first = true;

      focus-ring = {
        enable = true;
        width = 4;
        active.color = config.lib.stylix.colors.withHashtag.base0E;
        inactive.color = config.lib.stylix.colors.withHashtag.base02;
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

          "Alt+Tab".action = spawn "niriswitcherctl show --window";
          "Alt+Shift+Tab".action = spawn "niriswitcherctl show --workspace";

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
          "Mod+Alt+V".action = switch-focus-between-floating-and-tiling;
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
          "Mod+Alt+F".action = maximize-column;
          "Mod+F".action = expand-column-to-available-width;
          "Mod+Shift+F".action = fullscreen-window;
          "Mod+C".action = center-column;
          "Mod+Shift+Left".action = set-column-width "-10%";
          "Mod+Shift+Right".action = set-column-width "+10%";
          "Mod+Shift+E".action = quit;
          "Mod+Shift+P".action = power-off-monitors;
          "Mod+V".action = toggle-overview;
        }
      ];

    animations.window-resize.custom-shader = builtins.readFile ../../resources/resize.glsl;

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

    # This was not working. It wouldnt build the system.
    #xwayland-satellite.path = "/etc/profiles/per-user/gabz/bin/xwayland-satellite";
    #xwayland-satellite.path = "{pkgs.xwayland-satellite-unstable}/bin/xwayland-satellite";
  };

  programs.niri.settings.environment."NIXOS_OZONE_WL" = "1";
  #programs.waybar.settings.mainBar.layer = "top";
  #systemd.user.services.niri-flake-polkit.enable = true;

  #TODO: xwayland-satellite.path = "${lib.getExe pkgs.xwayland-satellite-unstable}";

  # I dont remember to ever using it tbh
  programs.niriswitcher.enable = true;
  programs.niriswitcher.settings = {
    keys = {
      modifier = "Super";
      switch = {
        next = "Tab";
        prev = "Shift+Tab";
      };
    };
    center_on_focus = true;
    appearance = {
      system_theme = "dark";
      icon_size = 64;
    };
  };

  home.packages = with pkgs; [
    # Dependências do sistema e UWSM
    app2unit
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


  # Kitty configuration moved to home/modules/terminal.nix

  systemd.user.startServices = true;

  # Wallpaper setter. Great. But maybe move to somewhere else.
  systemd.user.services = {
    wallpaper_setter = {
      Unit = {
        Description = "Sets my wallpaper";
      };
      Install = {
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.swww}/bin/swww img ${config.stylix.image}";
        Type = "oneshot";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };

  # Fuzzel. (Should I switch with rofi-wayland/wofi? I used rofi on Hyprland)
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        # Is this well done? I have no clue.
        launch-prefix = "niri msg action spawn -- app2unit --fuzzel-compat --";
        terminal = "${pkgs.app2unit}/bin/app2unit-term-scope";
        layer = "overlay";
      };
    };
  };

  services.swaync.enable = true;
}
