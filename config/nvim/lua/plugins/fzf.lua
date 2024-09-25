return {
  -- fzf <3 vim
  -- https://github.com/junegunn/fzf.vim
  'junegunn/fzf.vim',
  dependencies = {
    { 'junegunn/fzf', run = ':call fzf#install()' },
  },
  keys = {
    -- Stolen from https://github.com/erikw/dotfiles/blob/d68d6274d67ac47afa20b9a0b9f3b0fa54bcdaf3/.config/nvim/lua/plugins.lua
    -- Search for files in given path.
    { '<Leader>zf', ':FZF<space>', desc = 'FZF: search for files in given path.' },
    -- Sublime-like shortcut 'go to file' ctrl+p.
    { '<C-p>', ':Files<CR>', desc = 'FZF: search for files starting at current directory.' },
    { '<Leader>zc', ':Commands<CR>', desc = 'FZF: search commands.' },
    { '<Leader>zt', ':Tags<CR>', desc = 'FZF: search in tags file' },
    { '<Leader>zb', ':Buffers<CR>', desc = 'FZF: search open buffers.' },
    -- Ref: https://medium.com/@paulodiovani/vim-buffers-windows-and-tabs-an-overview-8e2a57c57afa
    { '<Leader>zt', ':Windows<CR>', desc = 'FZF: search open tabs.' },
    { '<Leader>zh', ':History<CR>', desc = 'FZF: search history of opened files' },
    { '<Leader>zm', ':Maps<CR>', desc = 'FZF: search mappings.' },
    { '<Leader>zg', ':Rg<CR>', desc = 'FZF: search with rg (aka live grep).' },
  },
  config = function()
    -- To ignore a certain path in a git project from both RG and FD used by FZF,
    -- the eaiest way is to create ignore files and exclude the in local git clone.
    -- Ref: https://stackoverflow.com/a/1753078/265508
    -- $ cd git_proj/
    -- $ echo "path/to/exclude" > .rgignore
    -- $ echo "path/to/exclude" > .fdignore
    -- $ printf ".rgignore\n.fdignore" >> .git/info/exclude
  end,
}
