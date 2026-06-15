return {
  init_options = {
    -- Chain: $INTELEPHENSE_LICENSE env var → ~/intelephense/license.txt → nil (free tier)
    licenceKey = vim.env.INTELEPHENSE_LICENSE or GetIntelephenseLicense(),
  },
}
