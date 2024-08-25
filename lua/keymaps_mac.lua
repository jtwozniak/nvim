-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
--
vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Move left" })
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Move right" })

vim.keymap.set("n", "Ż", ":m .-2<CR>==", { desc = "move line up" })
vim.keymap.set("n", "∆", ":m .+1<CR>==", { desc = "move line down" })

vim.keymap.set("i", "Ż", "<Esc>:m .-2<CR>==gi", { desc = "move line up" })
vim.keymap.set("i", "∆", "<Esc>:m .+1<CR>==gi", { desc = "move line down" })

vim.keymap.set("v", "Ż", ":m '<-2<CR>gv-gv", { desc = "move line up" })
vim.keymap.set("v", "∆", ":m '>+1<CR>gv-gv", { desc = "move line down" })

-- vim.keymap.set('n', 'J', "mzJ`z")

-- vim.keymap.set('n', '<C-d>', '<C-d>zz')
-- vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- vim.keymap.set('n', 'n', 'nzzzv')
-- vim.keymap.set('n', 'N', 'Nzzzv')

-- vim.keymap.set("x", "<leader>p", '"_dP')

vim.keymap.set("n", "<leader>z", "<Cmd>q<CR>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>w", "<Cmd>w<CR>", { desc = "Write buffer" })

vim.keymap.set("n", "<leader>gm", "<Cmd>:Gvdiffsplit main<CR>", { desc = "Compare Master" })
-- vim.keymap.set('n', '<leader>gv', '<Cmd>:Gvdiffsplit v3<CR>', { desc = "Compare Master" })
-- vim.keymap.set("n", "<leader>gl", "<Cmd>G! difftool main<CR>", { desc = "List changed files cmp to master" })
vim.keymap.set("n", "<leader>gb", "<Cmd>:Gvdiffsplit<CR>", { desc = "Compare current branch" })
-- vim.keymap.set("n", "<leader>gc", "<Cmd>Gclog!<CR>", { desc = "commit list" })
-- vim.keymap.set("n", "<leader>gx", "<Cmd>Gclog! --follow %<CR>", { desc = "commit list" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
