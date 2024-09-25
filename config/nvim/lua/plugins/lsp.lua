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
      {
        'folke/neoconf.nvim',
        lazy = false,
        keys = {
          { '<leader>?c', '<cmd>Neoconf<CR>', desc = 'Neoconf: Open' },
          { '<leader>?g', '<cmd>Neoconf global<CR>', desc = 'Neoconf: Global' },
          { '<leader>?l', '<cmd>Neoconf local<CR>', desc = 'Neoconf: Local' },
          { '<leader>?m', '<cmd>Neoconf lsp<CR>', desc = 'Neoconf: Show merged LSP config' },
          { '<leader>?s', '<cmd>Neoconf show<CR>', desc = 'Neoconf: Show merged config' },
        },
        config = function()
          require('neoconf').setup()
        end,
      },
      -- Automatically install LSPs to stdpath for neovim
      {
        'williamboman/mason.nvim',
        lazy = false,
        run = ':call MasonUpdate',
      },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'b0o/schemastore.nvim',
      -- vscode-like pictograms for neovim lsp completion items
      -- https://github.com/onsails/lspkind-nvim
      { 'onsails/lspkind.nvim' },
    },
    keys = {
      { '<leader>do', '<cmd>lua vim.diagnostic.open_float()<CR>', desc = 'Diagnostic: Open float' },
      { '<leader>dq', '<cmd>lua vim.diagnostic.setloclist()<CR>', desc = 'Diagnostic: Set loc list' },
      { 'dn', '<cmd>lua vim.diagnostic.goto_next()<CR>', desc = 'Diagnostic: Goto Next' },
      { 'dp', '<cmd>lua vim.diagnostic.goto_prev()<CR>', desc = 'Diagnostic: Goto Prev' },
      { '<leader>cr', '<cmd>lua vim.lsp.buf.rename()<CR>', desc = 'LSP: Rename' },
      { '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', desc = 'LSP: Code Action' },
      { 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', desc = 'LSP: Goto Definition' },
      { 'gr', '<cmd>lua require("telescope.builtin").lsp_references()<CR>', desc = 'LSP: Goto References' },
      { 'gI', '<cmd>lua vim.lsp.buf.implementation()<CR>', desc = 'LSP: Goto Implementation' },
      { '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', desc = 'LSP: Type Definition' },
      { '<leader>ds', '<cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>', desc = 'LSP: Document Symbols' },
      { '<leader>ws', '<cmd>lua require("telescope.builtin").lsp_dynamic_workspace_symbols()<CR>', desc = 'LSP: Workspace Symbols' },
      { 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', desc = 'LSP: Hover Documentation' },
      { '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', desc = 'LSP: Signature Documentation' },
      { 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', desc = 'LSP: Goto Declaration' },
      { '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', desc = 'LSP: Workspace Add Folder' },
      { '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', desc = 'LSP: Workspace Remove Folder' },
      { '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', desc = 'LSP: Workspace List Folders' },
    },
    config = function()
      -- LSP settings.
      --  This function gets run when an LSP connects to a particular buffer.
      local on_attach = function(_, bufnr)
        -- Create a command `:Format` local to the LSP buffer
        vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
          if vim.lsp.buf.format then
            vim.lsp.buf.format()
          elseif vim.lsp.buf.formatting then
            vim.lsp.buf.formatting()
          end
        end, { desc = 'Format current buffer with LSP' })
      end

      -- Setup mason so it can manage external tooling
      require('mason').setup()

      -- Enable the following language servers
      -- Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      local servers = {
        -- :help lspconfig-all for all pre-configured LSPs
        ast_grep = {},

        actionlint = {}, -- GitHub Actions
        ansiblels = {}, -- Ansible
        bashls = {}, -- Bash
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
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              diagnostics = { disable = { 'missing-fields' } },
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
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'actionlint',
        'ansible-language-server',
        'ansible-lint',
        'bash-language-server',
        'blade-formatter',
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
        'yamllint',
      })
      require('mason-tool-installer').setup {
        ensure_installed = ensure_installed,
        auto_update = true,
      }

      -- Ensure the servers above are installed
      require('mason-lspconfig').setup {
        automatic_installation = true,
        ensure_installed = servers,
      }

      -- nvim-cmp supports additional completion capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      for _, lsp in ipairs(servers) do
        require('lspconfig')[lsp].setup {
          on_attach = on_attach,
          capabilities = capabilities,
        }
      end

      -- Turn on lsp status information
      -- require('fidget').setup()

      -- Example custom configuration for lua
      --
      -- Make runtime files discoverable to the server
      local runtime_path = vim.split(package.path, ';')
      table.insert(runtime_path, 'lua/?.lua')
      table.insert(runtime_path, 'lua/?/init.lua')

      require('lspconfig').lua_ls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
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
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file('', true),
              checkThirdParty = false,
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = { enable = false },
          },
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
    end,
  },
}
