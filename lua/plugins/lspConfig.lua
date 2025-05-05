return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "roobert/tailwindcss-colorizer-cmp.nvim",
  },

  opts = function(_, opts)
    opts.inlay_hints = { enabled = false, focusable = true }
    local on_publish_diagnostics = vim.lsp.diagnostic.on_publish_diagnostics

    local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
      opts = opts or {}
      opts.border = opts.border or "rounded"
      return orig_util_open_floating_preview(contents, syntax, opts, ...)
    end

    opts.setup = {
      bashls = vim.tbl_deep_extend("force", opts.servers.bashls or {}, {
        handlers = {
          ["textDocument/publishDiagnostics"] = function(err, res, ...)
            local file_name = vim.fn.fnamemodify(vim.uri_to_fname(res.uri), ":t")
            if string.match(file_name, "^%.env") == nil then
              return on_publish_diagnostics(err, res, ...)
            end
          end,
        },
      }),

      tailwindcss = function(_, opts)
        local keys = require("lazyvim.plugins.lsp.keymaps").get()
        keys[#keys + 1] = { "<leader>fl", "<cmd>EslintFixAll<cr>" }
        opts.filetypes = opts.filetypes or {}

        -- Additional settings for Phoenix projects
        opts.settings = {
          tailwindCSS = {
            classAttributes = { "className", ".*ClassName" },
            classFunctions = { "clsx", "cn", "cva", "twMerge" },
          },
        }
      end,
    }
  end,
}
