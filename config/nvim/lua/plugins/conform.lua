-- ── Formatting ──────────────────────────────────────────────────────
-- Lightweight yet powerful formatter plugin for Neovim
-- https://github.com/stevearc/conform.nvim
return {
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


}
