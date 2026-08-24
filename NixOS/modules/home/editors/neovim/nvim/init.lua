-- ~/.config/nvim/init.lua

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Отключаем провайдеры, которые не используются (нет плагинов на
-- node/ruby/perl/python), чтобы :checkhealth не показывал лишних
-- warning/error про отсутствующие интерпретаторы.
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0


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

  pkg = { enabled = false },   -- stop injecting bundled lazy.lua/rockspec specs (v11 feature)
  rocks = { enabled = false }, -- no luarocks/hererocks needed; all plugins come from Nix
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

-- Автостарт :Obsession — пишет Session.vim в cwd и держит его актуальным.
-- Без этого tmux-resurrect (@resurrect-strategy-nvim 'session') не сможет
-- восстановить nvim: ему просто нечего будет открывать через `nvim -S`.
--
-- Чтобы Session.vim не мусорил в репозиториях, он автоматически добавляется
-- в .git/info/exclude — локальные игноры git: файлы не трогаем, .gitignore
-- не меняем, работает даже там, где нет прав на коммиты.
local function exclude_session_vim()
  local git_dir = vim.fn.trim(vim.fn.system({ 'git', 'rev-parse', '--absolute-git-dir' }))
  if vim.v.shell_error ~= 0 or git_dir == '' then
    return -- не git-репозиторий — игнорировать нечего
  end
  local exclude = git_dir .. '/info/exclude'
  vim.fn.mkdir(vim.fn.fnamemodify(exclude, ':h'), 'p')
  local f = io.open(exclude, 'r')
  local content = f and f:read('*a') or ''
  if f then
    f:close()
  end
  if not content:find('Session%.vim') then
    local w = io.open(exclude, 'a')
    if w then
      if content ~= '' and content:sub(-1) ~= '\n' then
        w:write('\n')
      end
      w:write('# nvim session file (added automatically by init.lua)\nSession.vim\n')
      w:close()
    end
  end
end

vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Auto-start Obsession session tracking for tmux-resurrect',
  group = vim.api.nvim_create_augroup('obsession-autostart', { clear = true }),
  callback = function()
    -- не трогаем случаи вроде `nvim -` (stdin) или сложных многофайловых
    -- вызовов, где явное mksession может быть нежелательно
    if vim.fn.argc() <= 1 and vim.fn.exists(':Obsession') == 2 then
      vim.cmd('Obsession')
      exclude_session_vim()
    end
  end,
})

-- Подстраховка: если Obsession запущен вручную (или сессия сохраняется
-- после пересоздания), исключение всё равно проставится перед каждой записью.
vim.api.nvim_create_autocmd('User', {
  desc = 'Keep Session.vim out of git via .git/info/exclude',
  group = vim.api.nvim_create_augroup('obsession-git-exclude', { clear = true }),
  pattern = 'ObsessionPreSave',
  callback = exclude_session_vim,
})

