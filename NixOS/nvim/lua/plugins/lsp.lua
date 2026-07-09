return {
  {
    "neovim/nvim-lspconfig",
    name = "nvim-lspconfig",
    lazy = false,
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Сами language servers ставятся отдельно через home.packages
      -- (см. neovim.nix), здесь мы только настраиваем lspconfig.
      local servers = {
        "clangd",  -- C / C++ (пакет: clang-tools)
        "pyright", -- Python  (пакет: pyright)
        "lua_ls",  -- Lua     (пакет: lua-language-server)
      }

      for _, server in ipairs(servers) do
        lspconfig[server].setup({
          capabilities = capabilities,
        })
      end

      -- Отдельная настройка nixd (путь к nixpkgs, форматтер и т.д.)
      lspconfig.nixd.setup({
        capabilities = capabilities,
        settings = {
          nixd = {
            nixpkgs = {
              expr = "import <nixpkgs> { }",
            },
            formatting = {
              command = { "nixfmt" },
            },
          },
        },
      })

      vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
      vim.keymap.set("n", "gr", vim.lsp.buf.references, {})
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    name = "nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }),
      })
    end,
  },

  {
    "nvimtools/none-ls.nvim",
    name = "none-ls-nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          -- C / C++
          null_ls.builtins.formatting.clang_format,
          null_ls.builtins.diagnostics.cppcheck,

          -- Python
          null_ls.builtins.formatting.ruff_format,
          null_ls.builtins.diagnostics.ruff,

          -- Lua
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.diagnostics.selene,

          -- Nix
          null_ls.builtins.formatting.nixfmt,
          null_ls.builtins.diagnostics.statix,
          null_ls.builtins.diagnostics.deadnix,
        },
      })
    end,
  },
}
