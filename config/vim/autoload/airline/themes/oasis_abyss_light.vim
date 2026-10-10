" oasis_abyss_light — Oasis Abyss Light 3 (https://github.com/uhs-robert/oasis.nvim),
" derived from catppuccin_latte.vim by the colour-role map in
" config/theme/palettes.d/oasis/light/starship.toml.
" =============================================================================
" Filename: autoload/airline/themes/oasis_abyss_light.vim
" Author: tilmaneggers
" License: MIT License
" Last Change: 2023/01/19
"
" =============================================================================

" Theme colors.
let s:rosewater = "#5B3B28"
let s:flamingo = "#BA141A"
let s:pink = "#2E6B28"
let s:mauve = "#691FBE"
let s:red = "#9E1010"
let s:maroon = "#870F13"
let s:peach = "#744211"
let s:yellow = "#554F1C"
let s:green = "#31572E"
let s:teal = "#2F564A"
let s:sky = "#1E546A"
let s:sapphire = "#750202"
let s:blue = "#11508D"
let s:lavender = "#5049C1"
"
let s:text = "#181811"
let s:subtext1 = "#3D4047"
let s:subtext0 = "#615E54"
let s:overlay2 = "#647276"
let s:overlay1 = "#7C7A74"
let s:overlay0 = "#615F57"
let s:surface2 = "#97CEBE"
let s:surface1 = "#B9B9B9"
let s:surface0 = "#CDCDCD"
"
let s:base = "#D8D8D8"
let s:mantle = "#D4D4D4"
let s:crust = "#D0D0D0"

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


let g:airline#themes#oasis_abyss_light#palette = {}

let g:airline#themes#oasis_abyss_light#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)

let g:airline#themes#oasis_abyss_light#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)
let g:airline#themes#oasis_abyss_light#palette.insert_replace = {
	\ 'airline_a': [ s:RE[0]   , s:I1[1]   , s:RE[1]   , s:I1[3]   , ''     ] }

let g:airline#themes#oasis_abyss_light#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3)

let g:airline#themes#oasis_abyss_light#palette.replace = copy(g:airline#themes#oasis_abyss_light#palette.normal)
let g:airline#themes#oasis_abyss_light#palette.replace.airline_a = [ s:RE[0] , s:RE[1] , s:RE[2] , s:RE[3] , '' ]

let s:IA = [ s:N1[1] , s:N3[1] , s:N1[3] , s:N3[3] , '' ]
let g:airline#themes#oasis_abyss_light#palette.inactive = airline#themes#generate_color_map(s:IA, s:IA, s:IA)

let g:airline#themes#oasis_abyss_light#palette.normal.airline_warning = s:WR
let g:airline#themes#oasis_abyss_light#palette.insert.airline_warning = s:WR
let g:airline#themes#oasis_abyss_light#palette.visual.airline_warning = s:WR
