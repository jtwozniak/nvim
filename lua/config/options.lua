-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local _border = "rounded"

vim.diagnostic.config({
  float = { border = _border },
})

vim.g.trouble_lualine = false
vim.g.snacks_animate = false
