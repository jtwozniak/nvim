local M = {}

function M.copy_relative_path(picker)
  local item = picker:current()
  local path = item and item.file
  if not path then
    return
  end

  local relative_path = vim.fn.fnamemodify(path, ":.")
  vim.fn.setreg("+", relative_path)
  vim.notify("Copied: " .. relative_path)
end

function M.git_log_dir(picker, item)
  if not item or not item.dir then
    return
  end
  Snacks.picker.git_log({
    cmd_args = { "--", item.file },
  })
end

return M
