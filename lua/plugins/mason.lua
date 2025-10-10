return {
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        border = "rounded",
      },
      ensure_installed = {
        -- ...elided others
        "graphql-language-service-cli", -- required for graphql-lsp
      },
    },
  },
}
