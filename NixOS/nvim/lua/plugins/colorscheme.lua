return {
  {
    "rose-pine",
    dir = plugin_path("rose-pine"),
    name = "rose-pine",
    lazy = false,
    priority = 1000, -- цветовая схема должна грузиться раньше остальных плагинов
    config = function()
      require("rose-pine").setup({
        variant = "auto", -- "main" | "moon" | "dawn" | "auto"
        dark_variant = "main",
      })

      vim.cmd("colorscheme rose-pine")
    end,
  },
}
