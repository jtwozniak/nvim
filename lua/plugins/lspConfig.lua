return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "roobert/tailwindcss-colorizer-cmp.nvim",
  },

  opts = {
    inlay_hints = { enabled = false, focusable = true },

    servers = {
      -- tsgo = {
      --   -- keys = { { "<leader>fl", "<cmd>LspEslintFixAll<cr><cmd>OxcFixAll<cr>", "Lint fix" } },
      --   enabled = true,
      --   cmd = { "tsgo", "--lsp", "--stdio" },
      --   filetypes = {
      --     "javascript",
      --     "javascriptreact",
      --     "javascript.jsx",
      --     "typescript",
      --     "typescriptreact",
      --     "typescript.tsx",
      --   },
      --   root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
      -- },
      oxlint = {
        -- keys = { { "<leader>fl", "<cmd>LspEslintFixAll<cr><cmd>OxcFixAll<cr>", "Lint fix" } },
        keys = { { "<leader>fl", "<cmd>LspEslintFixAll<cr>", "Lint fix" } },
        enabled = true,
        cmd = { "oxc_language_server" },
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },
        root_markers = { ".oxlintrc.json", "package.json", ".git" },
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
