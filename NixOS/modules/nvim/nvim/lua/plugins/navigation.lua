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
    { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon: add file" },
    { "<leader>hh", function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, desc = "Harpoon: menu" },
    { "<C-1>", function() require("harpoon"):list():select(1) end, desc = "Harpoon: file 1" },
    { "<C-2>", function() require("harpoon"):list():select(2) end, desc = "Harpoon: file 2" },
    { "<C-3>", function() require("harpoon"):list():select(3) end, desc = "Harpoon: file 3" },
    { "<C-4>", function() require("harpoon"):list():select(4) end, desc = "Harpoon: file 4" },
    { "<C-5>", function() require("harpoon"):list():select(5) end, desc = "Harpoon: file 5" },
    { "<C-6>", function() require("harpoon"):list():select(6) end, desc = "Harpoon: file 6" },
    { "<C-7>", function() require("harpoon"):list():select(7) end, desc = "Harpoon: file 7" },
    { "<C-8>", function() require("harpoon"):list():select(8) end, desc = "Harpoon: file 8" },
    { "<C-9>", function() require("harpoon"):list():select(9) end, desc = "Harpoon: file 9" },
    { "<C-p>", function() require("harpoon"):list():prev() end, desc = "Harpoon: previous file" },
    { "<C-n>", function() require("harpoon"):list():next() end, desc = "Harpoon: next file" },
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
