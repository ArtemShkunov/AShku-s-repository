-- lua/theme-switcher.lua
--
-- Централизованный переключатель темы для nvim.
-- Список тем ниже — единственный источник правды: каждый вариант каждой
-- темы регистрируется отдельной записью (можно выбрать/переключить любой
-- конкретный вариант, а не только "основную" тему).

local M = {}

-- name        -> имя, показываемое в :Colorscheme picker
-- colorscheme -> имя, передаваемое в vim.cmd.colorscheme
-- setup       -> (опционально) функция настройки плагина перед применением темы
M.themes = {
  -- Rose Pine
  {
    name = "Rose Pine",
    colorscheme = "rose-pine",
    setup = function()
      require("rose-pine").setup({ styles = { transparency = true } })
    end,
  },
  {
    name = "Rose Pine (Main)",
    colorscheme = "rose-pine-main",
    setup = function()
      require("rose-pine").setup({ styles = { transparency = true } })
    end,
  },
  {
    name = "Rose Pine (Moon)",
    colorscheme = "rose-pine-moon",
    setup = function()
      require("rose-pine").setup({ styles = { transparency = true } })
    end,
  },
  {
    name = "Rose Pine (Dawn)",
    colorscheme = "rose-pine-dawn",
    setup = function()
      require("rose-pine").setup({ styles = { transparency = true } })
    end,
  },

  -- Gruvbox (единственный colorscheme; light/dark управляется background)
  {
    name = "Gruvbox",
    colorscheme = "gruvbox",
    setup = function()
      require("gruvbox").setup({ transparent_mode = true })
    end,
  },

  -- Nightfox family
  {
    name = "Nightfox",
    colorscheme = "nightfox",
  },
  {
    name = "Nightfox (Day)",
    colorscheme = "dayfox",
  },
  {
    name = "Nightfox (Dawn)",
    colorscheme = "dawnfox",
  },
  {
    name = "Nightfox (Dusk)",
    colorscheme = "duskfox",
  },
  {
    name = "Nightfox (Nord)",
    colorscheme = "nordfox",
  },
  {
    name = "Nightfox (Tera)",
    colorscheme = "terafox",
  },
  {
    name = "Nightfox (Carbon)",
    colorscheme = "carbonfox",
  },

  -- Kanagawa
  {
    name = "Kanagawa",
    colorscheme = "kanagawa",
    setup = function()
      require("kanagawa").setup({ transparent = true })
    end,
  },
  {
    name = "Kanagawa (Wave)",
    colorscheme = "kanagawa-wave",
    setup = function()
      require("kanagawa").setup({ transparent = true })
    end,
  },
  {
    name = "Kanagawa (Dragon)",
    colorscheme = "kanagawa-dragon",
    setup = function()
      require("kanagawa").setup({ transparent = true })
    end,
  },
  {
    name = "Kanagawa (Lotus)",
    colorscheme = "kanagawa-lotus",
    setup = function()
      require("kanagawa").setup({ transparent = true })
    end,
  },

  -- Catppuccin
  {
    name = "Catppuccin",
    colorscheme = "catppuccin",
    setup = function()
      require("catppuccin").setup({ transparent_background = true })
    end,
  },
  {
    name = "Catppuccin (Latte)",
    colorscheme = "catppuccin-latte",
    setup = function()
      require("catppuccin").setup({ flavour = "latte", transparent_background = true })
    end,
  },
  {
    name = "Catppuccin (Frappe)",
    colorscheme = "catppuccin-frappe",
    setup = function()
      require("catppuccin").setup({ flavour = "frappe", transparent_background = true })
    end,
  },
  {
    name = "Catppuccin (Macchiato)",
    colorscheme = "catppuccin-macchiato",
    setup = function()
      require("catppuccin").setup({ flavour = "macchiato", transparent_background = true })
    end,
  },
  {
    name = "Catppuccin (Mocha)",
    colorscheme = "catppuccin-mocha",
    setup = function()
      require("catppuccin").setup({ flavour = "mocha", transparent_background = true })
    end,
  },

  -- Tokyo Night
  {
    name = "Tokyo Night",
    colorscheme = "tokyonight",
    setup = function()
      require("tokyonight").setup({ transparent = true })
    end,
  },
  {
    name = "Tokyo Night (Night)",
    colorscheme = "tokyonight-night",
    setup = function()
      require("tokyonight").setup({ style = "night", transparent = true })
    end,
  },
  {
    name = "Tokyo Night (Storm)",
    colorscheme = "tokyonight-storm",
    setup = function()
      require("tokyonight").setup({ style = "storm", transparent = true })
    end,
  },
  {
    name = "Tokyo Night (Moon)",
    colorscheme = "tokyonight-moon",
    setup = function()
      require("tokyonight").setup({ style = "moon", transparent = true })
    end,
  },
  {
    name = "Tokyo Night (Day)",
    colorscheme = "tokyonight-day",
    setup = function()
      require("tokyonight").setup({ style = "day", transparent = true })
    end,
  },

  -- Nord (единственный colorscheme; вариаций-файлов colors/ нет)
  {
    name = "Nord",
    colorscheme = "nord",
    setup = function()
      vim.g.nord_disable_background = true
    end,
  },

  -- Ayu
  {
    name = "Ayu",
    colorscheme = "ayu",
  },
  {
    name = "Ayu (Dark)",
    colorscheme = "ayu-dark",
  },
  {
    name = "Ayu (Light)",
    colorscheme = "ayu-light",
  },
  {
    name = "Ayu (Mirage)",
    colorscheme = "ayu-mirage",
  },
}

local state_file = vim.fn.stdpath("state") .. "/nvim-theme.txt"
local default_colorscheme = "rose-pine"

-- Индекс текущей темы в M.themes. vim.g.colors_name не годится для этого:
-- некоторые плагины (catppuccin, tokyonight) выставляют вариант-специфичное
-- имя (напр. "catppuccin-mocha"), которое не совпадает с t.colorscheme.
local current_index = 1

local function find_theme(colorscheme)
  for _, t in ipairs(M.themes) do
    if t.colorscheme == colorscheme then
      return t
    end
  end
  return nil
end

-- Применяет тему по имени colorscheme, запускает её setup() (если задан)
-- и обновляет lualine, чтобы оформление статус-бара совпадало.
function M.apply(colorscheme, opts)
  opts = opts or {}
  local theme = find_theme(colorscheme)
  if not theme then
    vim.notify("theme-switcher: неизвестная тема '" .. tostring(colorscheme) .. "'", vim.log.levels.WARN)
    return false
  end

  if theme.setup then
    local ok, err = pcall(theme.setup)
    if not ok then
      vim.notify("theme-switcher: ошибка setup() для '" .. theme.name .. "': " .. tostring(err), vim.log.levels.ERROR)
    end
  end

  local ok_cs, err_cs = pcall(vim.cmd.colorscheme, theme.colorscheme)
  if not ok_cs then
    vim.notify("theme-switcher: не удалось применить '" .. theme.colorscheme .. "': " .. tostring(err_cs), vim.log.levels.ERROR)
    return false
  end

  -- lualine настроен на theme = "auto" — просто перезагружаем его,
  -- чтобы статус-бар подхватил новые highlight-группы.
  local has_lualine, lualine = pcall(require, "lualine")
  if has_lualine then
    lualine.refresh()
  end

  for i, t in ipairs(M.themes) do
    if t.colorscheme == theme.colorscheme then
      current_index = i
      break
    end
  end

  if not opts.skip_persist then
    local f = io.open(state_file, "w")
    if f then
      f:write(theme.colorscheme)
      f:close()
    end
  end

  return true
end

function M.load_saved()
  local f = io.open(state_file, "r")
  if f then
    local saved = vim.trim(f:read("*a") or "")
    f:close()
    if saved ~= "" and find_theme(saved) then
      return saved
    end
  end
  return default_colorscheme
end

-- Интерактивный выбор темы через vim.ui.select (:Colorscheme)
function M.pick()
  local items = {}
  for _, t in ipairs(M.themes) do
    table.insert(items, t)
  end

  vim.ui.select(items, {
    prompt = "Выбери тему:",
    format_item = function(t)
      return t.name
    end,
  }, function(choice)
    if choice then
      M.apply(choice.colorscheme)
    end
  end)
end

-- Переключение по кругу на следующую тему в списке (<leader>th)
function M.next()
  local next_theme = M.themes[(current_index % #M.themes) + 1]
  M.apply(next_theme.colorscheme)
  vim.notify("Тема: " .. next_theme.name)
end

-- Переключение по кругу на предыдущую тему в списке (<leader>tH)
function M.prev()
  local prev_theme = M.themes[((current_index - 2) % #M.themes) + 1]
  M.apply(prev_theme.colorscheme)
  vim.notify("Тема: " .. prev_theme.name)
end

function M.setup()
  vim.api.nvim_create_user_command("Colorscheme", M.pick, { desc = "Выбрать тему nvim" })
  vim.keymap.set("n", "<leader>th", M.next, { desc = "Следующая тема" })
  vim.keymap.set("n", "<leader>tH", M.prev, { desc = "Предыдущая тема" })
  vim.keymap.set("n", "<leader>tp", M.pick, { desc = "Выбрать тему из списка" })
end

return M
