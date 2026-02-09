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
          transform = function(item, ctx)
            if item.file then
              local is_test = item.file:match("%.test%.") or item.file:match("%.spec%.")
              if is_test then
                return false
              end
            end
            return item
          end,
        })
      end,
      desc = "References (no tests)",
      mode = "n",
      nowait = true,
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
