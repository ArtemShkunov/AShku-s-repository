return {
  {
    "render-markdown-nvim",
    dir = plugin_path("render-markdown-nvim"),
    name = "render-markdown-nvim",
    ft = { "markdown" },
    dependencies = {
      { "nvim-web-devicons", dir = plugin_path("nvim-web-devicons"), name = "nvim-web-devicons" },
    },
    keys = {
      { "<leader>md", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown render", ft = "markdown" },
    },
    config = function()
      require("render-markdown").setup({
        heading = { enabled = true },
        code = { enabled = true, style = "full" },
        bullet = { enabled = true },
      })
    end,
  },

  {
    "autolist-nvim",
    dir = plugin_path("autolist-nvim"),
    name = "autolist-nvim",
    ft = { "markdown", "text", "gitcommit" },
    config = function()
      require("autolist").setup({})
    end,
  },

  {
    "vim-table-mode",
    dir = plugin_path("vim-table-mode"),
    name = "vim-table-mode",
    ft = { "markdown" },
    config = function()
      vim.g.table_mode_disable_tableize_mappings = 0
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.cmd("TableModeEnable")
        end,
      })
    end,
  },
}
