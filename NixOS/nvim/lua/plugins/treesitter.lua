-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
  {
    "nvim-treesitter",
    dir = plugin_path("nvim-treesitter"),
    name = "nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,  -- загружаем сразу для подсветки синтаксиса
    config = function()
      require("nvim-treesitter.configs").setup({
        -- Подсветка синтаксиса
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },

        -- Отступы (если нужно)
        indent = {
          enable = true,
        },

        -- Настройки для textobjects
        textobjects = {
          select = {
            enable = true,

            -- Автоматические маппинги для выбора текстовых объектов
            keymaps = {
              -- Выбор по синтаксическим конструкциям
              ["af"] = "@function.outer",   -- выбрать функцию целиком
              ["if"] = "@function.inner",   -- выбрать тело функции
              ["ac"] = "@class.outer",      -- выбрать класс целиком
              ["ic"] = "@class.inner",      -- выбрать тело класса
              ["aa"] = "@parameter.outer",  -- выбрать параметр
              ["ia"] = "@parameter.inner",  -- выбрать параметр (внутренняя часть)
            },

            -- Включить выбор по движению
            move = {
              enable = true,
              set_jumps = true,

              -- Перемещение между функциями
              goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = "@class.outer",
              },
              goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = "@class.outer",
              },
              goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = "@class.outer",
              },
              goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = "@class.outer",
              },
            },

            -- Включить swap (перестановку) объектов
            swap = {
              enable = true,
              swap_next = {
                ["<leader>a"] = "@parameter.outer",  -- поменять местами параметры
              },
              swap_previous = {
                ["<leader>A"] = "@parameter.outer",
              },
            },
          },
        },
      })

      -- Дополнительно: включить автоматическое обновление парсеров
      vim.cmd("TSUpdate")
    end,
  },

  {
    "nvim-treesitter-textobjects",
    dir = plugin_path("nvim-treesitter-textobjects"),
    name = "nvim-treesitter-textobjects",
    dependencies = {
      { "nvim-treesitter", dir = plugin_path("nvim-treesitter"), name = "nvim-treesitter" },
    },
    lazy = false,  -- загружаем вместе с treesitter
    config = function()
      -- Конфигурация уже в nvim-treesitter.configs.setup() выше
      -- Этот плагин просто расширяет функциональность
    end,
  },
}
