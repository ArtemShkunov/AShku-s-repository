return {
  {
    "lualine-nvim",
    dir = plugin_path("lualine-nvim"),
    name = "lualine-nvim",
    event = "VeryLazy",
    dependencies = {
      { "nvim-web-devicons", dir = plugin_path("nvim-web-devicons"), name = "nvim-web-devicons" },
    },
    config = function()
      require("lualine").setup({
        options = { theme = "rose-pine" },
      })
    end,
  },

  {
    "bufferline-nvim",
    dir = plugin_path("bufferline-nvim"),
    name = "bufferline-nvim",
    event = "VeryLazy",
    dependencies = {
      { "nvim-web-devicons", dir = plugin_path("nvim-web-devicons"), name = "nvim-web-devicons" },
      "rose-pine",
    },
    config = function()
      require("bufferline").setup({
        highlights = require("rose-pine.plugins.bufferline"),
      })
    end,
  },

  {
    "which-key-nvim",
    dir = plugin_path("which-key-nvim"),
    name = "which-key-nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({})
    end,
  },

  {
    "indent-blankline-nvim",
    dir = plugin_path("indent-blankline-nvim"),
    name = "indent-blankline-nvim",
    main = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("ibl").setup({})
    end,
  },

  {
    "dressing-nvim",
    dir = plugin_path("dressing-nvim"),
    event = "VeryLazy",
    config = function ()
      require("dressing").setup({})
    end,
  },
}
