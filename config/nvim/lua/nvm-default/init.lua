-- Get nvm default version and use it in node_host_prog
-- and g.copilot_node_command.
--
-- This module automatically configures Neovim to use the default Node.js version
-- from NVM. It requires a working NVM installation and 'default' alias to be set,
-- and also neovim npm package to be installed.
--
-- You can install the neovim package by running:
-- npm i --global neovim
--
-- Usage:
--   require('nvm-default').setup({
--     add_to_path = true,        -- optional: add NVM bin directory to PATH
--     nvm_path = "~/.nvm",      -- optional: custom NVM installation path
--     notify_level = "info"     -- optional: notification level
--   })

local M = {}

M.name = 'nvm-default.nvim'
M.version = '0.1.0' -- x-release-please-version

-- Helper function to run a shell command
---@param cmd string Run a shell command
---@return string? Return the result of the command
local function run_command(cmd)
  local result = vim.fn.system(cmd)
  return vim.v.shell_error == 0 and result:gsub('%s+$', '') or nil
end

-- Helper function to show a notification
---@param msg string Show a message
---@param level "info"|"warn"|"error"|"trace" Notification level
local function n(msg, level)
  if msg == nil then msg = M.name .. ': No message provided' end
  if level == nil then level = 'trace' end

  local log_level = vim.log.levels.INFO

  if level == 'info' then
    log_level = vim.log.levels.INFO
  elseif level == 'warn' then
    log_level = vim.log.levels.WARN
  elseif level == 'error' then
    log_level = vim.log.levels.ERROR
  elseif level == 'trace' then
    log_level = vim.log.levels.TRACE
  end

  vim.notify(M.name .. ': ' .. msg, log_level)
end

---@class NvmDefaultOptions
---@field add_to_path boolean Add found NVM bin directory to PATH
---@field nvm_path string Where nvm installation is located
---@field notify_level number|"info"|"warn"|"error"|"trace" Notification level filter

-- Default options
---@type NvmDefaultOptions
M.defaults = {
  add_to_path = vim.g.nvm_default_add_to_path or true,
  nvm_path = vim.fn.expand(os.getenv 'NVM_DIR' or '~/.nvm'),
  notify_level = vim.g.nvm_default_notify_level or 'info',
}

-- Fetch the NVM default version or fallback to node version
---@param opts? NvmDefaultOptions Plugin options
function M.setup(opts)
  local options = vim.tbl_deep_extend('force', M.defaults, opts or {})

  local nvm_path = options.nvm_path
  local node_version = run_command(
    string.format('. %s/nvm.sh && nvm version default', nvm_path)
  ) or run_command(string.format('. %s/nvm.sh && nvm version node', nvm_path)) or nil

  if node_version and node_version:match '^v' then
    -- Set vim.g.node_host_prog and vim.g.copilot_node_command
    local current_nvm_version_path =
      string.format('%s/versions/node/%s', nvm_path, node_version)
    local current_nvm_node_bin_path = string.format('%s/bin', current_nvm_version_path)
    local current_nvm_node_bin = string.format('%s/node', current_nvm_node_bin_path)
    local neovim_node_host_bin_path =
      string.format('%s/neovim-node-host', current_nvm_node_bin_path)

    -- Collect missing files and directories errors for error output
    local missing = {}

    -- If node_dir isn't there, stop and show error
    if not vim.fn.isdirectory(current_nvm_version_path) then
      table.insert(missing, 'Node.js directory: ' .. current_nvm_version_path)
    end

    -- If node_bin isn't there, stop and show error
    if not vim.fn.filereadable(current_nvm_node_bin) then
      table.insert(missing, 'Node.js binary: ' .. current_nvm_node_bin)
    end

    if not vim.fn.filereadable(neovim_node_host_bin_path) then
      table.insert(missing, 'Neovim host binary: ' .. neovim_node_host_bin_path)
    end

    if #missing > 0 then
      n('Missing required files:\n- ' .. table.concat(missing, '\n- '), 'error')
      return
    end

    -- Add to PATH if requested. Can be turned off by setting if it messes with
    -- other tools.
    if options.add_to_path then
      vim.env.PATH = current_nvm_node_bin_path .. ':' .. vim.env.PATH
    end

    vim.g.node_host_prog = neovim_node_host_bin_path
    vim.g.copilot_node_command = current_nvm_node_bin
  else
    n('Unable to determine the Node.js version from nvm.', 'error')
  end
end

return M
