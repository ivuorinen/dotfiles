return {
  -- Performant, batteries-included completion plugin for Neovim
  -- https://github.com/saghen/blink.cmp
  {
    'saghen/blink.cmp',
    version = '*',
    lazy = false, -- lazy loading handled internally
    dependencies = {
      -- Compatibility layer for using nvim-cmp sources on blink.cmp
      -- https://github.com/Saghen/blink.compat
      {
        'saghen/blink.compat',
        version = '*',
        opts = {
          impersonate_nvim_cmp = true,
        },
      },

      -- Lua plugin to turn github copilot into a cmp source
      -- https://github.com/giuxtaposition/blink-cmp-copilot
      {
        'giuxtaposition/blink-cmp-copilot',
        dependencies = {
          -- Fully featured & enhanced replacement for copilot.vim complete
          -- with API for interacting with Github Copilot
          -- https://github.com/zbirenbaum/copilot.lua
          {
            'zbirenbaum/copilot.lua',
            cmd = 'Copilot',
            build = ':Copilot setup',
            event = { 'InsertEnter', 'LspAttach' },
            opts = {
              fix_pairs = true,
              suggestion = { enabled = false },
              panel = { enabled = false },
              filetypes = {
                markdown = true,
              },
            },
          },
        },
      },
    },
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
          'copilot',
          'path',
          'snippets',
          'buffer',
          'lazydev',
        },
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-cmp-copilot',
          },
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },

      fuzzy = { implementation = 'lua' },

      signature = { enabled = true },
    },
    opts_extend = { 'sources.completion.enabled_providers' },
  },
}
