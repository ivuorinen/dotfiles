" Vim-only extras. The keymap scheme follows nvim
" (config/nvim/lua/keymaps.lua) and lives in the vimrc Neovim parity block.
" A key stays here only if nvim leaves it free: nothing in this file may
" take a <leader> group nvim uses (b, c, p, q, s, t, x) or override a
" built-in key nvim keeps (<Tab>/<C-i>, T, n/N, cmdline <C-p>, visual
" <C-v>/J/K).
"
" Map commands take no trailing comments: text after the {rhs}, including
" `" comment`, becomes part of the mapping. Comments go on their own line.

" Split: horizontal, vertical
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>

" Git (fugitive / rhubarb). Every key is a single letter after g: the
" which-key guide cannot reach a command that is also a prefix, which the
" old gs/gsh (status/push) pair was. Labels: g:which_key_map in the vimrc.
noremap <Leader>ga :Gwrite<CR>
noremap <Leader>gc :Git commit --verbose<CR>
noremap <Leader>gp :Git push<CR>
noremap <Leader>gl :Git pull<CR>
noremap <Leader>gs :Git<CR>
noremap <Leader>gb :Git blame<CR>
noremap <Leader>gd :Gvdiffsplit<CR>
noremap <Leader>gr :GRemove<CR>
" open current line on GitHub
nnoremap <Leader>o :.GBrowse<CR>

" set working directory to the current file
nnoremap <leader>. :lcd %:p:h<CR>

" Opens a tab edit command with the path of the currently
" edited file filled
noremap <Leader>r :tabe <C-R>=expand("%:p:h") . "/" <CR>

" fzf.vim
let $FZF_DEFAULT_COMMAND = "find * -path '*/\.*' -prune -o -path 'node_modules/**' -prune -o -path 'target/**' -prune -o -path 'vendor/**' -prune -o -path 'dist/**' -prune -o  -type f -print -o -type l -print 2> /dev/null"
" Recovery commands from history through FZF
nnoremap <leader>y :History:<CR>

" Tagbar
nnoremap <silent> <F4> :TagbarToggle<CR>
let g:tagbar_autofocus = 1

" Disable visualbell
set noerrorbells visualbell t_vb=
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

"" Copy/Paste/Cut through the system clipboard: plain y/p/d reach it.
"" macOS vim has +clipboard but no 'unnamedplus' (that register is X11),
"" so it needs the plain 'unnamed' branch.
if has('unnamedplus')
  set clipboard=unnamed,unnamedplus
elseif has('clipboard')
  set clipboard=unnamed
endif
