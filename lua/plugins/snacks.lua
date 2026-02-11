return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          layout = {
            layout = {
              position = "right",
            },
          },
        },
      },
    },
  },
  keys = {
    {
      "gr",
      function()
        Snacks.picker.lsp_references({
          include_declaration = false,
          auto_confirm = true, -- Jumps automatically if only 1 item remains
          jump = { reuse_win = true },

          -- 'transform' is called for every item. Return false to drop it.
          transform = function(item)
            -- 1. Skip test files
            local file = item.file or vim.uri_to_fname(item.uri)
            if file:match("%.test%.") or file:match("%.spec%.") then
              return false
            end

            -- 2. Skip import lines
            local text = item.text or ""
            local trimmed = text:match("^%s*(.-)%s*$") or ""

            local is_import = trimmed:match("^import[%s{(]")
              or trimmed:match("from%s+['\"]")
              or (trimmed:match("^[%w_]+%s*,?$") and not (trimmed:match("=") or trimmed:match("%(")))

            return not is_import and item or false
          end,
        })
      end,
      desc = "Smart References",
    },
    {
      "gt",
      function()
        Snacks.picker.lsp_references({
          include_declaration = false,
        })
      end,
      desc = "References (with tests)",
      mode = "n",
      nowait = true,
    },
  },
}
