return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "oxfmt" },
        javascriptreact = { "oxfmt" },
        typescript = { "oxfmt" },
        typescriptreact = { "oxfmt" },
        json = { "oxfmt" },
        vue = { "oxfmt" },
      },
      formatters = {
        oxfmt = {
          command = function(self, bufnr)
            return require("conform.util").find_executable({
              "node_modules/.bin/oxfmt",
            }, "oxfmt")
          end,
          args = { "$FILENAME" },
          stdin = false,
        },
      },
    },
  },
}
