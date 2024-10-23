-- ── Mason and LSPConfig integration ────────────────────────────────────

-- ── LSP settings. ───────────────────────────────────────────────
--  This function gets run when an LSP connects to a particular buffer.

-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
-- Tell the server the capability of foldingRange,
-- Neovim hasn't added foldingRange to default capabilities, users must add it manually
capabilities.textDocument.foldingRange = {
  dynamicRegistration = true,
  lineFoldingOnly = true,
}

return {
  {
    'folke/neoconf.nvim',
    cmd = 'Neoconf',
    opts = {},
  },
  -- Portable package manager for Neovim that runs everywhere Neovim runs.
  -- Easily install and manage LSP servers, DAP servers, linters, and formatters.
  -- https://github.com/williamboman/mason.nvim
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    run = ':MasonUpdate',
    opts = {
      PATH = 'prepend',
      -- Mason servers to install
      -- See: https://mason-registry.dev/registry/list
      ensure_installed = {
        'clang-format',
        'codespell',
        'commitlint',
        'editorconfig-checker',
        'fixjson',
        'jsonlint',
        'luacheck',
        'phpcbf',
        'phpcs',
        'phpmd',
        'prettier',
        'shellcheck',
        'shfmt',
        'stylua',
        'yamllint',
      },
    },
  },
  -- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim.
  -- https://github.com/williamboman/mason-lspconfig.nvim
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      -- ── Enable the following language servers ───────────────────────────
      -- :help lspconfig-all for all pre-configured LSPs
      ensure_installed = {
        'bashls',
        -- 'csharp_ls',
        'diagnosticls',
        'gopls',
        'html',
        'intelephense',
        'jsonls',
        'lua_ls',
        'tailwindcss',
        'ts_ls',
        'vimls',
        'volar',
      },
      automatic_installation = true,
      handlers = {
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.
        function(server_name) -- default handler (optional)
          require('lspconfig')[server_name].setup {
            on_attach = function(_, bufnr)
              -- Create a command `:Format` local to the LSP buffer
              vim.api.nvim_buf_create_user_command(
                bufnr,
                'Format',
                function(_)
                  require('conform').format {
                    formatters = { 'injected' },
                    async = true,
                    lsp_fallback = true,
                  }
                end,
                { desc = 'Format current buffer with LSP' }
              )
            end,
            capabilities = capabilities,
          }
        end,
        -- Next, you can provide targeted overrides for specific servers.
        ['lua_ls'] = function()
          require('lspconfig')['lua_ls'].setup {
            on_attach = function(_, bufnr)
              -- Create a command `:Format` local to the LSP buffer
              vim.api.nvim_buf_create_user_command(
                bufnr,
                'Format',
                function(_)
                  require('conform').format {
                    formatters = { 'injected' },
                    async = true,
                    lsp_fallback = true,
                  }
                end,
                { desc = 'Format current buffer with LSP' }
              )
            end,
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = {
                  -- Tell the language server which version of Lua you're
                  -- using (most likely LuaJIT)
                  version = 'LuaJIT',
                  -- Setup your lua path
                  path = runtime_path,
                },
                diagnostics = {
                  globals = { 'vim' },
                  disable = {
                    -- Ignore lua_ls noisy `missing-fields` warnings
                    'missing-fields',
                  },
                },
                workspace = {
                  library = vim.api.nvim_get_runtime_file('', true),
                  checkThirdParty = false,
                },
                -- Do not send telemetry data containing a randomized
                -- but unique identifier
                telemetry = { enable = false },

                completion = {
                  callSnippet = 'Replace',
                },
              },
            },
          }
        end,
        ['jsonls'] = function()
          require('lspconfig')['jsonls'].setup {
            on_attach = function(_, bufnr)
              -- Create a command `:Format` local to the LSP buffer
              vim.api.nvim_buf_create_user_command(
                bufnr,
                'Format',
                function(_)
                  require('conform').format {
                    formatters = { 'injected' },
                    async = true,
                    lsp_fallback = true,
                  }
                end,
                { desc = 'Format current buffer with LSP' }
              )
            end,
            capabilities = capabilities,
            settings = {
              json = {
                schemas = require('schemastore').json.schemas(),
                validate = { enable = true },
              },
              yaml = {
                schemaStore = {
                  -- You must disable built-in SchemaStore support if you want to use
                  -- this plugin and its advanced options like `ignore`.
                  enable = false,
                  -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                  url = '',
                },
                schemas = require('schemastore').yaml.schemas(),
                validate = { enable = true },
              },
            },
          }
        end,
        ['ts_ls'] = function()
          local mason_registry = require 'mason-registry'
          local ts_plugin_location = mason_registry
            .get_package('vue-language-server')
            :get_install_path() .. '/node_modules/@vue/typescript-plugin'
          require('lspconfig')['volar'].setup {
            init_options = {
              plugins = {
                {
                  name = '@vue/typescript-plugin',
                  location = ts_plugin_location,
                  languages = { 'javascript', 'typescript', 'vue' },
                },
              },
            },
            filetypes = {
              'typescript',
              'javascript',
              'javascriptreact',
              'typescriptreact',
              'vue',
            },
          }
        end,
      },
    },
  },

  -- ── Misc ───────────────────────────────────────────────────
  -- vscode-like pictograms for neovim lsp completion items
  -- https://github.com/onsails/lspkind-nvim
  { 'onsails/lspkind.nvim', opts = {} },
  -- JSON schemas for Neovim
  -- https://github.com/b0o/SchemaStore.nvim
  { 'b0o/schemastore.nvim' },

  -- ── LSP ────────────────────────────────────────────────────
  -- Quick start configs for Nvim LSP
  -- https://github.com/neovim/nvim-lspconfig
  { 'neovim/nvim-lspconfig', dependencies = { 'folke/neoconf.nvim' } },

  -- Garbage collector that stops inactive LSP clients to free RAM
  -- https://github.com/Zeioth/garbage-day.nvim
  {
    'zeioth/garbage-day.nvim',
    dependencies = 'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    opts = {},
  },
}
