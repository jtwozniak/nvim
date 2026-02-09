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
        local params = vim.lsp.util.make_position_params()
        params.context = { includeDeclaration = false }
        vim.lsp.buf_request(0, "textDocument/references", params, function(err, result, ctx, config)
          if err or not result or #result == 0 then
            vim.notify("No references found", vim.log.levels.INFO)
            return
          end

          vim.notify("Total refs: " .. #result, vim.log.levels.INFO)

          -- Filter out test files and imports
          local filtered = {}
          for _, item in ipairs(result) do
            local uri = item.uri or item.targetUri
            local file = vim.uri_to_fname(uri)
            local is_test = file:match("%.test%.") or file:match("%.spec%.")
            
            if not is_test then
              -- Get the text at the reference location
              local bufnr = vim.uri_to_bufnr(uri)
              local line_text = ""
              if vim.api.nvim_buf_is_loaded(bufnr) then
                line_text = vim.api.nvim_buf_get_lines(bufnr, item.range.start.line, item.range.start.line + 1, false)[1] or ""
              else
                -- Read from file if buffer not loaded
                local f = io.open(file, "r")
                if f then
                  local line_num = 1
                  for line in f:lines() do
                    if line_num == item.range.start.line + 1 then
                      line_text = line
                      break
                    end
                    line_num = line_num + 1
                  end
                  f:close()
                end
              end
              
              vim.notify("Line text: [" .. line_text .. "]", vim.log.levels.INFO)
              
              local trimmed = line_text:match("^%s*(.-)%s*$") or line_text
              vim.notify("Trimmed: [" .. trimmed .. "]", vim.log.levels.INFO)
              
              -- Check if this line is part of an import statement
              -- Look for patterns that indicate imports
              local is_import = false
              
              -- Direct import patterns
              if trimmed:match("^import%s") or trimmed:match("^import{") or trimmed:match("^import%(") then
                is_import = true
              end
              
              -- Check if line contains comma after identifier (destructured import pattern)
              -- AND doesn't contain operators or function calls
              if trimmed:match("^[%w_]+%s*,") and not trimmed:match("[%(%):]") then
                is_import = true
              end
              
              vim.notify("Is import: " .. tostring(is_import), vim.log.levels.INFO)
              
              if not is_import then
                table.insert(filtered, item)
              end
            end
          end

          vim.notify("Filtered refs: " .. #filtered, vim.log.levels.INFO)

          if #filtered == 0 then
            vim.notify("No non-import references found", vim.log.levels.INFO)
          elseif #filtered == 1 then
            -- Jump directly to the single reference
            vim.lsp.util.jump_to_location(filtered[1], "utf-8")
          else
            -- Open picker with multiple references
            Snacks.picker.lsp_references({
              include_declaration = false,
              transform = function(item, ctx)
                if item.file then
                  local is_test = item.file:match("%.test%.") or item.file:match("%.spec%.")
                  if is_test then
                    return false
                  end
                end
                if item.text then
                  local trimmed = item.text:match("^%s*(.-)%s*$") or item.text
                  if trimmed:match("^import%s") or trimmed:match("^import{") or trimmed:match("^import%(") then
                    return false
                  end
                end
                return item
              end,
            })
          end
        end)
      end,
      desc = "References (no tests/imports)",
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
