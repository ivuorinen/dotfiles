-- Not UFO in the sky, but an ultra fold in Neovim.
-- https://github.com/kevinhwang91/nvim-ufo/
return {
  {
    'kevinhwang91/nvim-ufo',
    version = '*',
    dependencies = {
      { 'kevinhwang91/promise-async' },
      { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' },
      {
        -- Status column plugin that provides a configurable
        -- 'statuscolumn' and click handlers.
        -- https://github.com/luukvbaal/statuscol.nvim
        'luukvbaal/statuscol.nvim',
        opts = {},
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
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
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
