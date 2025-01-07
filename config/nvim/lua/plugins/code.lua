return {
  -- A better annotation generator.
  -- Supports multiple languages and annotation conventions.
  -- https://github.com/danymat/neogen
  {
    'danymat/neogen',
    version = '*',
    opts = { enabled = true, snippet_engine = 'luasnip' },
  },

  -- Terminal manager for (neo)vim
  -- https://github.com/voldikss/vim-floaterm
  {
    'voldikss/vim-floaterm',
    cmd = { 'FloatermToggle' },
    init = function()
      vim.g.floaterm_width = 0.8
      vim.g.floaterm_height = 0.8
    end,
  },

  -- Run your tests at the speed of thought
  -- https://github.com/vim-test/vim-test
  {
    'vim-test/vim-test',
    dependencies = { 'voldikss/vim-floaterm' },
    config = function()
      vim.cmd [[
      function! PhpUnitTransform(cmd) abort
        return join(map(split(a:cmd), 'v:val == "--colors" ? "--colors=always" : v:val'))
      endfunction

      let g:test#custom_transformations = {'phpunit': function('PhpUnitTransform')}
      let g:test#transformation = 'phpunit'

      " let test#php#phpunit#options = '--colors=always'
      let test#php#pest#options = '-v'
      let test#javascript#jest#options = '--color'

      function! FloatermStrategy(cmd)
        execute 'silent FloatermSend q'
        execute 'silent FloatermKill'
        execute 'FloatermNew! '.a:cmd.' | less -X'
      endfunction

      let g:test#custom_strategies = {'floaterm': function('FloatermStrategy')}
      let g:test#strategy = 'floaterm'
    ]]
    end,
  },

  -- Cloak allows you to overlay *'s over defined patterns in defined files.
  -- https://github.com/laytan/cloak.nvim
  {
    'laytan/cloak.nvim',
    version = '*',
    opts = {
      enabled = true,
      cloak_character = '*',
      -- The applied highlight group (colors) on the cloaking, see `:h highlight`.
      highlight_group = 'Comment',
      patterns = {
        {
          -- Match any file starting with ".env".
          -- This can be a table to match multiple file patterns.
          file_pattern = {
            '.env*',
            'wrangler.toml',
            '.dev.vars',
          },
          -- Match an equals sign and any character after it.
          -- This can also be a table of patterns to cloak,
          -- example: cloak_pattern = { ":.+", "-.+" } for yaml files.
          cloak_pattern = '=.+',
        },
      },
    },
  },

  -- projectionist.vim: Granular project configuration
  -- https://github.com/tpope/vim-projectionist
  {
    'tpope/vim-projectionist',
    dependencies = 'tpope/vim-dispatch',
    config = function()
      vim.g.projectionist_heuristics = {
        artisan = {
          ['*'] = {
            start = 'php artisan serve',
            console = 'php artisan tinker',
          },
          ['app/*.php'] = {
            type = 'source',
            alternate = {
              'tests/Unit/{}Test.php',
              'tests/Feature/{}Test.php',
            },
          },
          ['tests/Feature/*Test.php'] = {
            type = 'test',
            alternate = 'app/{}.php',
          },
          ['tests/Unit/*Test.php'] = {
            type = 'test',
            alternate = 'app/{}.php',
          },
          ['app/Models/*.php'] = {
            type = 'model',
          },
          ['app/Http/Controllers/*.php'] = {
            type = 'controller',
          },
          ['routes/*.php'] = {
            type = 'route',
          },
          ['database/migrations/*.php'] = {
            type = 'migration',
          },
        },
        ['src/&composer.json'] = {
          ['src/*.php'] = {
            type = 'source',
            alternate = {
              'tests/{}Test.php',
            },
          },
          ['tests/*Test.php'] = {
            type = 'test',
            alternate = 'src/{}.php',
          },
        },
        ['app/&composer.json'] = {
          ['app/*.php'] = {
            type = 'source',
            alternate = {
              'tests/{}Test.php',
            },
          },
          ['tests/*Test.php'] = {
            type = 'test',
            alternate = 'app/{}.php',
          },
        },
      }
    end,
  },

  -- A vim text object for XML/HTML attributes.
  -- https://github.com/whatyouhide/vim-textobj-xmlattr
  {
    'whatyouhide/vim-textobj-xmlattr',
    dependencies = { 'kana/vim-textobj-user' },
    opts = {},
  },

  -- Describe the regexp under the cursor
  -- https://github.com/bennypowers/nvim-regexplainer
  {
    'bennypowers/nvim-regexplainer',
    event = 'BufEnter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'MunifTanjim/nui.nvim',
    },
    opts = {
      -- automatically show the explainer when the cursor enters a regexp
      auto = true,
    },
  },

  -- Clarify and beautify your comments using boxes and lines.
  -- https://github.com/LudoPinelli/comment-box.nvim
  {
    'LudoPinelli/comment-box.nvim',
    event = 'BufEnter',
    opts = {},
  },

  -- Plugin to improve viewing Markdown files in Neovim
  -- https://github.com/MeanderingProgrammer/render-markdown.nvim
  {
    'MeanderingProgrammer/render-markdown.nvim',
    event = 'BufEnter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    ft = 'markdown',
    opts = {},
  },

  {
    'ray-x/go.nvim',
    dependencies = { -- optional packages
      'ray-x/guihua.lua',
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function() require('go').setup() end,
    event = { 'CmdlineEnter' },
    ft = { 'go', 'gomod' },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  },

  -- Mainly a PHP Language Server with more features than you can shake a stick at
  -- https://github.com/phpactor/phpactor
  {
    'phpactor/phpactor',
    build = 'composer install --no-dev --optimize-autoloader',
    ft = 'php',
  },
}
