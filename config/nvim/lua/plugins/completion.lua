return {
  -- Performant, batteries-included completion plugin for Neovim
  -- https://github.com/saghen/blink.cmp
  {
    'saghen/blink.cmp',
    version = '*',
    lazy = false, -- lazy loading handled internally
    ---@module 'blink.cmp'
    opts = {
      keymap = {
        preset = 'default',
        ['<C-x>'] = { 'show', 'show_documentation', 'hide_documentation' },
      },

      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = vim.g.nerd_font_variant or 'mono',
      },

      completion = {
        menu = {
          draw = {
            columns = {
              { 'label', 'label_description', gap = 1 },
              { 'kind_icon', 'kind', gap = 1 },
            },
          },
        },
        documentation = {
          auto_show = false,
          auto_show_delay_ms = 500,
        },
        ghost_text = {
          enabled = false,
        },
      },

      sources = {
        default = {
          'lsp',
          'path',
          'snippets',
          'buffer',
        },
      },

      fuzzy = { implementation = 'lua' },

      signature = { enabled = true },
    },
    opts_extend = { 'sources.completion.enabled_providers' },
  },
}
