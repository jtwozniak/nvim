vim.keymap.set('n', '<leader>tl', "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<cr>",
    { desc = "Worktree list" }
)
vim.keymap.set('n', '<leader>tc', "<cmd>lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>",
    { desc = "Worktree create" },


return {
    "ThePrimeagen/git-worktree.nvim",
}
