return {
  {
    "gitsigns-nvim",
    dir = plugin_path("gitsigns-nvim"),
    name = "gitsigns-nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({})
    end,
  },

  {
    "lazygit-nvim",
    dir = plugin_path("lazygit-nvim"),
    name = "lazygit-nvim",
    cmd = { "LazyGit" },
    dependencies = {
      { "plenary-nvim", dir = plugin_path("plenary-nvim"), name = "plenary-nvim" },
    },
    keys = {
      { "<leader>gs", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
}
