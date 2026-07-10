return {
  {
    "nvim-treesitter",
    dir = plugin_path("nvim-treesitter"),
    name = "nvim-treesitter",
    lazy = false,
    dependencies = {
      {
        "nvim-treesitter-textobjects",
        dir = plugin_path("nvim-treesitter-textobjects"),
        name = "nvim-treesitter-textobjects",
      },
    },
    config = function()
      -- Парсеры уже установлены через Nix, TSInstall не нужен.
      -- Включаем подсветку и отступы через нативный vim.treesitter API.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "python", "lua", "nix", "bash", "markdown", "vim" },
        callback = function(args)
          vim.treesitter.start(args.buf)
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      -- Textobjects: новый API настраивается напрямую через .setup(),
      -- без require("nvim-treesitter.configs")
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          selection_modes = {
            ["@parameter.outer"] = "v",
            ["@function.outer"] = "V",
            ["@class.outer"] = "V",
          },
          include_surrounding_whitespace = false,
        },
        move = {
          set_jumps = true,
        },
      })

      local select = require("nvim-treesitter-textobjects.select")

      vim.keymap.set({ "x", "o" }, "af", function()
        select.select_textobject("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "if", function()
        select.select_textobject("@function.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ac", function()
        select.select_textobject("@class.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ic", function()
        select.select_textobject("@class.inner", "textobjects")
      end)

      local move = require("nvim-treesitter-textobjects.move")

      vim.keymap.set({ "n", "x", "o" }, "]f", function()
        move.goto_next_start("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "n", "x", "o" }, "[f", function()
        move.goto_previous_start("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "n", "x", "o" }, "]c", function()
        move.goto_next_start("@class.outer", "textobjects")
      end)
      vim.keymap.set({ "n", "x", "o" }, "[c", function()
        move.goto_previous_start("@class.outer", "textobjects")
      end)
    end,
  },
}
