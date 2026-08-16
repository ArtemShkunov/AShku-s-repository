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
opt.shiftwidth = 4
opt.tabstop = 4 
opt.softtabstop = 4
opt.smartindent = true

opt.wrap = false
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 50
opt.timeoutlen = 300

opt.splitright = true
opt.splitbelow = true
opt.clipboard = "unnamedplus"
opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 8


vim.o.breakindent = true


vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.o.cursorline = true


require("remaps")

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


vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },

    -- Can switch between these as you prefer
    virtual_text = true, -- Text shows up at the end of the line
    virtual_lines = false, -- Text shows up underneath the line, with virtual lines

    -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
    jump = {
        on_jump = function(_, bufnr)
            vim.diagnostic.open_float {
                bufnr = bufnr,
                scope = 'cursor',
                focus = false,
            }
        end,
    },
}


vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })


 vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })

