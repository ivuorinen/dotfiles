-- Auto completion
-- https://github.com/hrsh7th/nvim-cmp
return {
  {
    'hrsh7th/nvim-cmp',
    lazy = false,
    version = false, -- Use the latest version of the plugin
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',

      -- ── LuaSnip Dependencies ────────────────────────────────────────────
      -- Snippet Engine for Neovim written in Lua.
      -- https://github.com/L3MON4D3/LuaSnip
      {
        'L3MON4D3/LuaSnip',
        build = 'make install_jsregexp',
        dependencies = {
          -- luasnip completion source for nvim-cmp
          -- https://github.com/saadparwaiz1/cmp_luasnip
          'saadparwaiz1/cmp_luasnip',
          'rafamadriz/friendly-snippets',
        },
      },
      { 'saadparwaiz1/cmp_luasnip' },

      -- ── Adds other completion capabilities. ─────────────────────────────
      -- ── nvim-cmp does not ship with all sources by default.
      -- ── They are split into multiple repos for maintenance purposes.
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-nvim-lsp-signature-help' },
      { 'hrsh7th/cmp-emoji' },
      { 'hrsh7th/cmp-cmdline' },
      -- cmp import and use all environment variables from .env.* and system
      -- https://github.com/SergioRibera/cmp-dotenv
      { 'SergioRibera/cmp-dotenv' },
      -- A dictionary completion source for nvim-cmp
      -- https://github.com/uga-rosa/cmp-dictionary
      { 'uga-rosa/cmp-dictionary' },
      -- An additional source for nvim-cmp to autocomplete packages and its versions
      -- https://github.com/David-Kunz/cmp-npm
      {
        'David-Kunz/cmp-npm',
        dependencies = { 'nvim-lua/plenary.nvim' },
        ft = 'json',
        opts = {},
      },
      -- https://github.com/chrisgrieser/cmp-nerdfont
      { 'chrisgrieser/cmp-nerdfont' },

      -- ── Other deps ──────────────────────────────────────────────────────
      -- vscode-like pictograms for neovim lsp completion items
      -- https://github.com/onsails/lspkind.nvim
      { 'onsails/lspkind.nvim' },
      -- Lua plugin to turn github copilot into a cmp source
      -- https://github.com/zbirenbaum/copilot-cmp
      {
        'zbirenbaum/copilot-cmp',
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
                help = true,
              },
            },
          },
        },
        config = function() require('copilot_cmp').setup() end,
      },
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local lspkind = require 'lspkind'
      luasnip.config.setup {}
      require('luasnip.loaders.from_vscode').lazy_load()
      require('copilot_cmp').setup()

      require('cmp_dictionary').setup {
        paths = { '/usr/share/dict/words' },
        exact_length = 2,
      }

      local has_words_before = function()
        if vim.api.nvim_get_option_value('buftype', {}) == 'prompt' then
          return false
        end
        local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0
          and vim.api
              .nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]
              :match '^%s*$'
            == nil
      end

      cmp.setup {
        formatting = {
          format = lspkind.cmp_format {
            mode = 'symbol',
            max_width = function() return math.floor(0.45 * vim.o.columns) end,
            show_labelDetails = true,
            symbol_map = {
              Copilot = '',
              Text = '',
              Constructor = '',
            },
          },
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        view = {
          width = function(_, _) return math.min(80, vim.o.columns) end,
          -- entries = {
          --   name = 'custom',
          --   selection_order = 'near_cursor',
          -- },
        },
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-c>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() and has_words_before() then
              cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = {
          -- function arg popups while typing
          { name = 'nvim_lsp_signature_help', group_index = 2 },

          -- Copilot Source
          { name = 'copilot', group_index = 2 },
          -- Other Sources
          { name = 'dictionary', keyword_length = 2, group_index = 2 },
          { name = 'npm', keyword_length = 4, group_index = 2 },
          { name = 'nvim_lsp', group_index = 2 },
          { name = 'luasnip', group_index = 2 },
          { name = 'dotenv', group_index = 2 },
          { name = 'path', group_index = 2 },
          { name = 'emoji', group_index = 2 },
          { name = 'nerdfont', group_index = 2 },
        },
        sorting = {
          priority_weight = 2,
          comparators = {
            require('copilot_cmp.comparators').prioritize,

            -- Below is the default comparator list and order for nvim-cmp
            cmp.config.compare.offset,
            cmp.config.compare.scopes, --this is commented in nvim-cmp too
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
      }

      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' },
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' },
        }, {
          { name = 'cmdline' },
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
      })
    end,
  },
  -- Luasnip choice node completion source for nvim-cmp
  -- https://github.com/doxnit/cmp-luasnip-choice
  {
    'doxnit/cmp-luasnip-choice',
    config = function()
      require('cmp_luasnip_choice').setup {
        auto_open = true, -- Automatically open nvim-cmp on choice node (default: true)
      }
    end,
  },
}
