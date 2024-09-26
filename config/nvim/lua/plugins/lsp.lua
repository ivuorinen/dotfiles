-- Quickstart configs for Nvim LSP
-- https://github.com/neovim/nvim-lspconfig
return {
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    dependencies = {
      -- Neovim plugin to manage global and project-local settings
      -- Should be included before LSP Config
      -- https://github.com/folke/neoconf.nvim
      { 'folke/neoconf.nvim', opts = {} },

      -- Garbage collector that stops inactive LSP clients to free RAM
      -- https://github.com/Zeioth/garbage-day.nvim
      {
        'zeioth/garbage-day.nvim',
        dependencies = 'neovim/nvim-lspconfig',
        event = 'VeryLazy',
        opts = {},
      },

      -- improve neovim lsp experience
      -- https://github.com/nvimdev/lspsaga.nvim
      {
        'nvimdev/lspsaga.nvim',
        dependencies = {
          'nvim-treesitter/nvim-treesitter', -- optional
          'nvim-tree/nvim-web-devicons', -- optional
        },
        opts = {
          code_action = {
            show_server_name = true,
          },
          diagnostic = {
            keys = {
              quit = { 'q', '<ESC>' },
            },
          },
        },
      },

      -- ── Mason and LSPConfig integration ─────────────────────────────────
      -- Automatically install LSPs to stdpath for neovim

      -- Portable package manager for Neovim that runs everywhere Neovim runs.
      -- Easily install and manage LSP servers, DAP servers, linters,
      -- and formatters.
      -- https://github.com/williamboman/mason.nvim
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'WhoIsSethDaniel/mason-tool-installer.nvim' },

      -- ── Linting ─────────────────────────────────────────────────────────
      -- An asynchronous linter plugin for Neovim complementary to the
      -- built-in Language Server Protocol support.
      -- https://github.com/mfussenegger/nvim-lint
      {
        'mfussenegger/nvim-lint',
        event = { 'BufReadPre', 'BufNewFile' },
      },
      -- Extension to mason.nvim that makes it
      -- easier to use nvim-lint with mason.nvim
      -- https://github.com/rshkarin/mason-nvim-lint
      { 'rshkarin/mason-nvim-lint' },

      -- ── Misc ────────────────────────────────────────────────────────────
      -- vscode-like pictograms for neovim lsp completion items
      -- https://github.com/onsails/lspkind-nvim
      { 'onsails/lspkind.nvim' },
      -- JSON schemas for Neovim
      -- https://github.com/b0o/SchemaStore.nvim
      { 'b0o/schemastore.nvim' },
    },
    config = function()
      -- ── LSP settings. ───────────────────────────────────────────────────
      --  This function gets run when an LSP connects to a particular buffer.

      -- Make runtime files discoverable to the server
      local runtime_path = vim.split(package.path, ';')
      table.insert(runtime_path, 'lua/?.lua')
      table.insert(runtime_path, 'lua/?/init.lua')

      -- Generate a command `:Format` local to the LSP buffer
      --
      ---@param _     nil    Skipped
      ---@param bufnr number Buffer number
      ---@output nil
      local on_attach = function(_, bufnr)
        -- Create a command `:Format` local to the LSP buffer
        vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
          if vim.lsp.buf.format then
            vim.lsp.buf.format()
          elseif vim.lsp.buf.formatting then
            vim.lsp.buf.formatting()
          else
            require('conform').format { async = true, lsp_fallback = true }
          end
        end, { desc = 'Format current buffer with LSP' })
      end

      -- ── Setup mason so it can manage external tooling ───────────────────
      require('mason').setup()

      -- ── Enable the following language servers ───────────────────────────
      -- :help lspconfig-all for all pre-configured LSPs
      local servers = {
        ast_grep = {},

        actionlint = {}, -- GitHub Actions
        ansiblels = {}, -- Ansible
        bashls = {}, -- Bash
        -- csharp_ls = {}, -- C#, requires dotnet executable
        css_variables = {}, -- CSS
        cssls = {}, -- CSS
        docker_compose_language_service = {}, -- Docker compose
        dockerls = {}, -- Docker
        eslint = {}, -- ESLint
        gitlab_ci_ls = {}, -- GitLab CI
        gopls = {}, -- Go
        html = {}, -- HTML
        intelephense = {}, -- PHP
        pest_ls = {}, -- Pest (PHP)
        phpactor = {}, -- PHP
        psalm = {}, -- PHP
        pyright = {}, -- Python
        semgrep = {}, -- Security
        shellcheck = {}, -- Shell scripts
        shfmt = {}, -- Shell scripts formatting
        stylelint_lsp = {}, -- Stylelint for S/CSS
        stylua = {}, -- Used to format Lua code
        tailwindcss = {}, -- Tailwind CSS
        terraformls = {}, -- Terraform
        tflint = {}, -- Terraform
        ts_ls = {}, -- TypeScript/JS
        typos_lsp = {}, -- Better writing
        volar = {}, -- Vue
        yamlls = {}, -- YAML

        lua_ls = {
          settings = {
            Lua = {
              runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT)
                version = 'LuaJIT',
                -- Setup your lua path
                path = runtime_path,
              },
              diagnostics = {
                globals = { 'vim' },
                disable = {
                  -- Ignore Lua_LS's noisy `missing-fields` warnings
                  'missing-fields',
                },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false,
              },
              -- Do not send telemetry data containing a randomized but unique identifier
              telemetry = { enable = false },

              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
        jsonls = {
          settings = {
            json = {
              schemas = require('schemastore').json.schemas(),
              validate = { enable = true },
            },
            yaml = {
              schemaStore = {
                -- You must disable built-in schemaStore support if you want to use
                -- this plugin and its advanced options like `ignore`.
                enable = false,
                -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                url = '',
              },
              schemas = require('schemastore').yaml.schemas(),
              validate = { enable = true },
            },
          },
        },
      }

      -- Mason servers should be it's own variable for mason-nvim-lint
      -- See: https://mason-registry.dev/registry/list
      local mason_servers = {
        'actionlint',
        'ansible-language-server',
        'ansible-lint',
        'bash-language-server',
        'blade-formatter',
        'clang-format',
        'commitlint',
        'diagnostic-languageserver',
        'docker-compose-language-service',
        'dockerfile-language-server',
        'editorconfig-checker',
        'fixjson',
        'flake8',
        'html-lsp',
        'jq',
        'jsonlint',
        'luacheck',
        'php-cs-fixer',
        'phpcs',
        'phpmd',
        'semgrep',
        'shellcheck',
        'shfmt',
        'stylelint',
        'stylua',
        'vue-language-server',
        'yamllint',
      }
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, mason_servers)

      -- ── Automagically install tools ─────────────────────────────────────
      require('mason-tool-installer').setup {
        ensure_installed = ensure_installed,
        auto_update = true,
      }

      -- ── Ensure the servers above are installed ──────────────────────────
      require('mason-lspconfig').setup {
        automatic_installation = true,
        ensure_installed = servers,
      }

      -- nvim-cmp supports additional completion capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      require('mason-lspconfig').setup_handlers {
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.
        function(server_name) -- default handler (optional)
          require('lspconfig')[server_name].setup {}
        end,
        -- Next, you can provide a dedicated handler for specific servers.
        -- For example, a handler override for the `rust_analyzer`:
        -- ['rust_analyzer'] = function()
        --   require('rust-tools').setup {}
        -- end,
      }

      for _, lsp in ipairs(servers) do
        require('lspconfig')[lsp].setup {
          on_attach = on_attach,
          capabilities = capabilities,
        }
      end

      require('lspconfig').lua_ls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = servers.lua_ls.settings.Lua,
        },
      }

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'sh',
        callback = function()
          vim.lsp.start {
            name = 'bash-language-server',
            cmd = { 'bash-language-server', 'start' },
          }
        end,
      })

      -- ── Setup linting ───────────────────────────────────────────────────
      require('mason-nvim-lint').setup {
        ensure_installed = mason_servers or {},
        quiet_mode = true,
      }
      local lint = require 'lint'
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
