-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/ivuorinen/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/ivuorinen/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/ivuorinen/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/ivuorinen/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/ivuorinen/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["Comment.nvim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/Comment.nvim",
    url = "https://github.com/numToStr/Comment.nvim"
  },
  LuaSnip = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/LuaSnip",
    url = "https://github.com/L3MON4D3/LuaSnip"
  },
  ["barbar.nvim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/barbar.nvim",
    url = "https://github.com/romgrk/barbar.nvim",
    wants = { "nvim-web-devicons" }
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  cmp_luasnip = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/cmp_luasnip",
    url = "https://github.com/saadparwaiz1/cmp_luasnip"
  },
  ["dressing.nvim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/dressing.nvim",
    url = "https://github.com/stevearc/dressing.nvim"
  },
  ["editorconfig.nvim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/editorconfig.nvim",
    url = "https://github.com/gpanders/editorconfig.nvim"
  },
  ["fidget.nvim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/fidget.nvim",
    url = "https://github.com/j-hui/fidget.nvim"
  },
  ["gitsigns.nvim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  ["indent-blankline.nvim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/indent-blankline.nvim",
    url = "https://github.com/lukas-reineke/indent-blankline.nvim"
  },
  ["lualine.nvim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["markdown-preview.nvim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/markdown-preview.nvim",
    url = "https://github.com/iamcco/markdown-preview.nvim"
  },
  ["mason-lspconfig.nvim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/mason-lspconfig.nvim",
    url = "https://github.com/williamboman/mason-lspconfig.nvim"
  },
  ["mason.nvim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/mason.nvim",
    url = "https://github.com/williamboman/mason.nvim"
  },
  ["mkdir.nvim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/mkdir.nvim",
    url = "https://github.com/jghauser/mkdir.nvim"
  },
  neodim = {
    config = { "\27LJ\2\n¸\1\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\thide\1\0\3\14underline\2\nsigns\2\17virtual_text\2\21update_in_insert\1\0\2\ndelay\3d\venable\2\1\0\2\nalpha\4\0€€ ÿ\3\16blend_color\f#000000\nsetup\vneodim\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/opt/neodim",
    url = "https://github.com/zbirenbaum/neodim"
  },
  ["notifier.nvim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/notifier.nvim",
    url = "https://github.com/vigoux/notifier.nvim"
  },
  ["null-ls.nvim"] = {
    config = { "\27LJ\2\nŸ\b\0\0\6\0*\0¡\0016\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3(\0004\4'\0009\5\3\0009\5\4\0059\5\5\5>\5\1\0049\5\3\0009\5\4\0059\5\6\5>\5\2\0049\5\3\0009\5\4\0059\5\a\5>\5\3\0049\5\3\0009\5\4\0059\5\b\5>\5\4\0049\5\3\0009\5\4\0059\5\t\5>\5\5\0049\5\3\0009\5\4\0059\5\n\5>\5\6\0049\5\3\0009\5\4\0059\5\v\5>\5\a\0049\5\3\0009\5\4\0059\5\f\5>\5\b\0049\5\3\0009\5\4\0059\5\r\5>\5\t\0049\5\3\0009\5\4\0059\5\14\5>\5\n\0049\5\3\0009\5\4\0059\5\15\5>\5\v\0049\5\3\0009\5\16\0059\5\17\5>\5\f\0049\5\3\0009\5\16\0059\5\18\5>\5\r\0049\5\3\0009\5\16\0059\5\19\5>\5\14\0049\5\3\0009\5\16\0059\5\20\5>\5\15\0049\5\3\0009\5\16\0059\5\21\5>\5\16\0049\5\3\0009\5\16\0059\5\22\5>\5\17\0049\5\3\0009\5\16\0059\5\6\5>\5\18\0049\5\3\0009\5\16\0059\5\23\5>\5\19\0049\5\3\0009\5\16\0059\5\24\5>\5\20\0049\5\3\0009\5\16\0059\5\25\5>\5\21\0049\5\3\0009\5\16\0059\5\t\5>\5\22\0049\5\3\0009\5\16\0059\5\26\5>\5\23\0049\5\3\0009\5\16\0059\5\27\5>\5\24\0049\5\3\0009\5\16\0059\5\28\5>\5\25\0049\5\3\0009\5\16\0059\5\29\5>\5\26\0049\5\3\0009\5\16\0059\5\30\5>\5\27\0049\5\3\0009\5\16\0059\5\31\5>\5\28\0049\5\3\0009\5\16\0059\5\f\5>\5\29\0049\5\3\0009\5\16\0059\5 \5>\5\30\0049\5\3\0009\5\16\0059\5!\5>\5\31\0049\5\3\0009\5\16\0059\5\"\5>\5 \0049\5\3\0009\5\16\0059\5#\5>\5!\0049\5\3\0009\5$\0059\5%\5>\5\"\0049\5\3\0009\5$\0059\5&\5>\5#\0049\5\3\0009\5'\0059\5\6\5>\5$\0049\5\3\0009\5'\0059\5\30\5>\5%\0049\5\3\0009\5'\0059\5\"\5>\5&\4=\4)\3B\1\2\1K\0\1\0\fsources\1\0\0\17code_actions\fluasnip\nspell\15completion\ryamllint\axo\16trail_space\18todo_comments\rspectral\15shellcheck\npsalm\fphpstan\nphpcs\bphp\rluacheck\rjsonlint\rhadolint\25editorconfig_checker\18dotenv_linter\14codespell\15actionlint\16ansiblelint\talex\16diagnostics\fyamlfmt\20trim_whitespace\18terraform_fmt\14stylelint\nshfmt\rprettier\17markdownlint\15lua_format\ffixjson\veslint\20blade_formatter\15formatting\rbuiltins\nsetup\fnull-ls\frequire\0" },
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/null-ls.nvim",
    url = "https://github.com/jose-elias-alvarez/null-ls.nvim"
  },
  ["nvim-cmp"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-lint"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/nvim-lint",
    url = "https://github.com/mfussenegger/nvim-lint"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-notify"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/nvim-notify",
    url = "https://github.com/rcarriga/nvim-notify"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-treesitter-textobjects"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/opt/nvim-treesitter-textobjects",
    url = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/nvim-tree/nvim-web-devicons"
  },
  ["obsidian.nvim"] = {
    config = { "\27LJ\2\n¯\1\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\15completion\1\0\1\rnvim_cmp\2\16daily_notes\1\0\1\vfolder\v_daily\1\0\2\bdir\26~/.local/share/_nvalt\17notes_subdir\nnotes\nsetup\robsidian\frequire\0" },
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/obsidian.nvim",
    url = "https://github.com/epwalsh/obsidian.nvim"
  },
  orgmode = {
    config = { "\27LJ\2\n9\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\forgmode\frequire\0" },
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/orgmode",
    url = "https://github.com/nvim-orgmode/orgmode"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["palenight.vim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/palenight.vim",
    url = "https://github.com/drewtempelmeyer/palenight.vim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["refactoring.nvim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/refactoring.nvim",
    url = "https://github.com/ThePrimeagen/refactoring.nvim"
  },
  tabular = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/tabular",
    url = "https://github.com/godlygeek/tabular"
  },
  ["telescope-fzf-native.nvim"] = {
    cond = { true },
    loaded = false,
    needs_bufread = false,
    only_cond = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/opt/telescope-fzf-native.nvim",
    url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["todo-comments.nvim"] = {
    config = { "\27LJ\2\n?\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\18todo-comments\frequire\0" },
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/todo-comments.nvim",
    url = "https://github.com/folke/todo-comments.nvim"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/vim-fugitive",
    url = "https://github.com/tpope/vim-fugitive"
  },
  ["vim-markdown"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/vim-markdown",
    url = "https://github.com/preservim/vim-markdown"
  },
  ["vim-rhubarb"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/vim-rhubarb",
    url = "https://github.com/tpope/vim-rhubarb"
  },
  ["vim-sleuth"] = {
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/vim-sleuth",
    url = "https://github.com/tpope/vim-sleuth"
  },
  ["which-key.nvim"] = {
    config = { "\27LJ\2\n;\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\14which-key\frequire\0" },
    loaded = true,
    path = "/Users/ivuorinen/.local/share/nvim/site/pack/packer/start/which-key.nvim",
    url = "https://github.com/folke/which-key.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: null-ls.nvim
time([[Config for null-ls.nvim]], true)
try_loadstring("\27LJ\2\nŸ\b\0\0\6\0*\0¡\0016\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3(\0004\4'\0009\5\3\0009\5\4\0059\5\5\5>\5\1\0049\5\3\0009\5\4\0059\5\6\5>\5\2\0049\5\3\0009\5\4\0059\5\a\5>\5\3\0049\5\3\0009\5\4\0059\5\b\5>\5\4\0049\5\3\0009\5\4\0059\5\t\5>\5\5\0049\5\3\0009\5\4\0059\5\n\5>\5\6\0049\5\3\0009\5\4\0059\5\v\5>\5\a\0049\5\3\0009\5\4\0059\5\f\5>\5\b\0049\5\3\0009\5\4\0059\5\r\5>\5\t\0049\5\3\0009\5\4\0059\5\14\5>\5\n\0049\5\3\0009\5\4\0059\5\15\5>\5\v\0049\5\3\0009\5\16\0059\5\17\5>\5\f\0049\5\3\0009\5\16\0059\5\18\5>\5\r\0049\5\3\0009\5\16\0059\5\19\5>\5\14\0049\5\3\0009\5\16\0059\5\20\5>\5\15\0049\5\3\0009\5\16\0059\5\21\5>\5\16\0049\5\3\0009\5\16\0059\5\22\5>\5\17\0049\5\3\0009\5\16\0059\5\6\5>\5\18\0049\5\3\0009\5\16\0059\5\23\5>\5\19\0049\5\3\0009\5\16\0059\5\24\5>\5\20\0049\5\3\0009\5\16\0059\5\25\5>\5\21\0049\5\3\0009\5\16\0059\5\t\5>\5\22\0049\5\3\0009\5\16\0059\5\26\5>\5\23\0049\5\3\0009\5\16\0059\5\27\5>\5\24\0049\5\3\0009\5\16\0059\5\28\5>\5\25\0049\5\3\0009\5\16\0059\5\29\5>\5\26\0049\5\3\0009\5\16\0059\5\30\5>\5\27\0049\5\3\0009\5\16\0059\5\31\5>\5\28\0049\5\3\0009\5\16\0059\5\f\5>\5\29\0049\5\3\0009\5\16\0059\5 \5>\5\30\0049\5\3\0009\5\16\0059\5!\5>\5\31\0049\5\3\0009\5\16\0059\5\"\5>\5 \0049\5\3\0009\5\16\0059\5#\5>\5!\0049\5\3\0009\5$\0059\5%\5>\5\"\0049\5\3\0009\5$\0059\5&\5>\5#\0049\5\3\0009\5'\0059\5\6\5>\5$\0049\5\3\0009\5'\0059\5\30\5>\5%\0049\5\3\0009\5'\0059\5\"\5>\5&\4=\4)\3B\1\2\1K\0\1\0\fsources\1\0\0\17code_actions\fluasnip\nspell\15completion\ryamllint\axo\16trail_space\18todo_comments\rspectral\15shellcheck\npsalm\fphpstan\nphpcs\bphp\rluacheck\rjsonlint\rhadolint\25editorconfig_checker\18dotenv_linter\14codespell\15actionlint\16ansiblelint\talex\16diagnostics\fyamlfmt\20trim_whitespace\18terraform_fmt\14stylelint\nshfmt\rprettier\17markdownlint\15lua_format\ffixjson\veslint\20blade_formatter\15formatting\rbuiltins\nsetup\fnull-ls\frequire\0", "config", "null-ls.nvim")
time([[Config for null-ls.nvim]], false)
-- Config for: obsidian.nvim
time([[Config for obsidian.nvim]], true)
try_loadstring("\27LJ\2\n¯\1\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\15completion\1\0\1\rnvim_cmp\2\16daily_notes\1\0\1\vfolder\v_daily\1\0\2\bdir\26~/.local/share/_nvalt\17notes_subdir\nnotes\nsetup\robsidian\frequire\0", "config", "obsidian.nvim")
time([[Config for obsidian.nvim]], false)
-- Config for: todo-comments.nvim
time([[Config for todo-comments.nvim]], true)
try_loadstring("\27LJ\2\n?\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\18todo-comments\frequire\0", "config", "todo-comments.nvim")
time([[Config for todo-comments.nvim]], false)
-- Config for: orgmode
time([[Config for orgmode]], true)
try_loadstring("\27LJ\2\n9\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\forgmode\frequire\0", "config", "orgmode")
time([[Config for orgmode]], false)
-- Config for: which-key.nvim
time([[Config for which-key.nvim]], true)
try_loadstring("\27LJ\2\n;\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\14which-key\frequire\0", "config", "which-key.nvim")
time([[Config for which-key.nvim]], false)
-- Conditional loads
time([[Conditional loading of telescope-fzf-native.nvim]], true)
  require("packer.load")({"telescope-fzf-native.nvim"}, {}, _G.packer_plugins)
time([[Conditional loading of telescope-fzf-native.nvim]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd nvim-treesitter ]]
vim.cmd [[ packadd nvim-treesitter-textobjects ]]
time([[Sequenced loading]], false)
vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au LspAttach * ++once lua require("packer.load")({'neodim'}, { event = "LspAttach *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
