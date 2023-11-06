{ config, pkgs, flags, inputs, ... }:
with pkgs.lib;
{
  imports = [
    (import ../mixins/home/crypt.nix {
      git = {
        enable = true;
        userName = "Lychee";
        userEmail = "itslychee@protonmail.com";
        withDelta = true;
      };
    })
    ./programs.nix
    ./services.nix
    ./graphical.nix
    ./firefox.nix
    ./waybar.nix
    ./neovim.nix
    ./shell.nix
  ];
  # Git
  programs.git.ignores = [ "*.swp" ".envrc" ".direnv" ];
  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    desktop     = "${config.home.homeDirectory}/desktop";
    documents   = "${config.home.homeDirectory}/documents";
    download    = "${config.home.homeDirectory}/downloads";
    music       = "${config.home.homeDirectory}/media/music";
    videos      = "${config.home.homeDirectory}/media/videos";
    pictures    = "${config.home.homeDirectory}/media/images";
    templates   = "${config.home.homeDirectory}/media/templates";
    publicShare = "${config.home.homeDirectory}/pub";
  };

  home.packages = with pkgs; [ ]
    # Headless & Non-headless appliations
    ++ [
      neofetch nmap zip unzip gnutar 
      ruff
      screen
      (python311.withPackages(ps: with ps; [ pip ]))
    ]
    # MPD applications
    ++ optionals config.services.mpd.enable [ mpc-cli ]
    # Non-headless specific packages (desktop)
    ++ optionals (!flags.headless or false) [
    wayshot
    spotify
    slurp
    discord-canary
    grim
    wl-clipboard
    gimp-with-plugins
    kcolorchooser
    xdg-utils
  ]
    # Headless specific packages (server) 
    ++ optionals (flags.headless or false) [ ];
}
