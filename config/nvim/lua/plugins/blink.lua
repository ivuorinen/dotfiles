return {
  -- add blink.compat
  {
    'saghen/blink.compat',
    -- use the latest release, via version = '*', if you also use the latest release for blink.cmp
    version = '*',
    -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
    lazy = true,
    -- make sure to set opts so that lazy.nvim calls blink.compat's setup
    opts = {
      impersonate_nvim_cmp = true,
    },
  },
  {
    'saghen/blink.cmp',
    lazy = false, -- lazy loading handled internally
    -- optional: provides snippets for the snippet source
    dependencies = {
      'rafamadriz/friendly-snippets',
      -- Lua plugin to turn github copilot into a cmp source
      -- https://github.com/giuxtaposition/blink-cmp-copilot
      {
        "giuxtaposition/blink-cmp-copilot",
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
    -- use a release tag to download pre-built binaries
    version = '*',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' for mappings similar to built-in completion
      -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
      -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
      -- see the "default configuration" section below for full documentation on how to define
      -- your own keymap.
      keymap = {
        preset = 'super-tab',
        ['<C-x>'] = { 'show', 'show_documentation', 'hide_documentation' },
      },

      appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- will be removed in a future release
        use_nvim_cmp_as_default = true,
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      completion = {
        menu = {
          draw = {
            columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind", gap = 1 } },
          },
        },
        documentation = {
          auto_show = true
        },
        ghost_text = {
          enabled = true,
        },
      },

      -- default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, via `opts_extend`
      sources = {
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-cmp-copilot'
          },
        },
        completion = {
          enabled_providers = {
            'lsp',
            'copilot',
            'path',
            'snippets',
            'buffer',
          },
        },
      },

      -- experimental auto-brackets support
      -- completion = { accept = { auto_brackets = { enabled = true } } }

      -- experimental signature help support
      signature = { enabled = true }
    },
    -- allows extending the enabled_providers array elsewhere in your config
    -- without having to redefine it
    opts_extend = { "sources.completion.enabled_providers" },
  },
}
