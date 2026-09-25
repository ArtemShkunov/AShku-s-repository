return {
  {
    "nvim-web-devicons",
    dir = plugin_path("nvim-web-devicons"),
    name = "nvim-web-devicons",
    lazy = false,
    config = function()
      require("nvim-web-devicons").setup({
        default = true,
      })
    end,
  },

  {
    "lualine-nvim",
    dir = plugin_path("lualine-nvim"),
    name = "lualine-nvim",
    event = "VeryLazy",
    dependencies = {
      { "nvim-web-devicons", dir = plugin_path("nvim-web-devicons"), name = "nvim-web-devicons" },
    },
    config = function()
      local function show_recording()
        local reg = vim.fn.reg_recording()
        if reg == "" then
          return ""
        end
        return "REC @" .. reg
      end

      require("lualine").setup({
        options = { theme = "auto" },
        sections = {
          lualine_x = { show_recording, "encoding", "fileformat", "filetype" },
        },
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
