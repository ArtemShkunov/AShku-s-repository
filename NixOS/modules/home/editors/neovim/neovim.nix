{ config, pkgs, ... }:

let
  # CodeLLDB adapter binary (bundled inside the vscode extension)
  codelldbWrapper = pkgs.runCommandLocal "codelldb" { } ''
        mkdir -p $out/bin
        cat > $out/bin/codelldb <<EOF
    #!${pkgs.runtimeShell}
    exec ${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb "\$@"
    EOF
        chmod +x $out/bin/codelldb
  '';

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
    harpoon2 = harpoon2;
    undotree = undotree;

    vim-obsession = vim-obsession;

    gitsigns-nvim = gitsigns-nvim;

    lualine-nvim = lualine-nvim;
    which-key-nvim = which-key-nvim;

    nvim-autopairs = nvim-autopairs;
    nvim-surround = nvim-surround;
    indent-blankline-nvim = indent-blankline-nvim;
    comment-nvim = comment-nvim;

    nvim-treesitter = nvim-treesitter.withPlugins (p: [
      p.c
      p.cpp
      p.python
      p.lua
      p.nix
      p.bash
      p.markdown
      p.vim
      p.query
      p.markdown_inline
    ]);
    nvim-treesitter-textobjects = nvim-treesitter-textobjects;

    noice-nvim = noice-nvim;
    nui-nvim = nui-nvim;
    nvim-notify = nvim-notify;

    dressing-nvim = dressing-nvim;
    rose-pine = rose-pine;

    nvim-dap = nvim-dap;
    nvim-dap-ui = nvim-dap-ui;
    nvim-nio = nvim-nio;
    lazygit-nvim = lazygit-nvim;

    codelldb = codelldbWrapper;

    render-markdown-nvim = render-markdown-nvim;

    autolist-nvim = autolist-nvim;
    vim-table-mode = vim-table-mode;
  };

  # Генерируем Lua-таблицу вида:
  # return {
  #--   ["nvim-lspconfig"] = "/nix/store/.../nvim-lspconfig",
  #--   ...
  #-- }
  pluginPathsLua =
    "return {\n"
    + pkgs.lib.concatStrings (
      pkgs.lib.mapAttrsToList (name: pkg: "  [\"${name}\"] = \"${pkg}\",\n") vimPlugins
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
    source = ./nvim;
    recursive = true;
  };

  # Отдельно кладём сгенерированный файл с путями плагинов —
  # он будет require'иться из init.lua как "plugin-paths"
  home.file.".config/nvim/lua/plugin-paths.lua".source = pluginPathsFile;

  home.packages = with pkgs; [
    # --- C / C++ ---
    clang-tools
    cppcheck
    codelldbWrapper

    # --- Python ---
    pyright
    ruff

    # --- Lua ---
    lua-language-server
    stylua
    selene

    # --- Nix ---
    nixd
    nixfmt
    statix
    deadnix

    # --- Bash ---
    pkgs.bash-language-server
    shellcheck
    shfmt

    # --- Markdown ---
    marksman

    # tree-sitter CLI — нужен для :checkhealth nvim-treesitter (и TSInstall при необходимости)
    tree-sitter

    # Для копирования
    wl-clipboard
    xclip

    # external dependency for treesitter
    fd
  ];
}
