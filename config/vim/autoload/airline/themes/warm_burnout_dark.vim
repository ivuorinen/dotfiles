" warm_burnout_dark — Warm Burnout Dark (https://github.com/felipefdl/warm-burnout),
" derived from catppuccin_mocha.vim by the colour-role map in
" config/theme/palettes.d/warm-burnout/light/starship.toml.
" =============================================================================
" Filename: autoload/airline/themes/warm_burnout_dark.vim
" Author: tilmaneggers
" License: MIT License
" Last Change: 2023/01/19
"
" =============================================================================

" Original theme colors
let s:rosewater = "#F5C56E"
let s:flamingo = "#DC9E92"
let s:pink = "#FF8F40"
let s:mauve = "#D4A8B8"
let s:red = "#F49090"
let s:maroon = "#EC9878"
let s:peach = "#F29668"
let s:yellow = "#FFB454"
let s:green = "#B4BC78"
let s:teal = "#96B898"
let s:sky = "#90AEC0"
let s:sapphire = "#E6C08A"
let s:blue = "#73B8FF"
let s:lavender = "#DEB074"
"
let s:text = "#BFBDB6"
let s:subtext1 = "#ADA69C"
let s:subtext0 = "#B4A89C"
let s:overlay2 = "#A59F96"
let s:overlay1 = "#746F67"
let s:overlay0 = "#6B6860"
let s:surface2 = "#4C4126"
let s:surface1 = "#2E3A41"
let s:surface0 = "#222018"
"
let s:base = "#1A1510"
let s:mantle = "#14120f"
let s:crust = "#14120F"

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


let g:airline#themes#warm_burnout_dark#palette = {}

let g:airline#themes#warm_burnout_dark#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)

let g:airline#themes#warm_burnout_dark#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)
let g:airline#themes#warm_burnout_dark#palette.insert_replace = {
	\ 'airline_a': [ s:RE[0]   , s:I1[1]   , s:RE[1]   , s:I1[3]   , ''     ] }

let g:airline#themes#warm_burnout_dark#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3)

let g:airline#themes#warm_burnout_dark#palette.replace = copy(g:airline#themes#warm_burnout_dark#palette.normal)
let g:airline#themes#warm_burnout_dark#palette.replace.airline_a = [ s:RE[0] , s:RE[1] , s:RE[2] , s:RE[3] , '' ]

let s:IA = [ s:N1[1] , s:N3[1] , s:N1[3] , s:N3[3] , '' ]
let g:airline#themes#warm_burnout_dark#palette.inactive = airline#themes#generate_color_map(s:IA, s:IA, s:IA)

let g:airline#themes#warm_burnout_dark#palette.normal.airline_warning = s:WR
let g:airline#themes#warm_burnout_dark#palette.insert.airline_warning = s:WR
let g:airline#themes#warm_burnout_dark#palette.visual.airline_warning = s:WR
