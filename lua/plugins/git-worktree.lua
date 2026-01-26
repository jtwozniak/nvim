return {
  "polarmutex/git-worktree.nvim",
  version = "^2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local Hooks = require("git-worktree.hooks")
    local config = require("git-worktree.config")
    local update_on_switch = Hooks.builtins.update_current_buffer_on_switch

    Hooks.register(Hooks.type.SWITCH, function(path, prev_path)
      vim.notify("Moved from " .. prev_path .. " to " .. path)
      update_on_switch(path, prev_path)
    end)
  end,
  keys = {
    {
      "<leader>gwl",
      function()
        local ok_snacks = pcall(require, "snacks")
        if not ok_snacks then
          vim.notify("Snacks.nvim not available", vim.log.levels.ERROR)
          return
        end

        local Job = require("plenary.job")
        local worktrees = {}

        Job
          :new({
            command = "git",
            args = { "worktree", "list", "--porcelain" },
            on_exit = function(j, return_val)
              if return_val ~= 0 then
                vim.notify("Not a git repository or no worktrees found", vim.log.levels.WARN)
                return
              end

              local current = {}
              for _, line in ipairs(j:result()) do
                if line:match("^worktree ") then
                  current.path = line:match("^worktree (.+)")
                elseif line:match("^HEAD ") then
                  -- Skip HEAD line
                elseif line:match("^branch ") then
                  current.branch = line:match("^branch refs/heads/(.+)")
                elseif line == "" and current.path then
                  table.insert(worktrees, {
                    text = string.format("%s (%s)", current.path, current.branch or "detached"),
                    path = current.path,
                    branch = current.branch,
                  })
                  current = {}
                end
              end

              vim.schedule(function()
                if #worktrees == 0 then
                  vim.notify("No worktrees found", vim.log.levels.INFO)
                  return
                end

                require("snacks").picker.pick({
                  prompt = "Git Worktrees",
                  items = worktrees,
                  format = "text",
                  confirm = function(picker, item)
                    if item then
                      require("git-worktree").switch_worktree(item.path)
                    end
                    picker:close()
                  end,
                })
              end)
            end,
          })
          :start()
      end,
      desc = "Git Worktree Picker",
    },
    {
      "<leader>gwc",
      function()
        require("snacks").input({
          prompt = "Variable (path and branch suffix):",
        }, function(variable)
          if variable and variable ~= "" then
            -- Get git root directory
            local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
            local path = git_root .. "/../" .. variable
            local branch = "janusz/" .. variable
            
            -- Fetch latest from origin/develop first
            vim.notify("Fetching origin/develop...", vim.log.levels.INFO)
            vim.fn.system("git fetch origin develop")
            
            -- Create worktree from fresh origin/develop
            require("git-worktree").create_worktree(path, branch, "origin/develop")
          end
        end)
      end,
      desc = "Create Worktree",
    },
    {
      "<leader>gwd",
      function()
        local Job = require("plenary.job")
        local worktrees = {}

        Job
          :new({
            command = "git",
            args = { "worktree", "list", "--porcelain" },
            on_exit = function(j, return_val)
              if return_val ~= 0 then
                vim.schedule(function()
                  vim.notify("Not a git repository or no worktrees found", vim.log.levels.WARN)
                end)
                return
              end

              local current = {}
              local lines = j:result()
              
              for _, line in ipairs(lines) do
                if line:match("^worktree ") then
                  current.path = line:match("^worktree (.+)")
                elseif line:match("^HEAD ") then
                  -- Skip HEAD line
                elseif line:match("^branch ") then
                  current.branch = line:match("^branch refs/heads/(.+)")
                elseif line == "" and current.path then
                  table.insert(worktrees, {
                    text = string.format("%-50s %s", current.path, current.branch or "(detached)"),
                    path = current.path,
                    branch = current.branch,
                  })
                  current = {}
                end
              end

              -- Handle last entry if file doesn't end with blank line
              if current.path then
                table.insert(worktrees, {
                  text = string.format("%-50s %s", current.path, current.branch or "(detached)"),
                  path = current.path,
                  branch = current.branch,
                })
              end

              vim.schedule(function()
                if #worktrees == 0 then
                  vim.notify("No worktrees to delete", vim.log.levels.INFO)
                  return
                end

                require("snacks").picker.pick({
                  prompt = "Delete Worktree",
                  items = worktrees,
                  format = "text",
                  confirm = function(picker, item)
                    if item then
                      require("git-worktree").delete_worktree(item.path)
                    end
                    picker:close()
                  end,
                })
              end)
            end,
          })
          :start()
      end,
      desc = "Delete Worktree",
    },
  },
}
