-- ── Formatting ──────────────────────────────────────────────────────
-- Lightweight yet powerful formatter plugin for Neovim
-- https://github.com/stevearc/conform.nvim

return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    opts = {
      -- Enable or disable logging
      notify_on_error = false,
      -- Set the default formatter for all filetypes
      default_formatter = 'injected',
      -- Set the default formatter for all filetypes
      default_formatter_opts = {
        lsp_format = 'fallback',
        -- Set the default formatter for all filetypes
        formatter = 'injected',
        -- Set the default formatter for all filetypes
        -- formatter_opts = {},
      },
      -- The options you set here will be merged with the builtin formatters.
      -- You can also define any custom formatters here.
      formatters = {
        injected = { options = { ignore_errors = true } },
        -- # Example of using dprint only when a dprint.json file is present
        -- dprint = {
        --   condition = function(ctx)
        --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
        --
        -- # Example of using shfmt with extra args
        -- shfmt = {
        --   prepend_args = { "-i", "2", "-ci" },
        -- },
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform will run multiple formatters sequentially
        go = { 'goimports', 'gofmt' },
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
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
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
    },
    init = function()
      -- If you want the formatexpr, here is the place to set it
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
  -- Automatically install formatters registered with conform.nvim via mason.nvim
  -- https://github.com/zapling/mason-conform.nvim
  {
    'zapling/mason-conform.nvim',
    depends = {
      'stevearc/conform.nvim',
      'williamboman/mason.nvim',
    },
    opts = {},
  },
}
