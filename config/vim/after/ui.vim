" GUI settings
if has("gui_running")
  if has("gui_mac") || has("gui_macvim")
    set macligatures
    set guifont=JetBrains\ Mono:h14
    set transparency=7
  endif
else
  let g:CSApprox_loaded = 1

  " IndentLine
  let g:indentLine_enabled = 1
  let g:indentLine_concealcursor = ''
  let g:indentLine_char = '┆'
  let g:indentLine_faster = 1

  if $COLORTERM == 'gnome-terminal'
    set term=gnome-256color
  else
    if $TERM == 'xterm'
      set term=xterm-256color
    endif
  endif
endif

" if terminal supports 256 colors, disable t_ut
if &term =~ '256color'
  set t_ut=
endif

" set the title of the terminal to the file name
set title
set titleold="Terminal"
set titlestring=%F
