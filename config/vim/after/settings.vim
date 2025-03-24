let mapleader=' '                 " Map leader to <space>
filetype off                      " disable filetype detection (but re-enable later, see below)

" find matching tags in html/xml documents using matchit
filetype plugin on
packadd! matchit
" disable super buggy netrw
let g:loaded_netrw=1
let g:netrw_loaded_netrwPlugin=1
" show JSDoc highlight colors
let g:javascript_plugin_jsdoc=1

set backspace=indent,eol,start    " Backspace behavior
set cindent                       " Use 'C' style program indenting
set cursorline                    " Highlight current line
set encoding=utf-8                " UTF-8
set expandtab                     " Use spaces instead of tabs
set fileformats=unix,dos,mac      " File formats
set foldmethod=indent             " Fold based on indent
set foldlevel=99                  " Open all folds
set guioptions=egmrti             " GUI options
set hidden                        " Enable hidden buffers
set ignorecase                    " Always case-insensitive
set incsearch                     " Searches for strings incrementally
set laststatus=2                  " Always show statusline (even with only single window)
set linespace=3                   " Set line spacing
set list                          " Show invisible characters
set listchars=tab:⌴\ ,trail:◼,nbsp:•,extends:…,precedes:… " Invisible characters
set modeline                      " Enable modelines
set modelines=3                   " Number of lines to check for modelines
set mouse=a                       " Enable mouse support
set mousemodel=popup              " Enable mouse support
set nobackup                      " Disable backup files
set nocompatible                  " disable compatibility mode with vi
set nowritebackup                 " Disable backup files
set number                        " Show line numbers
set relativenumber                " Show relative line numbers
set ruler                         " Show row and column ruler information
set scrolloff=8                   " Minimum number of lines to keep above and below the cursor
set shiftwidth=4                  " Number of auto-indent spaces
set shortmess+=A                  " Don't show autocommand messages
set shortmess+=F                  " Avoid showing the "file-info" message
set shortmess+=I                  " Don't show intro message
set shortmess+=O                  " Avoid showing the "file-read" message
set shortmess+=O                  " Don't show overlength messages
set shortmess+=T                  " Don't show title messages
set shortmess+=W                  " Don't show "written" messages
set shortmess+=a                  " Avoid showing the "ATTENTION" message
set shortmess+=c                  " Avoid showing the "ins-completion-menu" message
set shortmess+=c                  " Don't pass messages to |ins-completion-menu|
set shortmess+=o                  " Avoid showing the "overlength" message
set shortmess+=t                  " Avoid showing the "trailing whitespace" message
set showcmd                       " Show command in status line
set showmatch                     " Highlight matching brace
set signcolumn=yes                " Show sign column
set smartcase                     " Enable smart-case search
set smartindent                   " Enable smart-indent
set smarttab                      " Enable smart-tabs
set softtabstop=4                 " Number of spaces per Tab
set spelllang=fi,en               " Set the spell language
set spellsuggest=double           " Suggest the first word when spell checking
set t_Co=256                      " 256 colors
set termguicolors                 " Enable 24-bit RGB color in the terminal
set timeoutlen=500                " By default timeoutlen=1000 (ms)
set ttimeoutlen=0                 " By default ttimeoutlen=-1 (ms)
set undolevels=1000               " Number of undo levels
set visualbell                    " Use visual bell (no beeping)
set wildmenu                      " Enable wildmenu
set wildmode=longest,list:longest " Command-line completion mode
set wrap                          " Wrap lines
set wrapscan                      " Searches wrap around the end of the file

" Ignore these files in wildmenu
set wildignore+=*.o,*.obj,.git,*.rbc,*.pyc,__pycache__,vendor

colorscheme iceberg               " Set the color scheme
filetype plugin indent on         " enable filetype detection, plugins and indenting

" Set the shell
if exists('$SHELL')
  set shell=$SHELL
else
  set shell=/bin/sh
endif
