return {
  {
    "nvim-autopairs",
    dir = plugin_path("nvim-autopairs"),
    name = "nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  {
    "nvim-surround",
    dir = plugin_path("nvim-surround"),
    name = "nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  {
    "comment-nvim",
    dir = plugin_path("comment-nvim"),
    name = "comment-nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup({})
    end,
  },

  {
    -- VimL-плагин без setup(): нужен загруженным на старте, чтобы
    -- autocmd в init.lua видел :Obsession и автостартовал сессию для
    -- tmux-resurrect (@resurrect-strategy-nvim 'session').
    "vim-obsession",
    dir = plugin_path("vim-obsession"),
    name = "vim-obsession",
    lazy = false,
  },
}
