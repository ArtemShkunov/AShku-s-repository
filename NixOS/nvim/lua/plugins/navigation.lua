return {
  {
    "telescope-nvim",
    dir = plugin_path("telescope-nvim"),
    name = "telescope-nvim",
    dependencies = {
      { "plenary-nvim", dir = plugin_path("plenary-nvim"), name = "plenary-nvim" },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    },
    config = function()
      require("telescope").setup({})
    end,
  },

  {
    "nvim-tree-lua",
    dir = plugin_path("nvim-tree-lua"),
    name = "nvim-tree-lua",
    dependencies = {
      { "nvim-web-devicons", dir = plugin_path("nvim-web-devicons"), name = "nvim-web-devicons" },
    },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
    },
    config = function()
      require("nvim-tree").setup({})
    end,
  },
}
