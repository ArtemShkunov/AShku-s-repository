return {
    {
        "nvim-lspconfig",
        dir = plugin_path("nvim-lspconfig"),
        name = "nvim-lspconfig",
        lazy = false,
        config = function()
            -- nvim-lspconfig в новых версиях (Neovim 0.11+) используется не
            -- через require("lspconfig")[server].setup(), а как поставщик
            -- готовых конфигов для нативного vim.lsp.config()/vim.lsp.enable().
            -- Старый API (lspconfig[server].setup) объявлен deprecated и
            -- будет удалён в lspconfig v3.0.0.
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            vim.lsp.config("*", {
                capabilities = capabilities,
            })

            vim.lsp.config("nixd", {
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

            -- clangd не находит стандартные заголовки (iostream и т.п.) на NixOS,
            -- потому что сам по себе не знает про include-пути, которые Nix
            -- подставляет компилятору через cc-wrapper. Решаем через --query-driver:
            -- clangd будет спрашивать реальный компилятор из PATH о его системных
            -- include-путях и использовать их.
            vim.lsp.config("clangd", {
                filetypes = { "c", "cpp", "objc", "objcpp" },
                cmd = {
                    "clangd",
                    "--query-driver=/nix/store/**/bin/*",
                    "--header-insertion=never",
                    "--background-index",
                },
            })

            vim.lsp.enable({
                "clangd",  -- C / C++ (пакет: clang-tools)
                "pyright", -- Python  (пакет: pyright)
                "lua_ls",  -- Lua     (пакет: lua-language-server)
                "nixd",    -- Nix
                "ruff",    -- тоже Python
                "bashls",  -- Bash
                "marksman", -- Markdown
            })

            -- Убираем составные filetype'ы (c.doxygen, cpp.doxygen,
            -- markdown.mdx), которых нет в рантайме — иначе :checkhealth
            -- vim.lsp ругается "Unknown filetype".
            vim.lsp.config("marksman", {
                filetypes = { "markdown" },
            })

            vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
            vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
            vim.keymap.set("n", "gr", vim.lsp.buf.references, {})
            vim.keymap.set({ "n", "v" }, "<leader>fmt", function()
                vim.lsp.buf.format({ async = true })
            end, { desc = "Format buffer" })
        end,
    },

    {
        "nvim-cmp",
        dir = plugin_path("nvim-cmp"),
        name = "nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            { "cmp-nvim-lsp", dir = plugin_path("cmp-nvim-lsp"), name = "cmp-nvim-lsp" },
            { "LuaSnip", dir = plugin_path("LuaSnip"), name = "LuaSnip" },
            { "cmp_luasnip", dir = plugin_path("cmp_luasnip"), name = "cmp_luasnip" },
            { "friendly-snippets", dir = plugin_path("friendly-snippets"), name = "friendly-snippets" },
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
        "none-ls-nvim",
        dir = plugin_path("none-ls-nvim"),
        name = "none-ls-nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local null_ls = require("null-ls")
            null_ls.setup({
                sources = {
                    -- C / C++
                    null_ls.builtins.formatting.clang_format.with({
                        extra_args = { "--style=Microsoft" },
                    }),
                    null_ls.builtins.diagnostics.cppcheck,

                    -- Lua
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.diagnostics.selene,

                    -- Nix
                    null_ls.builtins.formatting.nixfmt,
                    null_ls.builtins.diagnostics.statix,
                    null_ls.builtins.diagnostics.deadnix,

                    -- Shell
                    null_ls.builtins.formatting.shfmt,
                },
            })
        end,
    },
}
