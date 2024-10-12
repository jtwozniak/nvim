return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "roobert/tailwindcss-colorizer-cmp.nvim",
  },

  opts = function(_, opts)
    opts.inlay_hints = { enabled = false, focusable = true }

    opts.setup = {
      tailwindcss = function(_, opts)
        local keys = require("lazyvim.plugins.lsp.keymaps").get()
        keys[#keys + 1] = { "<leader>fl", "<cmd>EslintFixAll<cr>" }
        opts.filetypes = opts.filetypes or {}

        -- Additional settings for Phoenix projects
        opts.settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                { "cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                { "twMerge\\(([^]*)\\)\\;", "[\"'`]([^\"'`]*).*?[\"'`]" },
              },
            },
          },
        }
      end,
    }
  end,
}
