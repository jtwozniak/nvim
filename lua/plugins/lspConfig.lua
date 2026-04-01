return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "roobert/tailwindcss-colorizer-cmp.nvim",
  },

  opts = {
    inlay_hints = { enabled = false, focusable = true },

    servers = {
      ["*"] = {
        keys = {
          { "gr", false }, -- Disable default gr mapping
        },
      },
      oxlint = {
        -- keys = { { "<leader>fl", "<cmd>OxcFixAll<cr>", "Lint fix" } },
        keys = { { "<leader>fl", "<cmd>LspOxlintFixAll<cr><cmd>!oxfmt %<cr>", "Lint fix" } },
        -- settings = {
        --   typeAware = true,
        -- },
        -- enabled = true,
        -- cmd = { "oxc_language_server" },
        -- filetypes = {
        --   "javascript",
        --   "javascriptreact",
        --   "javascript.jsx",
        --   "typescript",
        --   "typescriptreact",
        --   "typescript.tsx",
        -- },
        -- root_markers = { ".oxlintrc.json", "package.json", ".git" },
      },
    },

    setup = {
      tailwindcss = function(_, options)
        options.settings = {
          tailwindCSS = {
            classAttributes = { "className", ".*ClassName" },
            classFunctions = { "clsx", "cn", "cva", "twMerge" },
          },
        }
      end,
    },
  },
}
