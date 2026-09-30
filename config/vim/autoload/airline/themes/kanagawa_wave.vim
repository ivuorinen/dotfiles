" kanagawa_wave — derived from catppuccin_mocha.vim by the colour-role map in
" docs/plans/2026-09-30-kanagawa-theme-families.md.
" =============================================================================
" Filename: autoload/airline/themes/kanagawa_wave.vim
" Author: tilmaneggers
" License: MIT License
" Last Change: 2023/01/19
"
" =============================================================================

" Original theme colors
let s:rosewater = "#C8C093"
let s:flamingo = "#E46876"
let s:pink = "#D27E99"
let s:mauve = "#957FB8"
let s:red = "#E46876"
let s:maroon = "#FF5D62"
let s:peach = "#FFA066"
let s:yellow = "#E6C384"
let s:green = "#98BB6C"
let s:teal = "#7AA89F"
let s:sky = "#7FB4CA"
let s:sapphire = "#A3D4D5"
let s:blue = "#7E9CD8"
let s:lavender = "#9CABCA"
"
let s:text = "#DCD7BA"
let s:subtext1 = "#C8C093"
let s:subtext0 = "#A6A69C"
let s:overlay2 = "#938AA9"
let s:overlay1 = "#717C7C"
let s:overlay0 = "#727169"
let s:surface2 = "#54546D"
let s:surface1 = "#363646"
let s:surface0 = "#2a2a37"
"
let s:base = "#1F1F28"
let s:mantle = "#181820"
let s:crust = "#16161D"

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


let g:airline#themes#kanagawa_wave#palette = {}

let g:airline#themes#kanagawa_wave#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)

let g:airline#themes#kanagawa_wave#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)
let g:airline#themes#kanagawa_wave#palette.insert_replace = {
	\ 'airline_a': [ s:RE[0]   , s:I1[1]   , s:RE[1]   , s:I1[3]   , ''     ] }

let g:airline#themes#kanagawa_wave#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3)

let g:airline#themes#kanagawa_wave#palette.replace = copy(g:airline#themes#kanagawa_wave#palette.normal)
let g:airline#themes#kanagawa_wave#palette.replace.airline_a = [ s:RE[0] , s:RE[1] , s:RE[2] , s:RE[3] , '' ]

let s:IA = [ s:N1[1] , s:N3[1] , s:N1[3] , s:N3[3] , '' ]
let g:airline#themes#kanagawa_wave#palette.inactive = airline#themes#generate_color_map(s:IA, s:IA, s:IA)

let g:airline#themes#kanagawa_wave#palette.normal.airline_warning = s:WR
let g:airline#themes#kanagawa_wave#palette.insert.airline_warning = s:WR
let g:airline#themes#kanagawa_wave#palette.visual.airline_warning = s:WR
