-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim
return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    {
      -- This plugins prompts the user to pick a window and returns
      -- the window id of the picked window
      -- https://github.com/s1n7ax/nvim-window-picker
      's1n7ax/nvim-window-picker',
      version = '2.*',
      opts = {
        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          -- filter using buffer options
          bo = {
            -- if the file type is one of following, the window will be ignored
            filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
            -- if the buffer type is one of following, the window will be ignored
            buftype = { 'terminal', 'quickfix' },
          },
        },
      },
    },
  },
  cmd = 'Neotree',
  opts = {
    close_if_last_window = true,
    popup_border_style = 'rounded',
    enable_git_status = true,
    enable_diagnostics = true,
    git_status = {
      symbols = {
        -- Change type
        added = '',
        modified = '',
        deleted = '✖',
        renamed = '󰁕',
        -- Status type
        untracked = '',
        ignored = '',
        unstaged = '󰄱',
        staged = '',
        conflict = '',
      },
    },
    filesystem = {
      window = {
        mappings = {
          ['<Esc>'] = 'close_window',
          ['q'] = 'close_window',
        },
      },
      filtered_items = {
        hide_dotfiles = true,
        hide_gitignored = true,
        hide_hidden = true, -- only works on Windows for hidden files/directories
        never_show = {
          '.DS_Store',
        },
        hide_by_name = {
          'node_modules',
        },
        always_show = {
          '.actrc',
          '.browserslistrc',
          '.commitlintrc.json',
          '.editorconfig',
          '.env',
          '.env.example',
          '.envrc',
          '.eslintrc.json',
          '.github',
          '.gitignore',
          '.gitkeep',
          '.ignore',
          '.markdownlint.json',
          '.markdownlint.yaml',
          '.markdownlintignore',
          '.nvmrc',
          '.prettierignore',
          '.prettierrc.js',
          '.prettierrc.json',
          '.prettierrc.yaml',
          '.python-version',
          '.releaserc.json',
          '.shellcheckrc',
          '.simple-git-hooks.json',
          '.stylelintrc.json',
          '.stylua.toml',
          '.yamlignore',
          '.yamllint.yaml',
        },
        always_show_by_pattern = {
          '.*.json',
          '.*.toml',
          '.*.yaml',
          '.*.yml',
          '.*rc',
          '.*rc.*',
          '.env*',
          '.prettierrc*',
          '.markdownlint*',
          '.stylua.*',
        },
      },
    },
  },
}
