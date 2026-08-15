-- lua/remaps.lua


-- Удаление в черную дыру
vim.keymap.set({ "n", "v" }, "<leader>vd", [["_d]])

-- Открыть netrw (быстрый файловый браузер)
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Перемещение выделенных строк вверх/вниз
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- J больше не двигает курсор
vim.keymap.set("n", "J", "mzJ`z")

-- Полстраницы вниз/вверх с центрированием курсора
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Поиск с центрированием
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Вставка в visual-режиме без потери yank-регистра
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Отключаем Ex-режим (Q)
vim.keymap.set("n", "Q", "<nop>")

-- Навигация по quickfix / location list
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>lk", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>lj", "<cmd>lprev<CR>zz")

-- Поиск/замена слова под курсором во всём файле
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Переключения по буферам из BufferLine
vim.keymap.set("n", "<leader>b1", "<cmd>BufferLineGoToBuffer1")
vim.keymap.set("n", "<leader>b2", "<cmd>BufferLineGoToBuffer2")
vim.keymap.set("n", "<leader>b3", "<cmd>BufferLineGoToBuffer3")
vim.keymap.set("n", "<leader>b4", "<cmd>BufferLineGoToBuffer4")
vim.keymap.set("n", "<leader>b5", "<cmd>BufferLineGoToBuffer5")
vim.keymap.set("n", "<leader>b6", "<cmd>BufferLineGoToBuffer6")
vim.keymap.set("n", "<leader>b7", "<cmd>BufferLineGoToBuffer7")
vim.keymap.set("n", "<leader>b8", "<cmd>BufferLineGoToBuffer8")
vim.keymap.set("n", "<leader>b9", "<cmd>BufferLineGoToBuffer9")
