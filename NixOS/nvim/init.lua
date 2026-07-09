-- ~/.config/nvim/init.lua

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.ignorecase = true
opt.smartcase = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.clipboard = "unnamedplus"
opt.undofile = true

-- Пути к плагинам, установленным через Nix (сгенерировано из neovim.nix).
-- Экспортируем глобально, чтобы файлы в lua/plugins/*.lua могли
-- использовать plugin_path("nvim-lspconfig") вместо "owner/repo".
local plugin_paths = require("plugin-paths")

_G.plugin_path = function(name)
  local path = plugin_paths[name]
  if not path then
    error("Плагин '" .. name .. "' не найден в plugin-paths.lua (проверь neovim.nix)")
  end
  return path
end

-- lazy.nvim тоже установлен через Nix — добавляем его в rtp вручную,
-- т.к. он должен быть доступен ДО вызова require("lazy")
vim.opt.rtp:prepend(plugin_paths["lazy-nvim"])

require("lazy").setup("plugins", {
  -- Все плагины уже установлены Nix'ом, lazy.nvim не должен
  -- пытаться их скачивать или обновлять
  install = { missing = false },
  checker = { enabled = false },
  change_detection = { notify = false },
  performance = {
    reset_packpath = false,
    rtp = {
      reset = false,
    },
  },
})
