-- Базовые настройки

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

-- В связке с Nix плагины уже физически лежат в /nix/store и
-- добавлены в rtp через programs.neovim.plugins.
-- lazy.nvim здесь используется не для скачивания плагинов из интернета,
-- а как удобный загрузчик/структуризатор конфигурации (lazy loading,
-- keys, ft, cmd и т.д. всё ещё работают на уже установленных пакетах).

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- Если lazy.nvim ставится через Nix (plugins = [ lazy-nvim ]),
  -- он уже доступен в rtp, поэтому клонирование не требуется.
  -- Эта проверка — просто защита для не-Nix окружений.
end

require("lazy").setup("plugins", {
  -- Указываем lazy.nvim не пытаться сам управлять установкой/обновлением,
  -- т.к. все плагины уже предоставлены Nix
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
