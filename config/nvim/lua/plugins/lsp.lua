-- Quickstart configs for Nvim LSP
-- https://github.com/neovim/nvim-lspconfig
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    -- Useful status updates for LSP
    {
      'j-hui/fidget.nvim',
      opts = {
        notification = {
          window = {
            winblend = 50,
            align = 'top',
          },
        },
      },
    },
    'b0o/schemastore.nvim',
    {
      -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
      -- used for completion, annotations and signatures of Neovim apis
      'folke/lazydev.nvim',
      ft = 'lua',
      opts = {
        library = {
          -- Load luvit types when the `vim.uv` word is found
          { path = 'luvit-meta/library', words = { 'vim%.uv' } },
        },
      },
    },
  },
  config = function()
    -- Diagnostic keymaps
    vim.keymap.set('n', 'dp', vim.diagnostic.goto_prev, { desc = 'Diagnostic: Goto Prev' })
    vim.keymap.set('n', 'dn', vim.diagnostic.goto_next, { desc = 'Diagnostic: Goto Next' })
    vim.keymap.set('n', '<leader>do', vim.diagnostic.open_float, { desc = 'Diagnostic: Open float' })
    vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Diagnostic: Set loc list' })

    -- LSP settings.
    --  This function gets run when an LSP connects to a particular buffer.
    local on_attach = function(_, bufnr)
      local nmap = function(keys, func, desc)
        if desc then
          desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
      end

      nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
      nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
      nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
      nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
      nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
      nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
      nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
      nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

      -- See `:help K` for why this keymap
      nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
      nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

      -- Lesser used LSP functionality
      nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
      nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
      nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
      nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, '[W]orkspace [L]ist Folders')

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
      grammarly = {}, -- Grammar and better writing
      html = {}, -- HTML
      intelephense = {}, -- PHP
      jinja_lsp = {}, -- Jinja templates
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
        -- cmd = {...},
        -- filetypes = { ...},
        -- capabilities = {},
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
      'codespell',
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
    require('fidget').setup()

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
}
