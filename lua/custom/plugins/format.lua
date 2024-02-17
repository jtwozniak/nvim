vim.g.neoformat_try_node_exe = 1

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.json", "*.graphql", "*.jsonc", "*.js", "*.ts", "*.tsx", "*.jsx" },
    command = "Neoformat",
})

vim.keymap.set('n', '<leader>fo', '<cmd>Neoformat<cr>', { noremap = true, silent = true })



return {
    "sbdchd/neoformat",
}
