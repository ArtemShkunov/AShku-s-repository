return {
  {
    "nvim-lualine/lualine.nvim",
    name = "lualine-nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "auto" },
      })
    end,
  },

  {
    "akinsho/bufferline.nvim",
    name = "bufferline-nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({})
    end,
  },

  {
    "folke/which-key.nvim",
    name = "which-key-nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({})
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    name = "indent-blankline-nvim",
    main = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("ibl").setup({})
    end,
  },
}
