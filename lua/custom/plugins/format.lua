vim.g.neoformat_try_node_exe = 1
vim.g.ale_fix_on_save = 1
vim.g.ale_fixers = { 'prettier', 'eslint' }

function Organize_imports()
    local params = {
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
        title = ""
    }
    vim.lsp.buf.execute_command(params)
end

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.json", "*.jsonc", "*.js", "*.ts", "*.tsx", "*.jsx" },
    command = "lua Organize_imports()",
})

return {
    "sbdchd/neoformat",
    "dense-analysis/ale",
}
