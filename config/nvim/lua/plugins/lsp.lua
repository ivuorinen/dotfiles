-- ╭─────────────────────────────────────────────────────────╮
-- │               LSP Setup and configuration               │
-- ╰─────────────────────────────────────────────────────────╯

require 'utils'

return {
  {
    'williamboman/mason.nvim',
    lazy = false,
    opts = {},
  },

  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'saghen/blink.cmp',
    },
    config = function()
      require('mason-tool-installer').setup {
        auto_install = true,
        auto_update = true,
        ensure_installed = {
          -- LSP servers (mason package names)
          'ansible-language-server',
          'ast-grep',
          'bash-language-server',
          'css-lsp',
          'dockerfile-language-server',
          'eslint-lsp',
          'gopls',
          'html-lsp',
          'intelephense',
          'json-lsp',
          'lua-language-server',
          'pyright',
          'tailwindcss-language-server',
          'terraform-ls',
          'typescript-language-server',
          'vim-language-server',
          'yaml-language-server',
          -- Tools
          'actionlint',
          'shfmt',
          'stylua',
          'shellcheck',
        },
      }

      -- ╭─────────────────────────────────────────────────────────╮
      -- │     Native LSP configuration (nvim 0.11+)              │
      -- │     Uses vim.lsp.config() + vim.lsp.enable()           │
      -- ╰─────────────────────────────────────────────────────────╯

      -- Set global capabilities from blink.cmp for all LSP servers
      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
      })

      -- ── Per-server configuration ──────────────────────────────
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' },
              disable = { 'missing-fields' },
            },
            completion = { callSnippet = 'Replace' },
            workspace = { checkThirdParty = true },
            hint = {
              enable = true,
              arrayIndex = 'Auto',
              await = true,
              paramName = 'All',
              paramType = true,
              semicolon = 'SameLine',
              setType = false,
            },
          },
        },
        on_init = function(client)
          client.config.settings.Lua.workspace.library = {
            vim.env.VIMRUNTIME,
          }
          client.config.settings.Lua.runtime = { version = 'LuaJIT' }
          client:notify(
            'workspace/didChangeConfiguration',
            { settings = client.config.settings }
          )
        end,
      })

      vim.lsp.config('gopls', {
        settings = {
          gopls = {
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })

      vim.lsp.config('intelephense', {
        init_options = {
          licenceKey = vim.env.INTELEPHENSE_LICENSE or GetIntelephenseLicense() or nil,
        },
      })

      vim.lsp.config('yamlls', {
        settings = {
          yaml = {
            keyOrdering = false,
            schemaStore = { enable = true },
          },
        },
      })

      -- Servers with default config (no custom settings needed)
      local default_servers = {
        'ansiblels',
        'ast_grep',
        'bashls',
        'cssls',
        'dockerls',
        'eslint',
        'html',
        'jsonls',
        'pyright',
        'tailwindcss',
        'terraformls',
        'ts_ls',
        'vimls',
      }
      for _, server in ipairs(default_servers) do
        vim.lsp.config(server, {})
      end

      -- ── Enable all servers ────────────────────────────────────
      local all_servers = vim.list_extend(
        vim.deepcopy(default_servers),
        { 'gopls', 'intelephense', 'lua_ls', 'yamlls' }
      )
      vim.lsp.enable(all_servers)

      -- ── Diagnostic Config ─────────────────────────────────────
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- ── LSP Highlight (cursor word) ──────────────────────────
      local lsp_detach_augroup =
        vim.api.nvim_create_augroup('lsp-detach', { clear = true })
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-highlight', { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if
            client
            and client:supports_method(
              vim.lsp.protocol.Methods.textDocument_documentHighlight,
              event.buf
            )
          then
            local highlight_augroup =
              vim.api.nvim_create_augroup('lsp-highlight-refs', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = lsp_detach_augroup,
              buffer = event.buf,
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds {
                  group = 'lsp-highlight-refs',
                  buffer = event2.buf,
                }
              end,
            })
          end
        end,
      })
    end,
  },

  {
    'zapling/mason-conform.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {},
  },

  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      enabled = true,
      debug = false,
      runtime = vim.env.VIMRUNTIME,
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  { 'j-hui/fidget.nvim', opts = {} },
}
