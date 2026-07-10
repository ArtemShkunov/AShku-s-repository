return {
  {
    "nvim-treesitter",
    dir = plugin_path("nvim-treesitter"),
    name = "nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      {
        "nvim-treesitter-textobjects",
        dir = plugin_path("nvim-treesitter-textobjects"),
        name = "nvim-treesitter-textobjects",
      },
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {}, -- парсеры уже ставятся через Nix, доп. установка не нужна
        auto_install = false,  -- важно: не пытаться скачивать через :TSInstall
        highlight = { enable = true },
        indent = { enable = true },

        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
            },
          },
        },
      })
    end,
  },
}
