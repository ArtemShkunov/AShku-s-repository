return {
  {
    "render-markdown-nvim",
    dir = plugin_path("render-markdown-nvim"),
    name = "render-markdown-nvim",
    ft = { "markdown" },
    dependencies = {
      { "nvim-web-devicons", dir = plugin_path("nvim-web-devicons"), name = "nvim-web-devicons" },
    },
    config = function()
      require("render-markdown").setup({
        heading = { enabled = true },
        code = { enabled = true, style = "full" },
        bullet = { enabled = true },
      })
    end,
  },
}
