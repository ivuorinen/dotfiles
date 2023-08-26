local vim = vim
local api = vim.api
local M = {}

--- function to create a list of commands and convert them to autocommands
--- This function is taken from https://github.com/norcalli/nvim_utils
function M.nvim_create_augroups(definitions)
  for group_name, definition in pairs(definitions) do
    api.nvim_command("augroup " .. group_name)
    api.nvim_command("autocmd!")
    for _, def in ipairs(definition) do
      local command = table.concat(vim.tbl_flatten({ "autocmd", def }), " ")
      api.nvim_command(command)
    end
    api.nvim_command("augroup END")
  end
end

local autoCommands = {
  -- To save the current session (may be restored later).
  -- autocmd! VimLeavePre * :mks! ~/.config/nvim/session.vim
  save_session = {
    { "VimLeavePre", "*", ":mks! ~/.local/state/nvim/session.vim" },
  },
  -- other autocommands
  open_folds = {
    { "BufReadPost,FileReadPost", "*", "normal zR<cr>" },
  },
}

M.nvim_create_augroups(autoCommands)
