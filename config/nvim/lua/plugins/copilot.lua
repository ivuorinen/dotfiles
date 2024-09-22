-- CoPilot
-- https://github.com/zbirenbaum/copilot.lua
return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  build = ':Copilot setup',
  event = { 'InsertEnter', 'LspAttach' },
  fix_pairs = true,
  opts = {
    suggestion = { enabled = false },
    panel = { enabled = false },
    filetypes = {
      markdown = true,
      help = true,
    },
  },
}
