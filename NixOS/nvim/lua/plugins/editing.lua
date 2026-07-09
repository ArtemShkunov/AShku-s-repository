return {
  {
    "windwp/nvim-autopairs",
    name = "nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  {
    "kylechui/nvim-surround",
    name = "nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  {
    "numToStr/Comment.nvim",
    name = "comment-nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup({})
    end,
  },
}
