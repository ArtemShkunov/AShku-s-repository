return {
  {
    "telescope-nvim",
    dir = plugin_path("telescope-nvim"),
    name = "telescope-nvim",
    dependencies = {
      { "plenary-nvim", dir = plugin_path("plenary-nvim"), name = "plenary-nvim" },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    },
    config = function()
      require("telescope").setup({})
    end,
  },

  {
    "nvim-tree-lua",
    dir = plugin_path("nvim-tree-lua"),
    name = "nvim-tree-lua",
    dependencies = {
      { "nvim-web-devicons", dir = plugin_path("nvim-web-devicons"), name = "nvim-web-devicons" },
    },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
    },
    config = function()
      require("nvim-tree").setup({})
    end,
  },


{
  "harpoon2",
  dir = plugin_path("harpoon2"),
  name = "harpoon2",
  dependencies = {
    { "plenary-nvim", dir = plugin_path("plenary-nvim"), name = "plenary-nvim" },
  },
  keys = {
    { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon: добавить файл" },
    { "<leader>hh", function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, desc = "Harpoon: меню" },
    { "<leader>h1", function() require("harpoon"):list():select(1) end, desc = "Harpoon: файл 1" },
    { "<leader>h2", function() require("harpoon"):list():select(2) end, desc = "Harpoon: файл 2" },
    { "<leader>h3", function() require("harpoon"):list():select(3) end, desc = "Harpoon: файл 3" },
    { "<leader>h4", function() require("harpoon"):list():select(4) end, desc = "Harpoon: файл 4" },
    { "<leader>hp", function() require("harpoon"):list():prev() end, desc = "Harpoon: предыдущий" },
    { "<leader>hn", function() require("harpoon"):list():next() end, desc = "Harpoon: следующий" },
  },
  config = function()
    require("harpoon"):setup()
  end,
},

{
  "undotree",
  dir = plugin_path("undotree"),
  name = "undotree",
  cmd = "UndotreeToggle",
  keys = {
    { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
  },
  config = function()
    vim.g.undotree_SetFocusWhenToggle = 1
  end,
},
}
