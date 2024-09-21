return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = { enabled = false },
    setup = {
      tailwindcss = function(_, opts)
        opts.filetypes = opts.filetypes or {}

        -- Additional settings for Phoenix projects
        opts.settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                -- { "cva\\(([^]*)\\)\\;", "[\"'`]([^\"'`]*).*?[\"'`]" },
                -- { "twMerge\\(([^]*)\\)\\;", "/home/jtwozniak/w/m/apps/components/src/icons[\"'`]([^\"'`]*).*?[\"'`]" },
                { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                { "cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
              },
            },
          },
        }
      end,
    },
  },
}
