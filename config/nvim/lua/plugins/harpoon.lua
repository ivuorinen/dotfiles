-- Getting you where you want with the fewest keystrokes.
-- https://github.com/ThePrimeagen/harpoon
return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup {}

    -- basic telescope configuration
    local conf = require('telescope.config').values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = require('telescope.finders').new_table {
            results = file_paths,
          },
          previewer = conf.file_previewer {},
          sorter = conf.generic_sorter {},
        })
        :find()
    end

    vim.keymap.set(
      'n',
      '<leader>hw',
      function() toggle_telescope(harpoon:list()) end,
      { desc = 'Open harpoon window with telescope' }
    )
    vim.keymap.set(
      'n',
      '<leader>ht',
      function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
      { desc = 'Open Harpoon Quick menu' }
    )
  end,
}
