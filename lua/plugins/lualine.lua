return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local worktree_cache = { value = "", last_update = 0, is_running = false }
    local Job = nil

    local function update_worktree_cache()
      if worktree_cache.is_running then
        return
      end

      if not Job then
        local ok, plenary_job = pcall(require, "plenary.job")
        if not ok then
          return
        end
        Job = plenary_job
      end

      worktree_cache.is_running = true

      Job:new({
        command = "git",
        args = { "rev-parse", "--show-toplevel", "--abbrev-ref", "HEAD", "--git-common-dir" },
        on_exit = vim.schedule_wrap(function(j, return_val)
          worktree_cache.is_running = false
          worktree_cache.last_update = vim.loop.hrtime()

          if return_val == 0 then
            local results = j:result()
            if not results or #results == 0 then
              worktree_cache.value = ""
              return
            end

            local toplevel = results[1]
            local branch = results[2] or "detached"
            local common_dir = results[3]

            if toplevel and toplevel ~= "" then
              if common_dir and common_dir ~= "" and common_dir ~= ".git" then
                -- This is a worktree, extract relative path
                local main_root = vim.fn.fnamemodify(common_dir, ":h")
                local relative = toplevel:gsub("^" .. vim.pesc(main_root) .. "/?", "")

                -- Build breadcrumb from relative path
                local parts = vim.split(relative, "/")
                local breadcrumb = table.concat(parts, " > ")
                worktree_cache.value = string.format("🌳 %s (%s)", breadcrumb, branch)
              else
                -- Main repo or bare repo root
                local basename = vim.fn.fnamemodify(toplevel, ":t")
                if basename == "" or basename == "." then
                  -- Fallback for bare repo root or edge cases
                  worktree_cache.value = string.format("🌳 (%s)", branch)
                else
                  worktree_cache.value = string.format("🌳 %s (%s)", basename, branch)
                end
              end
            else
              worktree_cache.value = ""
            end
          else
            worktree_cache.value = ""
          end
        end),
      }):start()
    end

    local function worktree_info()
      local now = vim.loop.hrtime()
      -- Cache for 5 seconds
      if now - worktree_cache.last_update > 5e9 then
        update_worktree_cache()
      end

      return worktree_cache.value
    end

    table.insert(opts.sections.lualine_x, 1, {
      worktree_info,
      color = { fg = "#87e383", gui = "bold" },
    })
  end,
}
