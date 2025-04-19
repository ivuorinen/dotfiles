return {
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    config = function()
      local conform = require 'conform'

      conform.setup {
        formatters_by_ft = {
          lua = { 'stylua' },
        },
        format_on_save = function(bufnr)
          -- Disable autoformat for files in a certain paths
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          if bufname:match '/dist|node_modules|vendor/' then return end

          local disable_lsp = {
            c = true,
            cpp = true,
          }
          return {
            lsp_fallback = not disable_lsp[vim.bo[bufnr].filetype],
            timeout_ms = 500,
          }
        end,
        notify_on_error = true,
      }

      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

      -- Autoformat toggle keybinding
      local autoformat = true
      vim.g.autoformat_enabled = autoformat

      vim.api.nvim_create_user_command('ToggleFormat', function()
        autoformat = not autoformat
        vim.g.autoformat_enabled = autoformat
        vim.notify('Autoformat on save: ' .. (autoformat and 'enabled' or 'disabled'))
      end, {})

      vim.keymap.set(
        'n',
        '<leader>tf',
        ':ToggleFormat<CR>',
        { desc = 'Toggle autoformat on save' }
      )

      vim.api.nvim_create_autocmd('BufWritePre', {
        callback = function(args)
          if autoformat then
            conform.format {
              bufnr = args.buf,
              async = true,
              lsp_format = 'fallback',
            }
          end
        end,
      })

      -- Global statusline helper function
      function _G.autoformat_status()
        return vim.g.autoformat_enabled and '[ fmt:on]' or '[ fmt:off]'
      end
    end,
  },
}
