-- ╭─────────────────────────────────────────────────────────╮
-- │               LSP Setup and configuration               │
-- ╰─────────────────────────────────────────────────────────╯

require 'utils'

-- LSP Servers are installed and configured by lsp-setup.nvim
-- Mason formatters Conform uses to format files
-- These are automatically configured by zapling/mason-conform.nvim
local lsp_servers = {
  bashls = {},
  -- csharp_ls = {},
  diagnosticls = {},
  gopls = {
    settings = {
      gopls = {
        hints = {
          rangeVariableTypes = true,
          parameterNames = true,
          constantValues = true,
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          functionTypeParameters = true,
        },
      },
    },
  },
  html = {},
  intelephense = {
    init_options = {
      licenceKey = GetIntelephenseLicense(),
    },
  },
  jsonls = {},
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
        diagnostics = {
          globals = {
            'vim',
          },
          disable = {
            -- Ignore lua_ls noisy `missing-fields` warnings
            'missing-fields',
          },
        },
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
  },
  tailwindcss = {},
  ts_ls = {
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
    },
  },
  vimls = {},
  volar = {
    settings = {
      typescript = {
        inlayHints = {
          enumMemberValues = {
            enabled = true,
          },
          functionLikeReturnTypes = {
            enabled = true,
          },
          propertyDeclarationTypes = {
            enabled = true,
          },
          parameterTypes = {
            enabled = true,
            suppressWhenArgumentMatchesName = true,
          },
          variableTypes = {
            enabled = true,
          },
        },
      },
    },
  },
}

-- Mason tools to automatically install and configure.
-- These are automatically configured by WhoIsSethDaniel/mason-tool-installer.nvim
local mason_tools = {
  'actionlint',
  'ast-grep',
  'black',
  'editorconfig-checker',
  'goimports',
  'golangci-lint',
  'golines',
  'gopls',
  'gotests',
  'isort',
  'phpcbf',
  'phpmd',
  'phpstan',
  'pint',
  'prettierd',
  'revive',
  'semgrep',
  'shellcheck',
  'shfmt',
  'sonarlint-language-server',
  'staticcheck',
  'stylua',
  'trivy',
  'vint',
  'yamlfmt',
}

return {
  -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
  -- used for completion, annotations and signatures of Neovim apis
  -- https://github.com/folke/lazydev.nvim
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
        -- load assert and describe paths
        { path = 'luassert/library', words = { 'assert' } },
        { path = 'busted/library', words = { 'describe' } },
      },
    },
  },

  -- Meta type definitions for the Lua platform Luvit.
  -- https://github.com/Bilal2453/luvit-meta
  { 'Bilal2453/luvit-meta', lazy = true },

  -- Quickstart configs for Nvim LSP
  -- https://github.com/neovim/nvim-lspconfig
  { 'neovim/nvim-lspconfig' },

  -- Portable package manager for Neovim that runs everywhere Neovim runs.
  -- Easily install and manage LSP servers, DAP servers, linters, and formatters.
  -- https://github.com/williamboman/mason.nvim
  {
    'williamboman/mason.nvim',
    version = '*',
    cmd = 'Mason',
    run = ':MasonUpdate',
    opts = {},
  },

  -- Extensible UI for Neovim notifications and LSP progress messages.
  -- https://github.com/j-hui/fidget.nvim
  {
    'j-hui/fidget.nvim',
    version = '*',
    opts = {},
  },

  -- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim.
  -- https://github.com/williamboman/mason-lspconfig.nvim
  { 'williamboman/mason-lspconfig.nvim' },

  -- Install and upgrade third party tools automatically
  -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    version = '*',
    opts = {
      auto_install = true,
      auto_update = true,
      ensure_installed = mason_tools,
    },
  },

  -- JSON schemas for Neovim
  -- https://github.com/b0o/SchemaStore.nvim
  { 'b0o/schemastore.nvim' },

  -- Performant, batteries-included completion plugin for Neovim
  -- https://github.com/saghen/blink.cmp
  -- See lua/plugins/blink.lua for configs
  { 'saghen/blink.cmp' },

  -- A simple wrapper for nvim-lspconfig and mason-lspconfig
  -- to easily setup LSP servers.
  -- https://github.com/junnplus/lsp-setup.nvim
  {
    'junnplus/lsp-setup.nvim',
    opts = {
      default_mappings = false,
      servers = lsp_servers,
    },
    config = function(_, opts)
      require('lazydev').setup()
      require('lsp-setup').setup(opts)
      local cmp = require 'blink.cmp'
      local lspconfig = require 'lspconfig'
      for server, config in pairs(opts.servers) do
        -- passing config.capabilities to blink.cmp merges with the capabilities in your
        -- `opts[server].capabilities, if you've defined it
        config.capabilities = cmp.get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end

      lspconfig.lua_ls.on_init = function(client)
        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if
            vim.loop.fs_stat(path .. '/.luarc.json')
            or vim.loop.fs_stat(path .. '/.luarc.jsonc')
          then
            return
          end
        end
        client.config.settings.Lua =
          vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              -- Tell the language server which version of Lua you're using
              -- (most likely LuaJIT in the case of Neovim)
              version = 'LuaJIT',
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
              },
            },
          })
      end
      lspconfig.jsonls.settings = {
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
      }

      -- Diagnostic configuration
      local signs = {
        { name = 'DiagnosticSignError', text = '' }, -- Error icon
        { name = 'DiagnosticSignWarn', text = '' }, -- Warning icon
        { name = 'DiagnosticSignHint', text = '' }, -- Hint icon
        { name = 'DiagnosticSignInfo', text = '' }, -- Information icon
      }

      local function ensure_sign_defined(name, sign_opts)
        if vim.tbl_isempty(vim.fn.sign_getdefined(name)) then
          vim.fn.sign_define(name, sign_opts)
        end
      end

      for _, sign in ipairs(signs) do
        ensure_sign_defined(sign.name, {
          text = sign.text,
          texthl = sign.texthl or sign.name,
          numhl = sign.numhl or sign.name,
        })
      end

      ---@type vim.diagnostic.Opts
      local diagnostics_config = {
        signs = {
          active = signs, -- show signs
        },
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        virtual_text = true,
      }

      vim.diagnostic.config(diagnostics_config)

      -- end of junnplus/lsp-setup config
    end,
  },

  -- Lightweight yet powerful formatter plugin for Neovim
  -- https://github.com/stevearc/conform.nvim
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    opts = {
      notify_on_error = false,
      ---@type nil|conform.FormatOpts|fun(bufnr: integer): nil|conform.FormatOpts
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = 'never'
        else
          lsp_format_opt = 'fallback'
        end

        -- Disable autoformat for files in a certain paths
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname:match '/dist|node_modules|vendor/' then return end

        return {
          timeout_ms = 500,
          lsp_format = lsp_format_opt,
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        php = { 'phpcbf' },
        python = { 'isort', 'black' },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
    init = function()
      -- If you want the formatexpr, here is the place to set it
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
  -- Automatically install formatters registered with conform.nvim via mason.nvim
  -- https://github.com/zapling/mason-conform.nvim
  { 'zapling/mason-conform.nvim', opts = {} },
}
