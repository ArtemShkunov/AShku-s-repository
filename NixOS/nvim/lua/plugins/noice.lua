-- ~/.config/nvim/lua/plugins/noice.lua

return {
  {
    "noice-nvim",
    dir = plugin_path("noice-nvim"),
    name = "noice-nvim",
    dependencies = {
      { "nvim-treesitter", dir = plugin_path("nvim-treesitter"), name = "nvim-treesitter" },
      { "nvim-web-devicons", dir = plugin_path("nvim-web-devicons"), name = "nvim-web-devicons" },
    },
    event = "VeryLazy",
    config = function()
      require("noice").setup({
        -- Настройка UI
        views = {
          cmdline_popup = {
            position = {
              row = "25%",
              col = "50%",
            },
            size = {
              width = 60,
              height = "auto",
            },
          },
          popupmenu = {
            relative = "editor",
            position = {
              row = 8,
              col = "50%",
            },
            size = {
              width = 60,
              height = 10,
            },
          },
        },

        -- Какие сообщения показывать
        messages = {
          view = "mini",  -- компактный вид для сообщений
          view_search = "virtualtext",  -- поиск показывать в virtual text
        },

        -- Командная строка
        cmdline = {
          view = "cmdline_popup",  -- всплывающее окно для команд
          format = {
            cmdline = { pattern = "^:", icon = "", lang = "vim" },
            search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
            search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
            filter = { pattern = "^:%s*!", icon = "", lang = "bash" },
            lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
            help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
            input = { pattern = "^%s*?", icon = "" },
          },
        },

        -- Уведомления
        notify = {
          view = "notify",
          enabled = true,
        },

        -- LSP
        lsp = {
          -- Показывать сигнатуры в popup
          signature = {
            enabled = true,
            auto_open = {
              trigger = true,  -- автоматически открывать
              luasnip = true,
              throttle = 50,
            },
            view = "auto",  -- auto, hover, or split
          },
          -- Показывать прогресс LSP
          progress = {
            enabled = true,
            view = "mini",
          },
          -- Показывать сообщения от LSP
          message = {
            enabled = true,
            view = "mini",
          },
          -- Документация при hover (заменяет стандартный K)
          hover = {
            enabled = true,
            silent = true,
            popup = {
              border = "rounded",
              position = "top_left",
            },
          },
        },

        -- Кастомные presets
        presets = {
          bottom_search = true,     -- поиск внизу экрана
          command_palette = true,   -- палитра команд
          long_message_to_split = true,  -- длинные сообщения в split
          inc_rename = false,       -- для плагина inc-rename
        },

        -- Стили
        styles = {
          border = {
            border = "rounded",
            winblend = 0,
          },
          cmdline = {
            border = "none",
            winblend = 0,
          },
        },

        -- Роутинг сообщений
        routes = {
          {
            view = "notify",
            filter = { event = "msg_showmode" },
          },
        },

        -- Здоровье (проверка зависимостей)
        health = {
          checker = true,
        },
      })

      -- 🔥 Горячие клавиши для Noice
      vim.keymap.set("n", "<S-Enter>", function()
        require("noice").redirect(vim.fn.getcmdline())
      end, { desc = "Redirect command line" })

      -- Показывать историю сообщений
      vim.keymap.set("n", "<leader>nh", function()
        require("noice").cmd("history")
      end, { desc = "Noice history" })

      -- Показать последнее сообщение
      vim.keymap.set("n", "<leader>nl", function()
        require("noice").cmd("last")
      end, { desc = "Noice last message" })
    end,
  },
}
