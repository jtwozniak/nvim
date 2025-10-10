return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "roobert/tailwindcss-colorizer-cmp.nvim",
  },

  opts = function(_, opts)
    opts.inlay_hints = { enabled = false, focusable = true }
    -- local on_publish_diagnostics = vim.lsp.diagnostic.on_publish_diagnostics
    --
    -- local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
    -- function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    --   opts = opts or {}
    --   opts.border = opts.border or "rounded"
    --   return orig_util_open_floating_preview(contents, syntax, opts, ...)
    -- end

    opts.servers = {
      graphql = {},
      oxlint = {
        cmd = { "oxc_language_server" },
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },
        root_dir = function(fname)
          local util = require("lspconfig.util")
          return util.root_pattern(".oxlintrc.json", "package.json")(fname)
            or util.find_package_json_ancestor(fname)
            or util.find_node_modules_ancestor(fname)
            or util.find_git_ancestor(fname)
        end,
      },
    }
    opts.setup = {
      -- bashls = vim.tbl_deep_extend("force", opts.servers.bashls or {}, {
      --   handlers = {
      --     ["textDocument/publishDiagnostics"] = function(err, res, ...)
      --       local file_name = vim.fn.fnamemodify(vim.uri_to_fname(res.uri), ":t")
      --       if string.match(file_name, "^%.env") == nil then
      --         return on_publish_diagnostics(err, res, ...)
      --       end
      --     end,
      --   },
      -- }),

      tailwindcss = function(_, opts)
        local keys = require("lazyvim.plugins.lsp.keymaps").get()
        keys[#keys + 1] = { "<leader>fl", "<cmd>EslintFixAll<cr><cmd>OxcFixAll<cr>" }
        opts.filetypes = opts.filetypes or {}

        -- Additional settings for Phoenix projects
        opts.settings = {
          tailwindCSS = {
            classAttributes = { "className", ".*ClassName" },
            classFunctions = { "clsx", "cn", "cva", "twMerge" },
          },
        }
      end,
      oxlint = function(_, opts)
        opts.filtetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        }
        -- opts.root_dir = function(bufnr, on_dir)
        --   local fname = vim.api.nvim_buf_get_name(bufnr)
        --   -- local root_markers = util.insert_package_json({ ".oxlintrc.json" }, "oxlint", fname)
        --   -- on_dir(vim.fs.dirname(vim.fs.find(root_markers, { path = fname, upward = true })[1]))
        --   on_dir("~/w/m/.oxlintrs.json")
        -- end
      end,
    }
  end,
}
