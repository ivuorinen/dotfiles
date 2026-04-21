-- ╭─────────────────────────────────────────────────────────╮
-- │           Formatting (conform) and Linting              │
-- ╰─────────────────────────────────────────────────────────╯
-- Project-gated tools use HasConfig()/Gated() from utils.lua.
-- Tools not gated here run unconditionally (opinion-free defaults).

return {
  -- Formatting
  {
    'stevearc/conform.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local conform = require 'conform'

      vim.g.autoformat_enabled = true

      conform.setup {
        formatters_by_ft = {
          ['yaml.ansible'] = { 'ansible-lint' },
          bash = { 'shfmt' },
          fish = { 'fish_indent' },
          go = { 'goimports', 'gofmt' },
          lua = { 'stylua' },
          python = { 'ruff_format' },
          sh = { 'shfmt' },
          terraform = { 'terraform_fmt' },
          toml = { 'taplo' },
          yaml = { 'prettier' },
        },
        -- Always-on formatters (standard/opinion-free): shfmt,
        -- fish_indent, gofmt, goimports, terraform_fmt.
        formatters = {
          ['ansible-lint'] = Gated 'ansible_lint',
          prettier = Gated 'prettier',
          ruff_format = Gated 'ruff',
          stylua = Gated 'stylua',
          taplo = Gated 'taplo',
        },
        default_format_opts = {
          lsp_format = 'fallback',
        },
        format_on_save = function(bufnr)
          if not vim.g.autoformat_enabled then return end

          local bufname = vim.api.nvim_buf_get_name(bufnr)
          if bufname:match '/node_modules/' then return end
          if bufname:match '/vendor/' then return end
          if bufname:match '/dist/' then return end

          return { timeout_ms = 500 }
        end,
        notify_on_error = true,
      }

      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

      vim.api.nvim_create_user_command('ToggleFormat', function()
        vim.g.autoformat_enabled = not vim.g.autoformat_enabled
        vim.notify('Autoformat: ' .. (vim.g.autoformat_enabled and 'on' or 'off'))
      end, {})

      vim.keymap.set(
        'n',
        '<leader>tf',
        '<cmd>ToggleFormat<CR>',
        { desc = 'Toggle autoformat on save' }
      )
    end,
  },

  -- Linting
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      lint.linters_by_ft = {
        bash = { 'shellcheck' },
        dockerfile = { 'hadolint' },
        fish = { 'fish' },
        go = { 'golangci_lint' },
        python = { 'ruff' },
        sh = { 'shellcheck' },
        terraform = { 'tflint' },
        yaml = { 'yamllint' },
        ['yaml.ansible'] = { 'ansible_lint' },
      }

      -- Linter name → TOOL_CONFIGS key. Linters absent from this map
      -- run unconditionally (shellcheck, fish).
      local LINTER_GATES = {
        ansible_lint = 'ansible_lint',
        golangci_lint = 'golangci_lint',
        hadolint = 'hadolint',
        ruff = 'ruff',
        tflint = 'tflint',
        yamllint = 'yamllint',
      }

      -- Filetypes where biome applies
      local biome_fts = {
        javascript = true,
        javascriptreact = true,
        typescript = true,
        typescriptreact = true,
        json = true,
        jsonc = true,
      }

      vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
        group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          if biome_fts[ft] and HasConfig('biome', args.buf) then
            lint.try_lint 'biomejs'
          end

          local names = {}
          for _, name in ipairs(lint.linters_by_ft[ft] or {}) do
            local gate = LINTER_GATES[name]
            if gate == nil or HasConfig(gate, args.buf) then table.insert(names, name) end
          end
          if #names > 0 then lint.try_lint(names) end
        end,
      })
    end,
  },
}
