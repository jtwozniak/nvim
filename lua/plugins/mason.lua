return {
  {
    "mason-org/mason.nvim",
    version = "2.0.0",
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
