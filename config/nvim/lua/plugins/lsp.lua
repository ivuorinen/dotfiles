-- ╭─────────────────────────────────────────────────────────╮
-- │               LSP Setup and configuration               │
-- ╰─────────────────────────────────────────────────────────╯

require 'utils'

return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      'folke/lazydev.nvim',
      'zapling/mason-conform.nvim',

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',

      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      local lazydev = require 'lazydev'

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(
              mode,
              keys,
              func,
              { buffer = event.buf, desc = 'LSP: ' .. desc }
            )
          end

          local tsb = require 'telescope.builtin'

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>grn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map(
            '<leader>gra',
            vim.lsp.buf.code_action,
            '[G]oto Code [A]ction',
            { 'n', 'x' }
          )

          -- Find references for the word under your cursor.
          map('<leader>grr', tsb.lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without
          --  an actual implementation.
          map('<leader>gri', tsb.lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is
          --  defined, etc. To jump back, press <C-t>.
          map('<leader>grd', tsb.lsp_definitions, '[G]oto [D]efinition')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('<leader>grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>gO', tsb.lsp_document_symbols, 'Open Document Symbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>gW', tsb.lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>grt', tsb.lsp_type_definitions, '[G]oto [T]ype Definition')

          -- This function resolves a difference between neovim nightly
          -- (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              ---@diagnostic disable-next-line: param-type-mismatch
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared
          -- (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if
            client
            and client_supports_method(
              client,
              vim.lsp.protocol.Methods.textDocument_documentHighlight,
              event.buf
            )
          then
            local highlight_augroup =
              vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
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
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds {
                  group = 'lsp-highlight',
                  buffer = event2.buf,
                }
              end,
            })
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
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

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local servers = {
        ansiblels = {},
        ast_grep = {},
        bashls = {},
        cssls = {},
        dockerls = {},
        gopls = {
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
        },
        html = {},
        intelephense = {
          init_options = {
            licenceKey = vim.env.INTELEPHENSE_LICENSE or GetIntelephenseLicense() or nil,
          },
        },
        jsonls = {},
        lua_ls = {
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
            client.notify(
              'workspace/didChangeConfiguration',
              { settings = client.config.settings }
            )
          end,
        },
        pyright = {},
        tailwindcss = {},
        terraformls = {},
        ts_ls = {},
        vimls = {},
        eslint = {},
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false, -- don't auto-sort YAML keys on format
              schemaStore = { enable = true }, -- use JSON Schema Store for validation
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'actionlint', -- GitHub Actions linter
        'shfmt', -- Shell formatter
        'stylua', -- Lua formatter
        'shellcheck', -- Shell linter
      })

      require('mason-tool-installer').setup {
        auto_install = true,
        auto_update = true,
        ensure_installed = ensure_installed,
      }

      require('mason-conform').setup {
        ensure_installed = ensure_installed,
      }

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table
        automatic_enable = true,
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities =
              vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }

      lazydev.setup {
        ---@type boolean|(fun(root:string):boolean?)
        enabled = true,
        debug = false,
        runtime = vim.env.VIMRUNTIME --[[@as string]],
        library = {
          { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
        integrations = {
          lspconfig = true,
          cmp = true,
        },
      }
    end,
  },
}
