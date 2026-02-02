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

        Job:new({
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
        }):start()
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
            -- Get git common dir, then derive the root (parent of .git)
            local git_root = vim.fn.systemlist("git rev-parse --git-common-dir")[1]

            -- Check if we're in a git repository
            if vim.v.shell_error ~= 0 or not git_root or git_root:match("^fatal:") then
              vim.notify("Not in a git repository", vim.log.levels.ERROR)
              return
            end

            -- Get absolute path and strip /.git to get root
            git_root = vim.fn.fnamemodify(git_root, ":p")

            vim.notify("Git root:" .. git_root, vim.log.levels.INFO)
            vim.notify("Fetching remote branches...", vim.log.levels.INFO)
            vim.fn.system("git fetch origin")

            -- Check if branch exists on remote (with or without janusz/ prefix)
            local remote_branch_plain = vim.fn.systemlist("git ls-remote --heads origin " .. variable)[1]
            local remote_branch_janusz = vim.fn.systemlist("git ls-remote --heads origin janusz/" .. variable)[1]

            local path, branch, base_branch, is_remote

            if remote_branch_plain then
              -- Case 1: Branch exists on remote without prefix
              path = git_root .. variable
              branch = variable
              base_branch = "origin/" .. variable
              is_remote = true
              vim.notify("Checking out existing branch: " .. variable, vim.log.levels.INFO)
            elseif remote_branch_janusz then
              -- Case 2: Branch exists with janusz/ prefix - create worktree without prefix
              path = git_root .. variable
              branch = "janusz/" .. variable
              base_branch = "origin/janusz/" .. variable
              is_remote = true
              vim.notify("Checking out existing branch: janusz/" .. variable, vim.log.levels.INFO)
            else
              -- Case 3: Branch doesn't exist - create new with janusz/ prefix
              path = git_root .. variable
              branch = "janusz/" .. variable
              base_branch = "origin/develop"
              is_remote = false
              vim.notify("Creating new branch: janusz/" .. variable, vim.log.levels.INFO)
            end

            vim.notify("Creating new worktree: " .. path .. " " .. branch .. " " .. base_branch, vim.log.levels.INFO)
            require("git-worktree").create_worktree(path, branch, base_branch)

            -- If it's a remote branch, do git pull --rebase after worktree is created
            if is_remote then
              vim.defer_fn(function()
                vim.notify("Switching to worktree and running git pull --rebase...", vim.log.levels.INFO)
                -- Switch directory first
                vim.cmd("cd " .. vim.fn.fnameescape(path))
                -- Set upstream and pull rebase explicitly
                local result = vim.fn.system("git pull --rebase origin " .. branch)
                if vim.v.shell_error == 0 then
                  vim.notify("Successfully rebased from remote", vim.log.levels.INFO)
                else
                  vim.notify("Pull rebase failed: " .. result, vim.log.levels.WARN)
                end
              end, 1000) -- Wait 1 second for worktree creation to complete
            end
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
                      -- Switch to bare repo before deleting
                      require("git-worktree").switch_worktree(nil)
                      
                      vim.defer_fn(function()
                        require("git-worktree").delete_worktree(item.path, false, {
                          on_success = function()
                            vim.notify("Worktree deleted: " .. item.path, vim.log.levels.INFO)
                          end,
                          on_failure = function(e)
                            local error_msg = e:stderr_result()[1] or "Unknown error"
                            if error_msg:match("changes would be lost") or error_msg:match("uncommitted changes") then
                              vim.notify(
                                "Cannot delete worktree: uncommitted changes in " .. item.path,
                                vim.log.levels.WARN
                              )
                            else
                              vim.notify("Failed to delete worktree: " .. error_msg, vim.log.levels.ERROR)
                            end
                          end,
                        })
                      end, 100)
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
