return {
  {
    "noice-nvim",
    dir = plugin_path("noice-nvim"),
    name = "noice-nvim",
    event = "VeryLazy",
    dependencies = {
      { "nui-nvim", dir = plugin_path("nui-nvim"), name = "nui-nvim" },
      { "nvim-notify", dir = plugin_path("nvim-notify"), name = "nvim-notify" },
    },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          lsp_doc_border = true,
        },
      })

      require("notify").setup({
        background_colour = "#000000",
      })
      vim.notify = require("notify")
    end,
  },
}
