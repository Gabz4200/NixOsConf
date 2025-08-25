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

    notification.red-badge = "<span foreground='red'><sup></sup></span>";
    notification.bell = "󰂚";
    notification.bell-badge = "󱅫";
    notification.bell-outline = "󰂜";
    notification.bell-outline-badge = "󰅸";
  };
in {
  #todo: Change it to a better configuration. Maybe the one from HyDE, or some sidebar one.
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    systemd.target = "graphical-session.target";
  };
  programs.waybar.settings.mainBar = {
    layer = "top";
    modules-left = [
      "wireplumber"
      "wireplumber#source"
      "idle_inhibitor"
    ];
    modules-center = [
      "clock#date"
      "clock"
    ];
    modules-right = [
      "network"
      "bluetooth"
      "bluetooth#battery"
      "battery"
      "custom/swaync"
    ];

    battery = {
      interval = 5;
      format = "{icon}  {capacity}%";
      format-charging = "{icon}  {capacity}% ${icons.battery.charging}";
      format-icons = icons.battery.levels;
      states.warning = 30;
      states.critical = 15;
    };

    clock = {
      interval = 1;
      format = "${icons.clock} {:%H:%M:%S} paggles";
    };

    "clock#date" = {
      format = "${icons.calendar} {:%Y-%m-%d}";
    };
    "clock#week" = {
      format = "${icons.calendar} {:%W}";
    };

    network = {
      tooltip-format = "{ifname}";
      format-disconnected = icons.network.disconnected;
      format-ethernet = icons.network.ethernet;
      format-wifi = "{icon} {essid}";
      format-icons = icons.network.strength;
    };

    bluetooth = {
      format = "{icon}";
      format-disabled = "";
      format-icons = {
        inherit (icons.bluetooth) on off;
        connected = icons.bluetooth.on;
      };
      format-connected = "{icon} {device_alias}";
    };
    "bluetooth#battery" = {
      format = "";
      format-connected-battery = "${icons.bluetooth.battery} {device_battery_percentage}%";
    };

    wireplumber = {
      format = "{icon} {volume}%";
      format-muted = "${icons.volume.muted} {volume}%";
      format-icons = icons.volume.levels;
      reverse-scrolling = 1;
      tooltip = false;
    };

    "wireplumber#source" = {
      format = "${icons.volume.source} {node_name}";
      tooltip = false;
    };

    # "group/volume" = {
    #   orientation = "horizontal";
    #   modules = [
    #     "wireplumber"
    #     "wireplumber#source"
    #   ];
    #   drawer = {
    #     transition-left-to-right = true;
    #   };
    # };

    idle_inhibitor = {
      format = "{icon}";
      format-icons = {
        activated = icons.idle.on;
        deactivated = icons.idle.off;
      };
    };

    "custom/swaync" = {
      tooltip = false;
      format = "{icon}";
      format-icons = {
        notification = "<span foreground='red'><sup></sup></span>";
        none = icons.notification.bell-outline;
        none-cc-open = icons.notification.bell;
        dnd-notification = "<span foreground='red'><sup></sup></span>";
        dnd-none = "";
        inhibited-notification = "<span foreground='red'><sup></sup></span>";
        inhibited-none = "";
        dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
        dnd-inhibited-none = "";
      };
      return-type = "json";
      exec-if = "which swaync-client";
      exec = "swaync-client -swb";
      # exec = ''swaync-client -swb | jq -c 'if .class | .[]? // . | contains("cc-open") then .alt += "-cc-open" else . end' '';
      on-click = "swaync-client -t -sw";
      on-click-right = "swaync-client -d -sw";
      escape = true;
    };
  };
  stylix.targets.waybar.enable = false;
  programs.waybar.style = ''
    /* Pastel TTY Colors */
    @define-color background #212121;
    @define-color background-light #3a3a3a;
    @define-color foreground #e0e0e0;
    @define-color black #5a5a5a;
    @define-color red #ff9a9e;
    @define-color green #b5e8a9;
    @define-color yellow #ffe6a7;
    @define-color blue #63a4ff;
    @define-color magenta #dda0dd;
    @define-color cyan #a3e8e8;
    @define-color white #ffffff;
    @define-color orange #ff8952;

    /* Module-specific colors */
    @define-color workspaces-color @foreground;
    @define-color workspaces-focused-bg @green;
    @define-color workspaces-focused-fg @cyan;
    @define-color workspaces-urgent-bg @red;
    @define-color workspaces-urgent-fg @black;

    /* Text and border colors for modules */
    @define-color mode-color @orange;
    @define-color group-hardware-color @blue;
    @define-color group-session-color @red;
    @define-color clock-color @blue;
    @define-color cpu-color @green;
    @define-color memory-color @magenta;
    @define-color temperature-color @yellow;
    @define-color temperature-critical-color @red;
    @define-color battery-color @cyan;
    @define-color battery-charging-color @green;
    @define-color battery-warning-color @yellow;
    @define-color battery-critical-color @red;
    @define-color network-color @blue;
    @define-color network-disconnected-color @red;
    @define-color pulseaudio-color @orange;
    @define-color pulseaudio-muted-color @red;
    @define-color wireplumber-color @orange;
    @define-color wireplumber-muted-color @red;
    @define-color backlight-color @yellow;
    @define-color disk-color @cyan;
    @define-color updates-color @orange;
    @define-color quote-color @green;
    @define-color idle-inhibitor-color @foreground;
    @define-color idle-inhibitor-active-color @red;
    @define-color power-profiles-daemon-color @cyan;
    @define-color power-profiles-daemon-performance-color @red;
    @define-color power-profiles-daemon-balanced-color @yellow;
    @define-color power-profiles-daemon-power-saver-color @green;

    * {
      /* Base styling for all modules */
      border: none;
      border-radius: 0;
      font-family: "JetBrainsMono Nerd Font Propo";
      font-size: 14px;
      min-height: 0;
    }

    window#waybar {
      background-color: @background;
      color: @foreground;
    }

    /* Common module styling with border-bottom */
    #mode,
    #custom-hardware-wrap,
    #custom-session-wrap,
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

    /* Workspaces styling */
    #workspaces button {
      padding: 0 10px;
      background-color: transparent;
      color: @workspaces-color;
      margin: 0;
    }

    #workspaces button:hover {
      background: @background-light;
      box-shadow: inherit;
    }

    #workspaces button.focused {
      box-shadow: inset 0 -2px @workspaces-focused-fg;
      color: @workspaces-focused-fg;
      font-weight: 900;
    }

    #workspaces button.urgent {
      background-color: @workspaces-urgent-bg;
      color: @workspaces-urgent-fg;
    }

    /* Module-specific styling */
    #mode {
      color: @mode-color;
      border-bottom-color: @mode-color;
    }

    #custom-hardware-wrap {
      color: @group-hardware-color;
      border-bottom-color: @group-hardware-color;
    }

    #custom-session-wrap {
      color: @group-session-color;
      border-bottom-color: @group-session-color;
    }

    #clock {
      color: @clock-color;
      border-bottom-color: @clock-color;
    }

    #cpu {
      color: @cpu-color;
      border-bottom-color: @cpu-color;
    }

    #memory {
      color: @memory-color;
      border-bottom-color: @memory-color;
    }

    #temperature {
      color: @temperature-color;
      border-bottom-color: @temperature-color;
    }

    #temperature.critical {
      color: @temperature-critical-color;
      border-bottom-color: @temperature-critical-color;
    }

    #power-profiles-daemon {
      color: @power-profiles-daemon-color;
      border-bottom-color: @power-profiles-daemon-color;
    }

    #power-profiles-daemon.performance {
      color: @power-profiles-daemon-performance-color;
      border-bottom-color: @power-profiles-daemon-performance-color;
    }

    #power-profiles-daemon.balanced {
      color: @power-profiles-daemon-balanced-color;
      border-bottom-color: @power-profiles-daemon-balanced-color;
    }

    #power-profiles-daemon.power-saver {
      color: @power-profiles-daemon-power-saver-color;
      border-bottom-color: @power-profiles-daemon-power-saver-color;
    }

    #battery {
      color: @battery-color;
      border-bottom-color: @battery-color;
    }

    #battery.charging,
    #battery.plugged {
      color: @battery-charging-color;
      border-bottom-color: @battery-charging-color;
    }

    #battery.warning:not(.charging) {
      color: @battery-warning-color;
      border-bottom-color: @battery-warning-color;
    }

    #battery.critical:not(.charging) {
      color: @battery-critical-color;
      border-bottom-color: @battery-critical-color;
    }

    #network {
      color: @network-color;
      border-bottom-color: @network-color;
    }

    #network.disconnected {
      color: @network-disconnected-color;
      border-bottom-color: @network-disconnected-color;
    }

    #pulseaudio {
      color: @pulseaudio-color;
      border-bottom-color: @pulseaudio-color;
    }

    #pulseaudio.muted {
      color: @pulseaudio-muted-color;
      border-bottom-color: @pulseaudio-muted-color;
    }

    #wireplumber {
      color: @wireplumber-color;
      border-bottom-color: @wireplumber-color;
    }

    #wireplumber.muted {
      color: @wireplumber-muted-color;
      border-bottom-color: @wireplumber-muted-color;
    }

    #backlight {
      color: @backlight-color;
      border-bottom-color: @backlight-color;
    }

    #disk {
      color: @disk-color;
      border-bottom-color: @disk-color;
    }

    #idle_inhibitor {
      color: @idle-inhibitor-color;
      border-bottom-color: transparent;
    }

    #idle_inhibitor.activated {
      color: @idle-inhibitor-active-color;
      border-bottom-color: @idle-inhibitor-active-color;
    }

    #tray {
      background-color: transparent;
      padding: 0 10px;
      margin: 0 2px;
    }

    #tray>.passive {
      -gtk-icon-effect: dim;
    }

    #tray>.needs-attention {
      -gtk-icon-effect: highlight;
      color: @red;
      border-bottom-color: @red;
    }
  '';
}
