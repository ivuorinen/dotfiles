-- ╭─────────────────────────────────────────────────────────╮
-- │           Formatting (conform) and Linting              │
-- ╰─────────────────────────────────────────────────────────╯

-- Check if a config file exists relative to a buffer
local function has_file(patterns, bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr or 0)
  local dir = vim.fn.fnamemodify(bufname, ':h')
  return #vim.fs.find(patterns, {
    upward = true,
    path = dir,
    limit = 1,
  }) > 0
end

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
        ':ToggleFormat<CR>',
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
          if biome_fts[ft] and has_file({ 'biome.json', 'biome.jsonc' }, args.buf) then
            lint.try_lint 'biomejs'
          end

          lint.try_lint()
        end,
      })
    end,
  },
}
