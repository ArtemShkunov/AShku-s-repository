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
}
