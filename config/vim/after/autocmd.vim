"" The PC is fast enough, do syntax highlight
"" syncing from start 6nless 200 lines
augroup vimrc-sync-fromstart
  autocmd!
  autocmd BufEnter * :syntax sync maxlines=600
augroup END

"" txt
augroup vimrc-wrapping
  autocmd!
  autocmd BufRead,BufNewFile *.txt call s:setupWrapping()
augroup END

"" make/cmake
augroup vimrc-make-cmake
  autocmd!
  autocmd FileType make setlocal noexpandtab
  autocmd BufNewFile,BufRead CMakeLists.txt setlocal filetype=cmake
augroup END

set autoread

""" Create/get autocommand group
function! s:CreateAugroup(name) abort
  execute 'augroup' a:name
  autocmd!
  augroup END
endfunction

" Highlight on yank
" See `:help vim.highlight.on_yank()`
call s:CreateAugroup('YankHighlight')
autocmd YankHighlight TextYankPost * silent! lua vim.highlight.on_yank()

" Set the numberwidth to the maximum line number.
" Fixes the issue where the line numbers jump
" around when moving between lines with relative line numbers enabled.
call s:CreateAugroup('AdjustNumberWidth')
autocmd AdjustNumberWidth BufEnter,BufWinEnter,TabEnter *
  \ let max_line_count = line('$') |
  \ if max_line_count > 99 |
  \   let &numberwidth = strlen(string(max_line_count)) + 1
  \ endif

" Windows to close with "q"
call s:CreateAugroup('close_with_q')
autocmd close_with_q FileType checkhealth,dbout,gitsigns.blame,grug-far,help,
  \ lspinfo,man,neotest-output,neotest-output-panel,neotest-summary,notify,
  \ qf,spectre_panel,startuptime,tsplayground
  \ setlocal buflisted=false |
  \ nnoremap <silent> <buffer> q :close<CR>

" Make it easier to close man-files when opened inline
call s:CreateAugroup('man_unlisted')
autocmd man_unlisted FileType man setlocal buflisted=false

" Wrap and check for spell in text filetypes
call s:CreateAugroup('wrap_spell')
autocmd wrap_spell FileType text,plaintex,typst,gitcommit,markdown,asciidoc,rst,tex
  \ setlocal wrap spell

" Fix conceallevel for json files
call s:CreateAugroup('json_conceal')
autocmd json_conceal FileType json,jsonc,json5 setlocal conceallevel=0
