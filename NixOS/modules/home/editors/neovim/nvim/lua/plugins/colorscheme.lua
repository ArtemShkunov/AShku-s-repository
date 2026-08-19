return {
  {
    "rose-pine",
    dir = plugin_path("rose-pine"),
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "auto",
        dark_variant = "main",
        styles = {
          transparency = true,
        },
      })

      vim.cmd("colorscheme rose-pine")
    end,
  },
}
