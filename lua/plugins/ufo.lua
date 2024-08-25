vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

local nmap = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { desc = desc })
end



return {
    'kevinhwang91/nvim-ufo',
    dependencies = {
        'kevinhwang91/promise-async',
        'neovim/nvim-lspconfig',
        -- 'neoclide/coc.nvim'
    },
    config = function()
        -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
        nmap('ma', require('ufo').openAllFolds, "open all folds")
        nmap('md', require('ufo').closeAllFolds, "close all folds")
        nmap('mc', "<cmd>foldclose<CR>", "open fold")
        nmap('mo', "<cmd>foldopen<CR>", "close fold")
        require('ufo').setup({
            provider_selector = function() return { 'lsp', 'indent' } end,
        })
    end,

}
