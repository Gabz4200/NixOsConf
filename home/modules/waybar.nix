{
  lib,
  pkgs,
  config,
  ...
}: let
  icons = rec {
    calendar = "󰃭 ";
    clock = " ";
    battery.charging = "󱐋";
    battery.horizontal = [
      " "
      " "
      " "
      " "
      " "
    ];
    battery.vertical = [
      "󰁺"
      "󰁻"
      "󰁼"
      "󰁽"
      "󰁾"
      "󰁿"
      "󰂀"
      "󰂁"
      "󰂂"
      "󰁹"
    ];
    battery.levels = battery.vertical;
    network.disconnected = "󰤮 ";
    network.ethernet = "󰈀 ";
    network.strength = [
      "󰤟 "
      "󰤢 "
      "󰤥 "
      "󰤨 "
    ];
    bluetooth.on = "󰂯";
    bluetooth.off = "󰂲";
    bluetooth.battery = "󰥉";
    volume.source = "󱄠";
    volume.muted = "󰝟";
    volume.levels = [
      "󰕿"
      "󰖀"
      "󰕾"
    ];
    idle.on = "󰈈 ";
    idle.off = "󰈉 ";
    vpn = "󰌆 ";

    notification.red-badge = "<span foreground='#${config.lib.stylix.colors.base08}'><sup></sup></span>";
    notification.bell = "󰂚";
    notification.bell-badge = "󱅫";
    notification.bell-outline = "󰂜";
    notification.bell-outline-badge = "󰅸";
  };
in {
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    systemd.target = "graphical-session.target";
  };
  programs.waybar.settings.mainBar = {
    layer = "top";
    position = "bottom";
    height = 30;
    spacing = 1;
    margin = "0px";

    modules-left = [
      "group/hardware"
      "niri/workspaces"
      "niri/window"
    ];
    modules-center = [
      "clock"
    ];
    # Módulos da direita reordenados para uma progressão de cores mais suave
    modules-right = [
      "network"
      "wireplumber#sink"
      "backlight"
      "disk"
      "custom/swaync"
      "power-profiles-daemon"
      "battery"
      "group/session"
      "tray"
    ];
    "niri/workspaces" = {
      format = "{icon}";
      format-icons = {
        active = "";
        default = "";
      };
    };
    "niri/window" = {
      format = "<span color='#${config.lib.stylix.colors.base0A}'>  {title}</span>";
      rewrite = {
        "(.*) - Mozilla Firefox" = "🌎 $1";
        "(.*) - zsh" = "> [$1]";
      };
    };

    "custom/hardware-wrap" = {
      format = "";
      tooltip-format = "Resource Usage";
    };

    "group/hardware" = {
      orientation = "horizontal";
      drawer = {
        transition-duration = 500;
        transition-left-to-right = true;
      };
      modules = [
        "custom/hardware-wrap"
        "cpu"
        "memory"
        "temperature"
        # Módulo 'disk' movido para a direita para melhor fluxo
      ];
    };

    "custom/session-wrap" = {
      format = "<span color='#${config.lib.stylix.colors.base0F}'>  </span>"; # Cor alterada para Flamingo (rosa/pêssego)
      tooltip-format = "Lock, Reboot, Shutdown";
    };

    "group/session" = {
      orientation = "horizontal";
      drawer = {
        transition-duration = 500;
        transition-left-to-right = true;
      };
      modules = [
        "custom/session-wrap"
        "custom/lock"
        "custom/reboot"
        "custom/power"
      ];
    };

    "custom/lock" = {
      format = "<span color='#${config.lib.stylix.colors.base0C}'>  </span>";
      on-click = "swaylock -c 000000";
      tooltip = true;
      tooltip-format = "Lock screen";
    };

    "custom/reboot" = {
      format = "<span color='#${config.lib.stylix.colors.base0A}'>  </span>";
      on-click = "systemctl reboot";
      tooltip = true;
      tooltip-format = "Reboot";
    };
    "custom/power" = {
      format = "<span color='#${config.lib.stylix.colors.base08}'>  </span>";
      on-click = "systemctl poweroff";
      tooltip = true;
      tooltip-format = "Power Off";
    };

    clock = {
      format = "󰥔 {:%H:%M 󰃮 %B %d, %Y}";
      format-alt = "󰥔 {:%H:%M}";
      tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      calendar = {
        mode = "month";
        mode-mon-col = 3;
        weeks-pos = "right";
        on-scroll = 1;
        on-click-right = "mode";
        format = {
          months = "<span color='#${config.lib.stylix.colors.base06}'><b>{}</b></span>";
          days = "<span color='#${config.lib.stylix.colors.base08}'>{}</span>";
          weeks = "<span color='#${config.lib.stylix.colors.base0B}'><b>W{}</b></span>";
          weekdays = "<span color='#${config.lib.stylix.colors.base0C}'><b>{}</b></span>";
          today = "<span color='#${config.lib.stylix.colors.base0A}'><b><u>{}</u></b></span>";
        };
      };
      actions = {
        on-click-right = "mode";
        on-click-forward = "tz_up";
        on-click-backward = "tz_down";
        on-scroll-up = "shift_up";
        on-scroll-down = "shift_down";
      };
    };

    cpu = {
      format = "󰘚 {usage}%";
      tooltip = true;
      interval = 1;
      on-click = "kitty -e htop";
    };
    memory = {
      format = "󰍛 {}%";
      interval = 1;
      on-click = "kitty -e htop";
    };

    temperature = {
      critical-threshold = 80;
      format = "{icon} {temperatureC}°C";
      format-icons = [
        "󱃃"
        "󰔏"
        "󱃂"
      ];
    };

    battery = {
      states = {
        good = 95;
        warning = 30;
        critical = 15;
      };
      format = "{icon} {capacity}%";
      format-charging = "󰂄 {capacity}%";
      format-plugged = "󰚥 {capacity}%";
      format-alt = "{icon} {time}";
      format-icons = [
        "󰂎"
        "󰁺"
        "󰁻"
        "󰁼"
        "󰁽"
        "󰁾"
        "󰁿"
        "󰂀"
        "󰂁"
        "󰂂"
        "󰁹"
      ];
    };

    network = {
      format-wifi = "󰖩 {essid} ({signalStrength}%)";
      format-ethernet = "󰈀 {ifname}";
      format-linked = "󰈀 {ifname} (No IP)";
      format-disconnected = "󰖪 Disconnected";
      format-alt = "{ifname}: {ipaddr}/{cidr}";
      tooltip-format = "{ifname}: {ipaddr}";
      on-click-right = "kitty -e nmtui";
    };

    "wireplumber#sink" = {
      format = "{icon} {volume}%";
      format-muted = "";
      format-icons = [
        ""
        ""
        ""
      ];
      on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      on-scroll-down = "wpctl set-volume @DEFAULT_SINK@ 1%-";
      on-scroll-up = "wpctl set-volume @DEFAULT_SINK@ 1%+";
    };
    backlight = {
      format = "{icon} {percent}%";
      format-icons = [
        "󰃞"
        "󰃟"
        "󰃠"
      ];
      on-scroll-up = "brightnessctl set +5%";
      on-scroll-down = "brightnessctl set 5%-";
    };
    disk = {
      interval = 30;
      format = "󰋊 {percentage_used}%";
      path = "/";
    };
    tray = {
      icon-size = 16;
      spacing = 10;
    };
    power-profiles-daemon = {
      format = "{icon}";
      tooltip-format = "Power profile: {profile}\nDriver: {driver}";
      tooltip = true;
      format-icons = {
        default = "";
        performance = "";
        balanced = "";
        power-saver = "";
      };
    };

    "custom/swaync" = {
      tooltip = false;
      format = "{icon}";
      format-icons = {
        notification = "${icons.notification.red-badge}";
        none = icons.notification.bell-outline;
        none-cc-open = icons.notification.bell;
        dnd-notification = "${icons.notification.red-badge}";
        dnd-none = "";
        inhibited-notification = "${icons.notification.red-badge}";
        inhibited-none = "";
        dnd-inhibited-notification = "${icons.notification.red-badge}";
        dnd-inhibited-none = "";
      };
      return-type = "json";
      exec-if = "which swaync-client";
      exec = "swaync-client -swb";
      on-click = "swaync-client -t -sw";
      on-click-right = "swaync-client -d -sw";
      escape = true;
    };
  };
  stylix.targets.waybar.enable = false;
  programs.waybar.style = let
    colors = config.lib.stylix.colors;
  in ''
    /* Base styling (GTK CSS válido) */
    * {
      border: none;
      border-radius: 0;
      font-family: ${config.stylix.fonts.monospace.name} Propo;
      font-size: ${toString (config.stylix.fonts.sizes.desktop + 4)}px;
      min-height: 0;
      color: #${colors.base07};
    }

    window#waybar {
      background-color: #${colors.base00};
      color: #${colors.base07};
    }

    /* Common module styling */
    #mode,
    #custom-hardware-wrap,
    #custom-session-wrap,
    #custom-swaync,
    #clock,
    #cpu,
    #memory,
    #temperature,
    #battery,
    #network,
    #pulseaudio,
    #wireplumber,
    #backlight,
    #disk,
    #power-profiles-daemon,
    #idle_inhibitor,
    #tray {
      padding: 0 10px;
      margin: 0 2px;
      border-bottom: 2px solid transparent;
      background-color: transparent;
    }

    /* Workspaces */
    #workspaces button {
      padding: 0 10px;
      background-color: transparent;
      color: #${colors.base07};
      margin: 0;
    }

    #workspaces button:hover {
      background-color: #${colors.base01};
      box-shadow: none;
    }

    #workspaces button.focused {
      box-shadow: inset 0 -2px #${colors.base0C};
      color: #${colors.base0C};
      font-weight: 900;
    }

    #workspaces button.urgent {
      background-color: #${colors.base08};
      color: #${colors.base00};
    }

    /* Cores por módulo - Nova progressão de cores "tunada" */
    #custom-hardware-wrap { color: #${colors.base0E}; border-bottom-color: #${colors.base0E}; } /* Mauve */
    #cpu { color: #${colors.base0D}; border-bottom-color: #${colors.base0D}; } /* Blue */
    #memory { color: #${colors.base0C}; border-bottom-color: #${colors.base0C}; } /* Teal */
    #temperature { color: #${colors.base0B}; border-bottom-color: #${colors.base0B}; } /* Green */

    #clock { color: #${colors.base0C}; border-bottom-color: #${colors.base0C}; } /* Teal */

    #network { color: #${colors.base0D}; border-bottom-color: #${colors.base0D}; } /* Blue */
    #wireplumber { color: #${colors.base0C}; border-bottom-color: #${colors.base0C}; } /* Teal */
    #backlight { color: #${colors.base0B}; border-bottom-color: #${colors.base0B}; } /* Green */
    #disk { color: #${colors.base0A}; border-bottom-color: #${colors.base0A}; } /* Yellow */
    #custom-swaync { color: #${colors.base09}; border-bottom-color: #${colors.base09}; } /* Peach */
    #power-profiles-daemon { color: #${colors.base08}; border-bottom-color: #${colors.base08}; } /* Red */
    #battery { color: #${colors.base0F}; border-bottom-color: #${colors.base0F}; } /* Flamingo */
    #custom-session-wrap { color: #${colors.base0E}; border-bottom-color: #${colors.base0E}; } /* Mauve */
    #tray { border-bottom-color: #${colors.base0D}; } /* Blue */

    #tray > * { padding: 0 5px; }

    /* Estados */
    .critical, #temperature.critical { color: #${colors.base08}; border-bottom-color: #${colors.base08}; }
    .warning { color: #${colors.base0A}; border-bottom-color: #${colors.base0A}; }
    #network.disconnected { color: #${colors.base08}; border-bottom-color: #${colors.base08}; }
    #wireplumber.muted { color: #${colors.base08}; border-bottom-color: #${colors.base08}; }
    #battery.charging, #battery.plugged { color: #${colors.base0B}; border-bottom-color: #${colors.base0B}; }
    #battery.warning:not(.charging) { color: #${colors.base0A}; border-bottom-color: #${colors.base0A}; }
    #battery.critical:not(.charging) { color: #${colors.base08}; border-bottom-color: #${colors.base08}; }
  '';
}
