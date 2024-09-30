-- Quick start configs for Nvim LSP
-- https://github.com/neovim/nvim-lspconfig
return {
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    dependencies = {
      -- ── Mason and LSPConfig integration ─────────────────────────────────
      -- Automatically install LSPs to stdpath for neovim

      -- Portable package manager for Neovim that runs everywhere Neovim runs.
      -- Easily install and manage LSP servers, DAP servers, linters, and formatters.
      -- https://github.com/williamboman/mason.nvim
      {
        'williamboman/mason.nvim',
        cmd = 'Mason',
        run = ':MasonUpdate',
      },
      -- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim.
      -- https://github.com/williamboman/mason-lspconfig.nvim
      { 'williamboman/mason-lspconfig.nvim' },

      -- ── Formatting ──────────────────────────────────────────────────────
      -- Lightweight yet powerful formatter plugin for Neovim
      -- https://github.com/stevearc/conform.nvim
      {
        'stevearc/conform.nvim',
        event = { 'BufWritePre' },
        cmd = { 'ConformInfo' },
        config = function()
          -- Select first conform formatter that is available
          ---@param bufnr integer
          ---@param ... string
          ---@return string
          local function first(bufnr, ...)
            local conform = require 'conform'
            for i = 1, select('#', ...) do
              local formatter = select(i, ...)
              if conform.get_formatter_info(formatter, bufnr).available then
                return formatter
              end
            end
            return select(1, ...)
          end

          require('conform').setup {
            -- Enable or disable logging
            notify_on_error = true,
            -- Set the default formatter for all filetypes
            default_formatter = 'injected',
            -- Set the default formatter for all filetypes
            default_formatter_opts = {
              lsp_format = 'fallback',
              -- Set the default formatter for all filetypes
              -- formatter = 'injected',
              -- Set the default formatter for all filetypes
              -- formatter_opts = {},
            },
            formatters_by_ft = {
              markdown = function(bufnr)
                return { first(bufnr, 'prettierd', 'prettier'), 'injected' }
              end,
              javascript = function(bufnr)
                return { first(bufnr, 'prettier', 'eslint'), 'injected' }
              end,
              lua = { 'stylua' },
              -- Conform will run multiple formatters sequentially
              -- python = { 'isort', 'black', lsp_format = 'fallback' },
              -- You can customize some of the format options for the filetype (:help conform.format)
              -- rust = { 'rustfmt', lsp_format = 'fallback' },
            },
            format_on_save = function(bufnr)
              -- Disable autoformat on certain filetypes
              local ignore_filetypes = {
                'c',
                'cpp',
                'sql',
                'java',
              }
              if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
                return
              end
              -- Disable with a global or buffer-local variable
              if
                vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat
              then
                return
              end
              -- Disable autoformat for files in a certain path
              local bufname = vim.api.nvim_buf_get_name(bufnr)
              if bufname:match '/node_modules/' then return end
              if bufname:match '/vendor/' then return end
              if bufname:match '/dist/' then return end
              if bufname:match '/build/' then return end

              return { timeout_ms = 500, lsp_format = 'fallback' }
            end,
          }
        end,
        init = function()
          -- If you want the formatexpr, here is the place to set it
          vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
      },

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
        vim.api.nvim_create_user_command('Format', function(args)
          local range = nil
          if args.count ~= -1 then
            local end_line = vim.api.nvim_buf_get_lines(
              bufnr,
              args.line2 - 1,
              args.line2,
              true
            )[1]
            range = {
              start = { args.line1, 0 },
              ['end'] = { args.line2, end_line:len() },
            }
          end
          require('conform').format {
            async = true,
            lsp_format = 'fallback',
            range = range,
          }
        end, { range = true, desc = 'Format current buffer with LSP' })
      end

      -- ── Enable the following language servers ───────────────────────────
      -- :help lspconfig-all for all pre-configured LSPs
      local servers = {
        bashls = {}, -- Bash
        -- csharp_ls = {}, -- C#, requires dotnet executable
        gopls = {}, -- Go
        html = {}, -- HTML
        intelephense = {}, -- PHP
        tailwindcss = {}, -- Tailwind CSS
        ts_ls = {}, -- TypeScript
        volar = {}, -- Vue

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
        'bash-language-server',
        'clang-format',
        'codespell',
        'commitlint',
        'diagnostic-languageserver',
        'editorconfig-checker',
        'fixjson',
        'jsonlint',
        'lua-language-server',
        'luacheck',
        'phpcbf',
        'phpcs',
        'phpmd',
        'prettier',
        'shellcheck',
        'shfmt',
        'stylua',
        'vim-language-server',
        'vue-language-server',
        'yamllint',
      }
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, mason_servers)

      -- ── Setup mason so it can manage external tooling ───────────────────
      require('mason').setup {
        ensure_installed = ensure_installed,
        automatic_installation = true,
      }

      -- nvim-cmp supports additional completion capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
      -- Tell the server the capability of foldingRange,
      -- Neovim hasn't added foldingRange to default capabilities, users must add it manually
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = true,
        lineFoldingOnly = true,
      }

      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = {
          'documentation',
          'detail',
          'additionalTextEdits',
        },
      }

      local lspconfig_handlers = {
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.
        function(server_name) -- default handler (optional)
          require('lspconfig')[server_name].setup {
            on_attach = on_attach,
            capabilities = capabilities,
          }
        end,
        -- Next, you can provide targeted overrides for specific servers.
        ['lua_ls'] = function()
          require('lspconfig')['lua_ls'].setup { settings = servers.lua_ls }
        end,
        ['jsonls'] = function()
          require('lspconfig')['jsonls'].setup { settings = servers.jsonls }
        end,
      }

      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers or {}),
        automatic_installation = true,
        handlers = lspconfig_handlers,
      }
    end,
  },

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
  -- https://nvimdev.github.io/lspsaga/
  {
    'nvimdev/lspsaga.nvim',
    event = 'LspAttach',
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

  -- Not UFO in the sky, but an ultra fold in Neovim.
  -- https://github.com/kevinhwang91/nvim-ufo/
  {
    'kevinhwang91/nvim-ufo',
    version = '*',
    dependencies = {
      { 'neovim/nvim-lspconfig' },
      { 'kevinhwang91/promise-async' },
      { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' },
      {
        -- Status column plugin that provides a configurable
        -- 'statuscolumn' and click handlers.
        -- https://github.com/luukvbaal/statuscol.nvim
        'luukvbaal/statuscol.nvim',
        config = function()
          local builtin = require 'statuscol.builtin'
          require('statuscol').setup {
            relculright = true,
            segments = {
              {
                text = { builtin.foldfunc },
                click = 'v:lua.ScFa',
              },
              {
                sign = {
                  namespace = { 'diagnostic/signs' },
                  maxwidth = 2,
                  -- auto = true,
                },
                click = 'v:lua.ScSa',
              },
              {
                text = { builtin.lnumfunc, ' ' },
                click = 'v:lua.ScLa',
              },
            },
          }
        end,
      },
    },
    opts = {
      open_fold_hl_timeout = 150,
      close_fold_kinds_for_ft = { 'imports', 'comment' },
      preview = {
        win_config = {
          border = { '', '─', '', '', '', '─', '', '' },
          winhighlight = 'Normal:Folded',
          winblend = 0,
        },
        mappings = {
          scrollU = '<C-u>',
          scrollD = '<C-d>',
          jumpTop = '[',
          jumpBot = ']',
        },
      },

      provider_selector = function(_, _, _) -- bufnr, filetype, buftype
        return { 'treesitter', 'indent' }
      end,

      -- fold_virt_text_handler
      --
      -- This handler is called when the fold text is too long to fit in the window.
      -- It is expected to truncate the text and return a new list of virtual text.
      --
      ---@param virtText table The current virtual text list.
      ---@param lnum number The line number of the first line in the fold.
      ---@param endLnum number The line number of the last line in the fold.
      ---@param width number The width of the window.
      ---@param truncate function Truncate function
      ---@return table
      fold_virt_text_handler = function(
        virtText,
        lnum,
        endLnum,
        width,
        truncate
      )
        local newVirtText = {}
        local suffix = (' 󰁂 %d '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
      end,
    },
  },
}
