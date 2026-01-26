return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local worktree_cache = { value = "", last_update = 0 }
    
    local function update_worktree_cache()
      local Job = require("plenary.job")
      
      Job:new({
        command = "git",
        args = { "rev-parse", "--show-toplevel", "--abbrev-ref", "HEAD", "--git-common-dir" },
        on_exit = vim.schedule_wrap(function(j, return_val)
          if return_val == 0 then
            local results = j:result()
            local toplevel = results[1]
            local branch = results[2] or "detached"
            local common_dir = results[3]
            
            if toplevel then
              if common_dir and common_dir ~= ".git" then
                -- This is a worktree, extract relative path
                local main_root = vim.fn.fnamemodify(common_dir, ":h")
                local relative = toplevel:gsub("^" .. vim.pesc(main_root) .. "/?", "")
                
                -- Build breadcrumb from relative path
                local parts = vim.split(relative, "/")
                local breadcrumb = table.concat(parts, " > ")
                worktree_cache.value = string.format("🌳 %s (%s)", breadcrumb, branch)
              else
                -- Main repo
                local basename = vim.fn.fnamemodify(toplevel, ":t")
                worktree_cache.value = string.format("🌳 %s (%s)", basename, branch)
              end
              worktree_cache.last_update = vim.loop.hrtime()
            end
          else
            worktree_cache.value = ""
            worktree_cache.last_update = vim.loop.hrtime()
          end
        end),
      }):start()
    end
    
    local function worktree_info()
      local now = vim.loop.hrtime()
      -- Cache for 5 seconds
      if now - worktree_cache.last_update < 5e9 then
        return worktree_cache.value
      end

      local ok, Job = pcall(require, "plenary.job")
      if not ok then
        return ""
      end

      -- Trigger async update
      update_worktree_cache()
      
      return worktree_cache.value
    end

    table.insert(opts.sections.lualine_x, 1, {
      worktree_info,
      color = { fg = "#87e383", gui = "bold" },
    })
  end,
}
