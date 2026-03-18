return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local worktree_value = ""
    local is_running = false

    local function refresh_worktree()
      if is_running then
        return
      end
      is_running = true

      vim.system(
        { "git", "rev-parse", "--show-toplevel", "--abbrev-ref", "HEAD", "--git-common-dir" },
        { text = true },
        vim.schedule_wrap(function(result)
          is_running = false
          if result.code ~= 0 or not result.stdout or result.stdout == "" then
            worktree_value = ""
            return
          end

          local lines = vim.split(result.stdout, "\n", { trimempty = true })
          if #lines < 1 then
            worktree_value = ""
            return
          end

          local toplevel = lines[1]
          local branch = lines[2] or "detached"
          local common_dir = lines[3]

          if not toplevel or toplevel == "" then
            worktree_value = ""
            return
          end

          if common_dir and common_dir ~= "" and common_dir ~= ".git" then
            local main_root = vim.fn.fnamemodify(common_dir, ":h")
            local relative = toplevel:gsub("^" .. vim.pesc(main_root) .. "/?", "")
            local breadcrumb = table.concat(vim.split(relative, "/"), " > ")
            worktree_value = string.format("🌳 %s (%s)", breadcrumb, branch)
          else
            local basename = vim.fn.fnamemodify(toplevel, ":t")
            if basename == "" or basename == "." then
              worktree_value = string.format("🌳 (%s)", branch)
            else
              worktree_value = string.format("🌳 %s (%s)", basename, branch)
            end
          end
        end)
      )
    end

    -- Event-driven: only refresh when git state could actually change
    vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged", "FocusGained" }, {
      group = vim.api.nvim_create_augroup("lualine_worktree", { clear = true }),
      callback = refresh_worktree,
    })

    -- Initial fetch
    refresh_worktree()

    -- Reduce timer-driven redraws (default 1000ms triggers status_dispatch too often)
    opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
      refresh = { statusline = 3000, winbar = 3000 },
    })

    table.insert(opts.sections.lualine_x, 1, {
      function()
        return worktree_value
      end,
      color = { fg = "#87e383", gui = "bold" },
    })
  end,
}
