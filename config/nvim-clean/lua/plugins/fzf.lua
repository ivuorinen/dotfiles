return {
  "junegunn/fzf.vim",
  dependencies = {
    { "junegunn/fzf", run = ":call fzf#install()" },
  },
  config = function()
    -- Stolen from https://github.com/erikw/dotfiles/blob/d68d6274d67ac47afa20b9a0b9f3b0fa54bcdaf3/.config/nvim/lua/plugins.lua
    -- Comment must be on line of its own...
    -- Search for files in given path.
    vim.keymap.set("n", "<Leader>zf", ":FZF<space>", { silent = true, desc = "FZF: search for files in given path." })
    -- Sublime-like shortcut 'go to file' ctrl+p.
    vim.keymap.set(
      "n",
      "<C-p>",
      ":Files<CR>",
      { silent = true, desc = "FZF: search for files starting at current directory." }
    )
    vim.keymap.set("n", "<Leader>zc", ":Commands<CR>", { silent = true, desc = "FZF: search commands." })
    vim.keymap.set("n", "<Leader>zt", ":Tags<CR>", { silent = true, desc = "FZF: search in tags file" })
    vim.keymap.set("n", "<Leader>zb", ":Buffers<CR>", { silent = true, desc = "FZF: search open buffers." })
    -- Ref: https://medium.com/@paulodiovani/vim-buffers-windows-and-tabs-an-overview-8e2a57c57afa).
    vim.keymap.set("n", "<Leader>zt", ":Windows<CR>", { silent = true, desc = "FZF: search open tabs." })
    vim.keymap.set("n", "<Leader>zh", ":History<CR>", { silent = true, desc = "FZF: search history of opened files" })
    vim.keymap.set("n", "<Leader>zm", ":Maps<CR>", { silent = true, desc = "FZF: search mappings." })
    vim.keymap.set("n", "<Leader>zg", ":Rg<CR>", { silent = true, desc = "FZF: search with rg (aka live grep)." })

    -- To ignore a certain path in a git project from both RG and FD used by FZF,
    -- the eaiest way is to create ignore files and exclude the in local git clone.
    -- Ref: https://stackoverflow.com/a/1753078/265508
    -- $ cd git_proj/
    -- $ echo "path/to/exclude" > .rgignore
    -- $ echo "path/to/exclude" > .fdignore
    -- $ printf ".rgignore\n.fdignore" >> .git/info/exclude
  end,
}
