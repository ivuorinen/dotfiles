"*****************************************************************************
"" Abbreviations
"*****************************************************************************
"" no one is really happy until you have this shortcuts
cnoreabbrev W! w!       " force write
cnoreabbrev Q! q!       " force quit
cnoreabbrev Qall! qall! " force quit all
cnoreabbrev Wq wq       " write and quit
cnoreabbrev Wa wa       " write all
cnoreabbrev wQ wq       " write and quit
cnoreabbrev WQ wq       " write and quit
cnoreabbrev W w         " write
cnoreabbrev Q q         " quit
cnoreabbrev Qall qall   " quit all

"*****************************************************************************
"" Mappings
"*****************************************************************************

noremap <C-S> :w<CR>               " save buffer

" Split
noremap <Leader>h :<C-u>split<CR>  " horizontal split
noremap <Leader>v :<C-u>vsplit<CR> " vertical split

" Git
noremap <Leader>ga :Gwrite<CR>
noremap <Leader>gc :Git commit --verbose<CR>
noremap <Leader>gsh :Git push<CR>
noremap <Leader>gll :Git pull<CR>
noremap <Leader>gs :Git<CR>
noremap <Leader>gb :Git blame<CR>
noremap <Leader>gd :Gvdiffsplit<CR>
noremap <Leader>gr :GRemove<CR>

" session management
nnoremap <leader>so :OpenSession<Space>
nnoremap <leader>ss :SaveSession<Space>
nnoremap <leader>sd :DeleteSession<CR>
nnoremap <leader>sc :CloseSession<CR>

" Tabs
nnoremap <Tab> gt                   " next tab
nnoremap <S-Tab> gT                 " previous tab
nnoremap <silent> <S-t> :tabnew<CR> " new tab

nnoremap <leader>. :lcd %:p:h<CR>   " set working directory to the current file

" Opens an edit command with the path of the currently
" edited file filled in
noremap <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" Opens a tab edit command with the path of the currently
" edited file filled
noremap <Leader>r :tabe <C-R>=expand("%:p:h") . "/" <CR>

" fzf.vim
let $FZF_DEFAULT_COMMAND = "find * -path '*/\.*' -prune -o -path 'node_modules/**' -prune -o -path 'target/**' -prune -o -path 'vendor/**' -prune -o -path 'dist/**' -prune -o  -type f -print -o -type l -print 2> /dev/null"

cnoremap <C-P> <C-R>=expand("%:p:h") . "/" <CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>e :FZF -m<CR>
" Recovery commands from history through FZF
nmap <leader>y :History:<CR>

" Tagbar
nmap <silent> <F4> :TagbarToggle<CR> " open tagbar
let g:tagbar_autofocus = 1

" Disable visualbell
set noerrorbells visualbell t_vb=
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

"" Copy/Paste/Cut
if has('unnamedplus')
  set clipboard=unnamed,unnamedplus
endif

noremap YY "+y<CR>         " copy line
noremap <leader>p "+gP<CR> " paste
noremap XX "+x<CR>         " cut

if has('macunix')
  " pbcopy for OSX copy/paste
  vmap <C-x> :!pbcopy<CR>       " copy
  vmap <C-c> :w !pbcopy<CR><CR> " cut
  vmap <C-v> :!pbpaste<CR>      " paste
endif

"" Buffer nav
noremap <leader>z :bp<CR> " previous buffer
noremap <leader>x :bn<CR> " next buffer
noremap <leader>bq :bp<CR> " previous buffer
noremap <leader>bw :bn<CR> " next buffer
noremap <leader>bd :bd<CR> " close buffer


"" Switching windows
noremap <C-j> <C-w>j " move to window below
noremap <C-k> <C-w>k " move to window above
noremap <C-l> <C-w>l " move to window right
noremap <C-h> <C-w>h " move to window left

vmap < <gv                  " move visual block left, keep selection
vmap > >gv                  " move visual block right, keep selection
vnoremap J :m '>+1<CR>gv=gv " move visual block down, keep selection
vnoremap K :m '<-2<CR>gv=gv " move visual block up, keep selection

nnoremap <Leader>o :.GBrowse<CR>           " open current line on GitHub
nnoremap <silent> <leader>sh :terminal<CR> " open a new terminal
nnoremap <silent> <esc><esc> :noh<cr>      " clean search
