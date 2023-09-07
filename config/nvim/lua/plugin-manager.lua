-- Package manager https://github.com/folke/lazy.nvim
-- :help lazy.nvim.txt
-- luacheck: globals vim

-- To install lazy.nvim automatically.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local options = {
  defaults = { lazy = false },
  install = { colorscheme = { "catppuccin" } },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      disabled_plugins = {
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tohtml",
        "tutor",
      },
    },
  },
}

require("lazy").setup("plugins", options)
