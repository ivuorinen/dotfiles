" kanagawa_lotus — derived from catppuccin_latte.vim by the colour-role map in
" docs/plans/2026-09-30-kanagawa-theme-families.md.
" =============================================================================
" Filename: autoload/airline/themes/kanagawa_lotus.vim
" Author: tilmaneggers
" License: MIT License
" Last Change: 2023/01/19
"
" =============================================================================

" Theme colors. Accents darkened from upstream Latte (same HSL hue and
" saturation) to reach WCAG AA 4.5:1 on base #F2ECBC; mapping in
" config/theme/palettes.d/kanagawa/light/starship.toml.
let s:rosewater = "#9A5B00"
let s:flamingo = "#C92C30"
let s:pink = "#A54C6B"
let s:mauve = "#624C83"
let s:red = "#C0374A"
let s:maroon = "#C92C30"
let s:peach = "#A15600"
let s:yellow = "#716b3c"
let s:green = "#5B7040"
let s:teal = "#51706B"
let s:sky = "#3E7082"
let s:sapphire = "#536e7b"
let s:blue = "#4D699B"
let s:lavender = "#5D57A3"
"
let s:text = "#545464"
let s:subtext1 = "#43436C"
let s:subtext0 = "#6D6A5E"
let s:overlay2 = "#766B90"
let s:overlay1 = "#716E61"
let s:overlay0 = "#88877E"
let s:surface2 = "#A09CAC"
let s:surface1 = "#D5CEA3"
let s:surface0 = "#E7DBA0"
"
let s:base = "#F2ECBC"
let s:mantle = "#E5DDB0"
let s:crust = "#DCD5AC"

" Normal mode
" (Dark)
let s:N1 = [ s:mantle , s:blue , 59  , 149 ] " guifg guibg ctermfg ctermbg
let s:N2 = [ s:blue , s:surface1 , 149 , 59  ] " guifg guibg ctermfg ctermbg
let s:N3 = [ s:text , s:base , 145 , 16  ] " guifg guibg ctermfg ctermbg

" Insert mode
let s:I1 = [ s:mantle , s:teal , 59  , 74  ] " guifg guibg ctermfg ctermbg
let s:I2 = [ s:teal , s:mantle , 74  , 59  ] " guifg guibg ctermfg ctermbg
let s:I3 = [ s:text , s:base , 145 , 16  ] " guifg guibg ctermfg ctermbg

" Visual mode
let s:V1 = [ s:mantle , s:mauve , 59  , 209 ] " guifg guibg ctermfg ctermbg
let s:V2 = [ s:mauve , s:mantle , 209 , 59  ] " guifg guibg ctermfg ctermbg
let s:V3 = [ s:text , s:base , 145 , 16  ] " guifg guibg ctermfg ctermbg

" Replace mode
let s:RE = [ s:mantle , s:red , 59  , 203 ] " guifg guibg ctermfg ctermbg

" Warning section
let s:WR = [s:mantle ,s:peach , 232, 166 ]


let g:airline#themes#kanagawa_lotus#palette = {}

let g:airline#themes#kanagawa_lotus#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)

let g:airline#themes#kanagawa_lotus#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)
let g:airline#themes#kanagawa_lotus#palette.insert_replace = {
	\ 'airline_a': [ s:RE[0]   , s:I1[1]   , s:RE[1]   , s:I1[3]   , ''     ] }

let g:airline#themes#kanagawa_lotus#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3)

let g:airline#themes#kanagawa_lotus#palette.replace = copy(g:airline#themes#kanagawa_lotus#palette.normal)
let g:airline#themes#kanagawa_lotus#palette.replace.airline_a = [ s:RE[0] , s:RE[1] , s:RE[2] , s:RE[3] , '' ]

let s:IA = [ s:N1[1] , s:N3[1] , s:N1[3] , s:N3[3] , '' ]
let g:airline#themes#kanagawa_lotus#palette.inactive = airline#themes#generate_color_map(s:IA, s:IA, s:IA)

let g:airline#themes#kanagawa_lotus#palette.normal.airline_warning = s:WR
let g:airline#themes#kanagawa_lotus#palette.insert.airline_warning = s:WR
let g:airline#themes#kanagawa_lotus#palette.visual.airline_warning = s:WR
