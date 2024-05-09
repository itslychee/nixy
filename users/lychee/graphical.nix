{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  inherit (lib) getExe mkIf;
  swaySystemd = config.wayland.windowManager.sway.systemd.enable;
  cfg = config.wayland.windowManager.sway;
in {
  home.packages = builtins.attrValues {
    inherit
      (pkgs)
      wayshot
      wl-clipboard
      slurp
      swappy
      ;
  };
  wayland.windowManager.sway = {
    package = pkgs.swayfx;
    checkConfig = false; # fixes the dumb build time check
    config = {
      bars = [];
      window.commands = [
        {
          command = "floating enable";
          criteria.app_id = "xdg-desktop-portal-*";
        }
        {
          command = "floating enable";
          criteria.title = "^Extension: .+";
        }
      ];
      gaps.smartBorders = "on";
      focus.followMouse = "always";
      modifier = "Mod4";
      terminal = pkgs.alacritty;
      menu = pkgs.fuzzel;
      output."*".bg = "${../../assets/wallpaper} fill";

      keybindings = let
        pamixer = "${pkgs.pamixer}/bin/pamixer";
        player = "${pkgs.playerctl}/bin/playerctl --player='spotify,mpd,%any'";
        inherit (cfg.config) modifier;
      in {
        Print = ''
          exec wayshot -c -s "`slurp -f '%x %y %w %h'`" --stdout | wl-copy -t image/png'';
        "Shift+Print" = ''
          exec wayshot -c -s "`slurp -f '%x %y %w %h'`" --stdout | swappy -f - -o - | wl-copy -t image/png'';
        XF86AudioRaiseVolume = "exec ${pamixer} -i 2";
        XF86AudioLowerVolume = "exec ${pamixer} -d 2";
        "${modifier}+Shift+Backspace" = "exec ${pkgs.systemd}/bin/shutdown -h now";
        XF86AudioMute = "exec ${pamixer} -t";
        XF86AudioStop = "exec ${player} stop";
        XF86AudioPrev = "exec ${player} previous";
        XF86AudioPlay = "exec ${player} play-pause";
        XF86AudioNext = "exec ${player} next";
        XF86MonBrightnessUp = "exec light -A 5";
        XF86MonBrightnessDown = "exec light -U 5";
        "${modifier}+Return" = "exec ${lib.getExe pkgs.alacritty}";
        "${modifier}+Space" = "exec ${pkgs.fuzzel}/bin/fuzzel";
        "${modifier}+shift+escape" = "exit";
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        "${modifier}+u" = "focus mode_toggle";
        "${modifier}+z" = "workspace 1";
        "${modifier}+x" = "workspace 2";
        "${modifier}+c" = "workspace 3";
        "${modifier}+v" = "workspace 4";
        "${modifier}+b" = "workspace 5";
        "${modifier}+bracketright" = "workspace next";
        "${modifier}+bracketleft" = "workspace prev";
        "${modifier}+w" = "kill";
        "${modifier}+s" = "sticky toggle";
        "${modifier}+d" = "floating toggle";
        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+shift+h" = "move left";
        "${modifier}+shift+j" = "move down";
        "${modifier}+shift+k" = "move up";
        "${modifier}+shift+l" = "move right";
        "${modifier}+shift+z" = "move window to workspace 1";
        "${modifier}+shift+x" = "move window to workspace 2";
        "${modifier}+shift+c" = "move window to workspace 3";
        "${modifier}+shift+v" = "move window to workspace 4";
        "${modifier}+shift+b" = "move window to workspace 5";
        "${modifier}+left" = "resize shrink width 5";
        "${modifier}+right" = "resize grow width 5";
        "${modifier}+up" = "resize grow height 5";
        "${modifier}+down" = "resize shrink height 5";
      };
    };
    extraConfig = ''
      exec ${getExe pkgs.autotiling-rs}
      workspace number 1
    '';
  };

  services.mako = {
    enable = true;
    borderColor = "#f7cde4";
    backgroundColor = "#543245";
    layer = "overlay";
  };
  services.playerctld.enable = config.programs.waybar.enable;
}
