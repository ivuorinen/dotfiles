" Derived from kanagawa_wave.vim (menisadi/kanagawa.vim, MIT): each Wave colour
" replaced by its Lotus counterpart, paired slot-by-slot from upstream
" rebelot/kanagawa.nvim lua/kanagawa/themes.lua, foregrounds darkened to
" WCAG AA 4.5:1 on #f2ecbc, cterm numbers recomputed. Map: docs/plans/2026-09-30-kanagawa-theme-families.md.
" ============================================================================
" Kanagawa (Lotus AA) Colorscheme for Vim
" Inspired by https://github.com/rebelot/kanagawa.nvim (Wave variant)
" Author: menisadi
" ============================================================================
if exists("syntax_on")
  syntax reset
endif


" Ensure true color is enabled if possible
if has("termguicolors")
  set termguicolors
endif

set background=light
hi clear
let g:colors_name = "kanagawa_lotus"

hi Boolean gui=bold term=bold cterm=bold guifg=#a15600 guibg=NONE ctermfg=130 ctermbg=NONE
hi Added   gui=NONE term=NONE cterm=NONE guifg=#5b7040 guibg=NONE ctermfg=240 ctermbg=NONE
hi Changed gui=NONE term=NONE cterm=NONE guifg=#406d99 guibg=NONE ctermfg=60 ctermbg=NONE
hi Removed gui=NONE term=NONE cterm=NONE guifg=#c0374a guibg=NONE ctermfg=131 ctermbg=NONE
hi link Character String
hi ColorColumn gui=NONE term=NONE cterm=NONE guifg=NONE guibg=#e7dba0 ctermfg=NONE ctermbg=187
hi Comment gui=NONE term=italic cterm=NONE guifg=#88877e guibg=NONE ctermfg=102 ctermbg=NONE
hi Conceal gui=bold term=bold cterm=bold guifg=#766b90 guibg=NONE ctermfg=96 ctermbg=NONE
hi link Conditional Statement
hi Constant gui=NONE term=NONE cterm=NONE guifg=#a15600 guibg=NONE ctermfg=130 ctermbg=NONE
hi CurSearch gui=bold term=bold cterm=bold guifg=#545464 guibg=#b5cbd2 ctermfg=240 ctermbg=152
hi Cursor gui=NONE term=NONE cterm=NONE guifg=#f2ecbc guibg=#545464 ctermfg=229 ctermbg=240
hi link CursorColumn CursorLine
hi link CursorIM Cursor
hi CursorLine gui=NONE term=NONE cterm=NONE guifg=NONE guibg=#e4d794 ctermfg=NONE ctermbg=186
hi link CursorLineFold FoldColumn
hi CursorLineNr gui=bold term=bold cterm=bold guifg=#9a5b00 guibg=#e7dba0 ctermfg=94 ctermbg=187
hi link CursorLineSign SignColumn
hi link Debug Special
hi link Define PreProc
hi Delimiter gui=NONE term=NONE cterm=NONE guifg=#3e7082 guibg=NONE ctermfg=60 ctermbg=NONE
hi DiffAdd gui=NONE term=NONE cterm=NONE guifg=NONE guibg=#b7d0ae ctermfg=NONE ctermbg=151
hi DiffChange gui=NONE term=NONE cterm=NONE guifg=NONE guibg=#d7e3d8 ctermfg=NONE ctermbg=253
hi DiffDelete gui=NONE term=NONE cterm=NONE guifg=#c0374a guibg=#d9a594 ctermfg=131 ctermbg=180
hi DiffText gui=NONE term=NONE cterm=NONE guifg=NONE guibg=#f9d791 ctermfg=NONE ctermbg=222
hi Directory gui=NONE term=NONE cterm=NONE guifg=#4d699b guibg=NONE ctermfg=60 ctermbg=NONE
hi EndOfBuffer gui=NONE term=NONE cterm=NONE guifg=#f2ecbc guibg=NONE ctermfg=229 ctermbg=NONE
hi Error gui=NONE term=NONE cterm=NONE guifg=#d21616 guibg=NONE ctermfg=160 ctermbg=NONE
hi ErrorMsg gui=NONE term=NONE cterm=NONE guifg=#d21616 guibg=NONE ctermfg=160 ctermbg=NONE
hi Exception gui=NONE term=NONE cterm=NONE guifg=#c0374a guibg=NONE ctermfg=131 ctermbg=NONE
hi link Float Number
hi FoldColumn gui=NONE term=NONE cterm=NONE guifg=#766b90 guibg=#e7dba0 ctermfg=96 ctermbg=187
hi Folded gui=NONE term=NONE cterm=NONE guifg=#766b90 guibg=#e7dba0 ctermfg=96 ctermbg=187
hi Function gui=NONE term=NONE cterm=NONE guifg=#4d699b guibg=NONE ctermfg=60 ctermbg=NONE
hi Identifier gui=NONE term=NONE cterm=NONE guifg=#716b3c guibg=NONE ctermfg=59 ctermbg=NONE
hi link Ignore NonText
hi IncSearch gui=NONE term=NONE cterm=NONE guifg=#f2ecbc guibg=#9a5b00 ctermfg=229 ctermbg=94
hi link Include PreProc
hi Keyword gui=italic term=italic cterm=italic guifg=#624c83 guibg=NONE ctermfg=60 ctermbg=NONE
hi link Label Statement
hi LineNr gui=NONE term=NONE cterm=NONE guifg=#766b90 guibg=#e7dba0 ctermfg=96 ctermbg=187
hi link LineNrAbove LineNr
hi link LineNrBelow LineNr
hi link Macro PreProc
hi MatchParen gui=bold term=bold cterm=bold guifg=#9a5b00 guibg=NONE ctermfg=94 ctermbg=NONE
hi ModeMsg gui=bold term=bold cterm=bold guifg=#9a5b00 guibg=NONE ctermfg=94 ctermbg=NONE
hi MoreMsg gui=NONE term=NONE cterm=NONE guifg=#536e7b guibg=NONE ctermfg=60 ctermbg=NONE
hi NonText gui=NONE term=NONE cterm=NONE guifg=#766b90 guibg=NONE ctermfg=96 ctermbg=NONE
hi Normal gui=NONE term=NONE cterm=NONE guifg=#545464 guibg=#f2ecbc ctermfg=240 ctermbg=229
hi Number gui=NONE term=NONE cterm=NONE guifg=#a54c6b guibg=NONE ctermfg=131 ctermbg=NONE
hi Operator gui=NONE term=NONE cterm=NONE guifg=#7a6745 guibg=NONE ctermfg=95 ctermbg=NONE
hi Pmenu gui=NONE term=NONE cterm=NONE guifg=#545464 guibg=#c7d7e0 ctermfg=240 ctermbg=188
hi PmenuExtra gui=NONE term=NONE cterm=NONE guifg=#766b90 guibg=#c7d7e0 ctermfg=96 ctermbg=188
hi PmenuExtraSel gui=NONE term=NONE cterm=NONE guifg=#766b90 guibg=#b5cbd2 ctermfg=96 ctermbg=152
hi PmenuKind gui=NONE term=NONE cterm=NONE guifg=#43436c guibg=#c7d7e0 ctermfg=239 ctermbg=188
hi PmenuKindSel gui=NONE term=NONE cterm=NONE guifg=#43436c guibg=#b5cbd2 ctermfg=239 ctermbg=152
hi PmenuMatch gui=bold term=bold cterm=bold guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE
hi PmenuMatchSel gui=bold term=bold cterm=bold guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE
hi PmenuSbar gui=NONE term=NONE cterm=NONE guifg=NONE guibg=#c7d7e0 ctermfg=NONE ctermbg=188
hi PmenuSel gui=NONE term=NONE cterm=NONE guifg=NONE guibg=#b5cbd2 ctermfg=NONE ctermbg=152
hi PmenuThumb gui=NONE term=NONE cterm=NONE guifg=NONE guibg=#b5cbd2 ctermfg=NONE ctermbg=152
hi link PreCondit PreProc
hi PreProc gui=NONE term=NONE cterm=NONE guifg=#c0374a guibg=NONE ctermfg=131 ctermbg=NONE
hi link Question MoreMsg
hi QuickFixLine gui=NONE term=NONE cterm=NONE guifg=NONE guibg=#e7dba0 ctermfg=NONE ctermbg=187
hi link Repeat Statement
hi Search gui=NONE term=NONE cterm=NONE guifg=#545464 guibg=#b5cbd2 ctermfg=240 ctermbg=152
hi SignColumn gui=NONE term=NONE cterm=NONE guifg=#766b90 guibg=#e7dba0 ctermfg=96 ctermbg=187
hi Special gui=NONE term=NONE cterm=NONE guifg=#406d99 guibg=NONE ctermfg=60 ctermbg=NONE
hi link SpecialChar Special
hi link SpecialComment Special
hi SpecialKey gui=NONE term=NONE cterm=NONE guifg=#766b90 guibg=NONE ctermfg=96 ctermbg=NONE
hi SpellBad gui=undercurl term=undercurl cterm=undercurl guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE guisp=#d21616
hi SpellCap gui=undercurl term=undercurl cterm=undercurl guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE guisp=#9a5b00
hi SpellLocal gui=undercurl term=undercurl cterm=undercurl guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE guisp=#9a5b00
hi SpellRare gui=undercurl term=undercurl cterm=undercurl guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE guisp=#9a5b00
hi Statement gui=bold term=bold cterm=bold guifg=#624c83 guibg=NONE ctermfg=60 ctermbg=NONE
hi StatusLine gui=NONE term=NONE cterm=NONE guifg=#43436c guibg=#d5cea3 ctermfg=239 ctermbg=187
hi StatusLineNC gui=NONE term=NONE cterm=NONE guifg=#766b90 guibg=#d5cea3 ctermfg=96 ctermbg=187
hi link StatusLineTerm StatusLine
hi link StatusLineTermNC StatusLineNC
hi link StorageClass Type
hi String gui=NONE term=NONE cterm=NONE guifg=#5b7040 guibg=NONE ctermfg=240 ctermbg=NONE
hi link Structure Type
hi TabLine gui=NONE term=NONE cterm=NONE guifg=#766b90 guibg=#d5cea3 ctermfg=96 ctermbg=187
hi TabLineFill gui=NONE term=NONE cterm=NONE guifg=NONE guibg=#f2ecbc ctermfg=NONE ctermbg=229
hi TabLineSel gui=NONE term=NONE cterm=NONE guifg=#43436c guibg=#e7dba0 ctermfg=239 ctermbg=187
hi link Tag Special
hi Title gui=bold term=bold cterm=bold guifg=#4d699b guibg=NONE ctermfg=60 ctermbg=NONE
hi Todo gui=bold term=bold cterm=bold guifg=#f2ecbc guibg=#536e7b ctermfg=229 ctermbg=60
hi Type gui=NONE term=NONE cterm=NONE guifg=#4f7067 guibg=NONE ctermfg=241 ctermbg=NONE
hi link Typedef Type
hi Underlined gui=underline term=underline cterm=underline guifg=#406d99 guibg=NONE ctermfg=60 ctermbg=NONE
hi link VertSplit WinSeparator
hi Visual gui=NONE term=NONE cterm=NONE guifg=NONE guibg=#c7d7e0 ctermfg=NONE ctermbg=188
hi link VisualNOS Visual
hi WarningMsg gui=NONE term=NONE cterm=NONE guifg=#9a5b00 guibg=NONE ctermfg=94 ctermbg=NONE
hi link WildMenu Pmenu
hi link lCursor Cursor
hi WinSeparator gui=NONE term=NONE cterm=NONE guifg=#d5cea3 guibg=NONE ctermfg=187 ctermbg=NONE

" ============================================================================
" End of kanagawa (Wave) Colorscheme
" ============================================================================
