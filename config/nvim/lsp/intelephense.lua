require 'utils'

return {
  cmd = { 'intelephense', '--stdio' },
  filetypes = { 'php' },
  root_markers = { 'composer.json', '.git' },
  init_options = {
    licenceKey = vim.env.INTELEPHENSE_LICENSE or GetIntelephenseLicense() or nil,
  },
}
