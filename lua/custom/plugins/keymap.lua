vim.keymap.set('n', '<leader>w', '<Cmd>w<CR>', { desc = 'Write file' })
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Window left' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Window right' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Window up' })

vim.keymap.set('i', '<C-h>', '<Left>', { desc = 'Move left' })
vim.keymap.set('i', '<C-l>', '<Right>', { desc = 'Move right' })

vim.keymap.set('n', '<leader>c', '<Cmd>q<CR>', { desc = 'Move right' })

vim.keymap.set('n', '<A-e>', ":m .+1<CR>==", { desc = "move line up" })
vim.keymap.set('n', '<A-r>', ":m .-2<CR>==", { desc = "move line down" })

vim.keymap.set('i', '<A-e>', "<Esc>:m .-2<CR>==gi", { desc = "move line up" })
vim.keymap.set('i', '<A-r>', "<Esc>:m .+1<CR>==gi", { desc = "move line down" })

vim.keymap.set('v', '<A-e>', ":m '>+1<CR>gv-gv", { desc = "move line up" })
vim.keymap.set('v', '<A-r>', ":m '<-2<CR>gv-gv", { desc = "move line down" })

vim.keymap.set('n', 'J', "mzJ`z")

vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

vim.keymap.set('x', '<leader>p', "\"_dP")

vim.keymap.set('n', '<leader>gm', '<Cmd>:Gvdiffsplit master<CR>', { desc = "Compare Master" })
vim.keymap.set('n', '<leader>gl', '<Cmd>G! difftool master<CR>', { desc = "List changed files cmp to master" })
vim.keymap.set('n', '<leader>gb', '<Cmd>:Gvdiffsplit<CR>', { desc = "Compare current branch" })
vim.keymap.set('n', '<leader>gc', '<Cmd>Gclog!<CR>', { desc = "commit list" })

return {}
