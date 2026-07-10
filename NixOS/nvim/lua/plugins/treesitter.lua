return {
  {
    "nvim-treesitter",
    dir = plugin_path("nvim-treesitter"),
    name = "nvim-treesitter",
    lazy = false,
    config = function()
      -- Новый API: парсеры уже установлены через Nix, TSInstall не нужен.
      -- Просто включаем подсветку и отступы через нативный vim.treesitter.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "python", "lua", "nix", "bash", "markdown", "vim" },
        callback = function(args)
          vim.treesitter.start(args.buf)
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
