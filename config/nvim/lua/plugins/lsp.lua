return {
  -- improve neovim lsp experience
  -- https://github.com/nvimdev/lspsaga.nvim
  -- https://nvimdev.github.io/lspsaga/
  {
    'nvimdev/lspsaga.nvim',
    event = 'LspAttach',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    ---@type LspsagaConfig
    opts = {
      code_action = {
        show_server_name = true,
        keys = {
          quit = { 'q', '<ESC>' },
        },
      },
      diagnostic = {
        keys = {
          quit = { 'q', '<ESC>' },
        },
      },
    },
  },
  -- A simple wrapper for nvim-lspconfig and mason-lspconfig
  -- to easily setup LSP servers.
  -- https://github.com/junnplus/lsp-setup.nvim
  {
    'junnplus/lsp-setup.nvim',
    dependencies = {
      { 'neovim/nvim-lspconfig' },
      {
        'williamboman/mason.nvim',
        cmd = 'Mason',
        run = ':MasonUpdate'
      },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'folke/neodev.nvim' },
      { 'b0o/schemastore.nvim' },
      { 'saghen/blink.cmp' },
    },
    opts = {
      default_mappings = false,
      mappings = {
        gd = 'lua require"telescope.builtin".lsp_definitions()',
        gi = 'lua require"telescope.builtin".lsp_implementations()',
        gr = 'lua require"telescope.builtin".lsp_references()',
      },
      inlay_hints = {
        enabled = true,
      },
      servers = {
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
        intelephense = {},
        jsonls = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { 'vim' },
                disable = {
                  -- Ignore lua_ls noisy `missing-fields` warnings
                  'missing-fields',
                },
              },
              hint = {
                enable = false,
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
      },
    },
    config = function(_, opts)
      require('neodev').setup()
      require('lsp-setup').setup(opts)
      local lspconfig = require('lspconfig')
      for server, config in pairs(opts.servers) do
        -- passing config.capabilities to blink.cmp merges with the capabilities in your
        -- `opts[server].capabilities, if you've defined it
        config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end

      lspconfig.lua_ls.on_init = function(client)
        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
            return
          end
        end
        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME
            }
          }
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
    end,
  },
}
