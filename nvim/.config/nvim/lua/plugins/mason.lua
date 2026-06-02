return {
  {
    "mason-org/mason.nvim",
    opts = {
      registries = { "github:mason-org/mason-registry", "github:Crashdummyy/mason-registry" },
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
