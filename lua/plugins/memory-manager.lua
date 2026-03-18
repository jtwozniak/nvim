-- Memory manager: buffer pruning (max 5) + LSP orphan cleanup
-- Keeps Neovim lean during long sessions with a "one-in, one-out" approach.

local MAX_BUFFERS = 5

local buf_access = {} -- bufnr → timestamp
local augroup = vim.api.nvim_create_augroup("MemoryManager", { clear = true })

--- Check if a buffer is a "real file" buffer eligible for pruning
local function is_prunable(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  if not vim.bo[bufnr].buflisted then
    return false
  end
  if vim.bo[bufnr].modified then
    return false
  end

  local buftype = vim.bo[bufnr].buftype
  if buftype ~= "" then
    return false
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return false
  end

  local filetype = vim.bo[bufnr].filetype
  local skip_filetypes = {
    "dashboard",
    "neo-tree",
    "Trouble",
    "trouble",
    "fugitive",
    "harpoon",
    "qf",
    "help",
    "snacks_dashboard",
    "snacks_notif",
    "snacks_picker",
    "snacks_picker_input",
    "snacks_picker_list",
    "snacks_picker_preview",
    "snacks_explorer",
    "snacks_terminal",
    "lazy",
    "mason",
    "notify",
    "noice",
    "DressingInput",
    "TelescopePrompt",
    "copilot-chat",
  }
  for _, ft in ipairs(skip_filetypes) do
    if filetype == ft then
      return false
    end
  end

  return true
end

--- Get list of harpoon-pinned file paths (absolute)
local function get_harpoon_paths()
  local ok, harpoon = pcall(require, "harpoon")
  if not ok then
    return {}
  end

  local list = harpoon:list()
  if not list or not list.items then
    return {}
  end

  local paths = {}
  local cwd = vim.uv.cwd() or vim.fn.getcwd()
  for _, item in ipairs(list.items) do
    if item.value then
      local abs = item.value:sub(1, 1) == "/" and item.value or (cwd .. "/" .. item.value)
      paths[vim.fn.resolve(abs)] = true
    end
  end
  return paths
end

--- Check if a buffer's file is pinned in harpoon
local function is_harpoon_pinned(bufnr, harpoon_paths)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return false
  end
  return harpoon_paths[vim.fn.resolve(name)] == true
end

--- Get all prunable buffers sorted by last access (oldest first)
local function get_prunable_buffers()
  local harpoon_paths = get_harpoon_paths()
  local bufs = {}

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if is_prunable(bufnr) and not is_harpoon_pinned(bufnr, harpoon_paths) then
      table.insert(bufs, {
        bufnr = bufnr,
        last_access = buf_access[bufnr] or 0,
      })
    end
  end

  table.sort(bufs, function(a, b)
    return a.last_access < b.last_access
  end)

  return bufs
end

--- Prune oldest buffers to stay within MAX_BUFFERS
local function prune_buffers()
  local prunable = get_prunable_buffers()
  local current = vim.api.nvim_get_current_buf()
  local to_remove = #prunable - MAX_BUFFERS

  if to_remove <= 0 then
    return
  end

  local removed = 0
  for _, buf in ipairs(prunable) do
    if removed >= to_remove then
      break
    end
    if buf.bufnr ~= current then
      local ok = pcall(vim.cmd, "bwipeout " .. buf.bufnr)
      if ok then
        buf_access[buf.bufnr] = nil
        removed = removed + 1
      end
    end
  end
end

-- Track buffer access timestamps
vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  callback = function(ev)
    if vim.api.nvim_buf_is_valid(ev.buf) and vim.bo[ev.buf].buflisted then
      buf_access[ev.buf] = vim.uv.hrtime()
    end
  end,
})

-- Prune on new buffer open (deferred to let the buffer fully initialize)
vim.api.nvim_create_autocmd("BufAdd", {
  group = augroup,
  callback = function()
    vim.defer_fn(prune_buffers, 100)
  end,
})

-- Clean up access table when buffers are wiped
vim.api.nvim_create_autocmd("BufWipeout", {
  group = augroup,
  callback = function(ev)
    buf_access[ev.buf] = nil
  end,
})

-- Stop orphaned LSP clients after buffer wipe
vim.api.nvim_create_autocmd("BufWipeout", {
  group = augroup,
  callback = function()
    vim.defer_fn(function()
      for _, client in ipairs(vim.lsp.get_clients()) do
        local attached = vim.lsp.get_buffers_by_client_id(client.id)
        if #attached == 0 then
          client:stop()
        end
      end
    end, 200)
  end,
})

-- Manual prune command + keymap
vim.api.nvim_create_user_command("BufferPruneNow", function()
  prune_buffers()
  vim.notify("Buffers pruned (max " .. MAX_BUFFERS .. ")", vim.log.levels.INFO)
end, { desc = "Prune buffers to max limit" })

vim.keymap.set("n", "<leader>bp", "<cmd>BufferPruneNow<cr>", { desc = "Prune old buffers" })

return {}
