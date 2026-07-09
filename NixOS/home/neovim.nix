{ config, pkgs, ... }:

let
  # Список плагинов ОДИН РАЗ — используется и для установки через Nix,
  # и для генерации путей, которые скормим lazy.nvim.
  vimPlugins = with pkgs.vimPlugins; {
    lazy-nvim = lazy-nvim;

    nvim-lspconfig = nvim-lspconfig;
    nvim-cmp = nvim-cmp;
    cmp-nvim-lsp = cmp-nvim-lsp;
    cmp_luasnip = cmp_luasnip;
    LuaSnip = luasnip;
    friendly-snippets = friendly-snippets;
    none-ls-nvim = none-ls-nvim;

    telescope-nvim = telescope-nvim;
    plenary-nvim = plenary-nvim;
    nvim-tree-lua = nvim-tree-lua;
    nvim-web-devicons = nvim-web-devicons;

    gitsigns-nvim = gitsigns-nvim;
    vim-fugitive = vim-fugitive;

    lualine-nvim = lualine-nvim;
    bufferline-nvim = bufferline-nvim;
    which-key-nvim = which-key-nvim;

    nvim-autopairs = nvim-autopairs;
    nvim-surround = nvim-surround;
    indent-blankline-nvim = indent-blankline-nvim;
    comment-nvim = comment-nvim;
  };

  # Генерируем Lua-таблицу вида:
  # return {
  --   ["nvim-lspconfig"] = "/nix/store/.../nvim-lspconfig",
  --   ...
  -- }
  pluginPathsLua =
    "return {\n"
    + pkgs.lib.concatStrings (
      pkgs.lib.mapAttrsToList (
        name: pkg: "  [\"${name}\"] = \"${pkg}\",\n"
      ) vimPlugins
    )
    + "}\n";

  pluginPathsFile = pkgs.writeText "plugin-paths.lua" pluginPathsLua;

in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = builtins.attrValues vimPlugins;
  };

  # Весь каталог с lua-конфигом
  home.file.".config/nvim" = {
    source = ../nvim;
    recursive = true;
  };

  # Отдельно кладём сгенерированный файл с путями плагинов —
  # он будет require'иться из init.lua как "plugin-paths"
  home.file.".config/nvim/lua/plugin-paths.lua".source = pluginPathsFile;

  home.packages = with pkgs; [
    # --- C / C++ ---
    clang-tools
    cppcheck

    # --- Python ---
    pyright
    ruff

    # --- Lua ---
    lua-language-server
    stylua
    selene

    # --- Wayland ---
    wayland
    wayland-protocols
    wayland-scanner

    # --- Nix ---
    nixd
    nixfmt-rfc-style
    statix
    deadnix
  ];
}
