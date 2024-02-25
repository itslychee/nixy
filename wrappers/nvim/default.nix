{
  pkgs,
  lib,
  ...
}: {
  wrappers.nvim = let
    neovim = pkgs.neovimUtils.makeNeovimConfig {
      wrapRc = false;
      # See env.MYVIMRC for explanation
      vimAlias = true;
      viAlias = true;
      customRc = builtins.readFile ./vimrc;
      plugins = let
        inherit
          (pkgs.vimPlugins)
          git-conflict-nvim
          kanagawa-nvim
          bufferline-nvim
          telescope-nvim
          nvim-treesitter
          nvim-web-devicons
          ;
      in [
        {
          plugin = git-conflict-nvim;
          config = null;
          optional = false;
        }
        {
          plugin = nvim-web-devicons;
          config = null;
          optional = true;
        }
        {
          plugin = nvim-treesitter.withAllGrammars;
          config = null;
          optional = false;
        }
        {
          plugin = kanagawa-nvim;
          config = null;
          optional = false;
        }
        {
          plugin = bufferline-nvim;
          config = null;
          optional = false;
        }
        {
          plugin = telescope-nvim;
          config = null;
          optional = false;
        }
      ];
    };
  in {
    basePackage = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped neovim;
    # This feels like a cleaner approach as I can override
    # the configuration with flags.
    flags = [
      "-u"
      ./vimrc
    ];
    pathAdd = builtins.attrValues {
      inherit
        (pkgs)
        git
        ripgrep
        ;
    };
  };
}
