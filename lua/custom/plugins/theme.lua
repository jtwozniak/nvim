return {
    -- Theme inspired by Atom
    'navarasu/onedark.nvim',
    -- 'rose-pine/neovim',
    priority = 1000,
    config = function()
        vim.cmd.colorscheme 'onedark'
    end,
}
