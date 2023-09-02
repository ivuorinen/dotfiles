-- 🗺️ A legend for your keymaps, commands, and autocmds, with which-key.nvim integration
-- https://github.com/mrjones2014/legendary.nvim
return {
  "mrjones2014/legendary.nvim",
  version = "*",
  -- since legendary.nvim handles all your keymaps/commands,
  -- its recommended to load legendary.nvim before other plugins
  priority = 10000,
  lazy = false,
  -- sqlite is only needed if you want to use frecency sorting
  -- dependencies = { 'kkharji/sqlite.lua' }
  opts = {
    lazy_nvim = {
      auto_register = true,
    },
    which_key = {
      auto_register = true,
    },
  },
}
