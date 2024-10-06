return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "roobert/tailwindcss-colorizer-cmp.nvim",
  },

  opts = function(_, opts)
    opts.inlay_hints = { enabled = false, focusable = true }

    opts.setup = {
      tailwindcss = function(_, opts)
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
