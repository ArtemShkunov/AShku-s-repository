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
    "vim-fugitive",
    dir = plugin_path("vim-fugitive"),
    name = "vim-fugitive",
    cmd = { "Git", "Gstatus", "Gblame", "Gpush", "Gpull" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
    },
  },
}
