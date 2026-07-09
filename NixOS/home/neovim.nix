{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;


    plugins = with pkgs.vimPlugins; [
      # Менеджер плагинов (lazy.nvim ставится тоже как обычный плагин;
      # это позволяет Nix полностью управлять версией/загрузкой,
      # но сам lazy.nvim используется только как загрузчик остальных)
      lazy-nvim

      # LSP и автодополнение
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp_luasnip
      luasnip
      friendly-snippets
      none-ls-nvim

      # Навигация
      telescope-nvim
      plenary-nvim   # зависимость telescope
      nvim-tree-lua
      nvim-web-devicons # иконки для tree/telescope/bufferline

      # Git
      gitsigns-nvim
      vim-fugitive

      # Внешний вид
      lualine-nvim
      bufferline-nvim
      which-key-nvim

      # Редактирование
      nvim-autopairs
      nvim-surround
      indent-blankline-nvim
      comment-nvim
    ];
  };

  # Файл конфигурации плагинов (init.lua) кладём рядом,
  # чтобы home-manager его тоже отслеживал и линковал
  home.file.".config/nvim" = {
    source = ../nvim;
    recursive = true;
  }
}

