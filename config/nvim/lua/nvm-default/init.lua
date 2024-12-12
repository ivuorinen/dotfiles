-- Get nvm default version and use it in node_host_prog
-- and g.copilot_node_command.
local M = {}

M.name = 'nvm-default.nvim'
M.version = '0.1.0' -- x-release-please-version

-- Helper function to run a shell command
---@param cmd string Run a shell command
---@return string? Return the result of the command
local function run_command(cmd)
  local handle = io.popen(cmd)
  if not handle then
    return nil
  end
  local result = handle:read("*a")
  handle:close()
  return result and result:gsub("%s+$", "")
end


-- Helper function to show a notification
---@param msg string Show a message
---@param level number|"info"|"warn"|"error"|"trace" Notification level
local function n(msg, level)
  if msg == nil then
    msg = M.name .. ": No message provided"
  end
  if level == nil then
    level = "trace"
  end

  vim.notify(M.name .. ": " .. msg, level)
end

-- Default options
---@class NvmDefaultOptions
---@field nvm_path string Where nvm installation is located
---@field notify_level number|"info"|"warn"|"error"|"trace" Notification level filter
M.defaults = {
  nvm_path = os.getenv("NVM_DIR") or os.getenv("HOME") .. "/.nvm",
  notify_level = vim.g.nvm_default_notify_level or "info",
}

-- Fetch the NVM default version or fallback to node version
---@param opts? NvmDefaultOptions Options
function M.setup(opts)
  local options = vim.tbl_deep_extend("force", M.defaults, opts or {})

  local nvm_path = options.nvm_path
  local node_version =
      run_command(string.format("source %s/nvm.sh && nvm version default", nvm_path)) or
      run_command(string.format("source %s/nvm.sh && nvm version node", nvm_path))

  if node_version and node_version:match("^v") then
    -- Set vim.g.node_host_prog and vim.g.copilot_node_command
    local node_dir = string.format("%s/versions/node/%s", nvm_path, node_version)
    local node_dir_bin = string.format("%s/bin", node_dir)
    local node_bin = string.format("%s/node", node_dir_bin)
    local node_host_bin = string.format("%s/neovim-node-host", node_dir_bin)

    -- If node_dir isn't there, stop and show error
    if not vim.fn.isdirectory(node_dir) then
      n("Node.js dir " .. node_dir .. " does not exist", "error")
      return
    end

    -- If node_bin isn't there, stop and show error
    if not vim.fn.filereadable(node_bin) then
      n("Node.js bin " .. node_bin .. " does not exist", "error")
      return
    end

    if not vim.fn.filereadable(node_host_bin) then
      n("neovim-host-prog " .. node_host_bin .. " does not exist", "error")
      return
    end

    vim.env.PATH = node_dir_bin .. ":" .. vim.env.PATH

    vim.g.node_host_prog = node_host_bin
    vim.g.copilot_node_command = node_bin
  else
    n("Unable to determine the Node.js version from nvm.", "error")
  end
end

return M
