local on_attach = function(_, bufnr)
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>la', vim.lsp.buf.code_action, '[L]sp [A]ction')

    -- nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gd', '<cmd>Telescope lsp_definitions<cr>', '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    -- nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('gI', '<cmd>Telescope lsp_implementations<cr>', '[G]oto [I]mplementation')

    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    -- nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
end


return {
    {

        'williamboman/mason-lspconfig.nvim',
        dependency = {
            'neovim/nvim-lspconfig',
            'williamboman/mason.nvim',
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/nvim-cmp",
        },
        config = function()
            require('mason').setup()
            local servers = {
                graphql = {
                    filetypes = { "graphql", "typescriptreact", "javascriptreact", "typescript" },
                },

                lua_ls = {
                    Lua = {
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
            }
            -- Ensure the servers above are installed
            local mason_lspconfig = require 'mason-lspconfig'
            mason_lspconfig.setup {
                ensure_installed = vim.tbl_keys(servers),
            }

            -- local capabilities = vim.lsp.protocol.make_client_capabilities()
            -- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            mason_lspconfig.setup_handlers {
                function(server_name)
                    print('Setting up ' .. server_name)
                    require('lspconfig')[server_name].setup {
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = servers[server_name],
                        filetypes = (servers[server_name] or {}).filetypes,
                        -- commands = (servers[server_name] or {}).commands,
                    }
                end
            }
        end
    }
}
