return {
  {
    "lewis6991/gitsigns.nvim",
    name = "gitsigns-nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({})
    end,
  },

  {
    "tpope/vim-fugitive",
    name = "vim-fugitive",
    cmd = { "Git", "Gstatus", "Gblame", "Gpush", "Gpull" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
    },
  },
}
