-- lua/plugins/colorscheme.lua
--
-- Все colorscheme-плагины загружаются eagerly (lazy = false), т.к. один из
-- них обязан быть активен при старте. Реальное применение/переключение темы
-- делает lua/theme-switcher.lua — этот файл только регистрирует плагины и
-- запускает switcher на VimEnter.

return {
  {
    "rose-pine",
    dir = plugin_path("rose-pine"),
    name = "rose-pine",
    lazy = false,
    priority = 1000,
  },
  {
    "gruvbox-nvim",
    dir = plugin_path("gruvbox-nvim"),
    name = "gruvbox",
    lazy = false,
    priority = 1000,
  },
  {
    "nightfox-nvim",
    dir = plugin_path("nightfox-nvim"),
    name = "nightfox",
    lazy = false,
    priority = 1000,
  },
  {
    "kanagawa-nvim",
    dir = plugin_path("kanagawa-nvim"),
    name = "kanagawa",
    lazy = false,
    priority = 1000,
  },
  {
    "catppuccin-nvim",
    dir = plugin_path("catppuccin-nvim"),
    name = "catppuccin",
    lazy = false,
    priority = 1000,
  },
  {
    "tokyonight-nvim",
    dir = plugin_path("tokyonight-nvim"),
    name = "tokyonight",
    lazy = false,
    priority = 1000,
  },
  {
    "nord-nvim",
    dir = plugin_path("nord-nvim"),
    name = "nord",
    lazy = false,
    priority = 1000,
  },
  {
    "neovim-ayu",
    dir = plugin_path("neovim-ayu"),
    name = "ayu",
    lazy = false,
    priority = 1000,
  },
}
