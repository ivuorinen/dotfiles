return {
  -- Terminal manager for (neo)vim
  -- https://github.com/voldikss/vim-floaterm
  {
    'voldikss/vim-floaterm',
    lazy = true,
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
    ft = { 'html', 'xml', 'javascriptreact', 'typescriptreact', 'vue' },
  },

  -- Clarify and beautify your comments using boxes and lines.
  -- https://github.com/LudoPinelli/comment-box.nvim
  {
    'LudoPinelli/comment-box.nvim',
    event = 'BufEnter',
    opts = {},
  },
}
