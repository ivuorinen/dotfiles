return {
  init_options = {
    licenceKey = vim.env.INTELEPHENSE_LICENSE or GetIntelephenseLicense() or nil,
  },
}
