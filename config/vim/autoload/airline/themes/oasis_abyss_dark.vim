" oasis_abyss_dark — Oasis Abyss Dark (https://github.com/uhs-robert/oasis.nvim),
" derived from catppuccin_mocha.vim by the colour-role map in
" config/theme/palettes.d/oasis/light/starship.toml.
" =============================================================================
" Filename: autoload/airline/themes/oasis_abyss_dark.vim
" Author: tilmaneggers
" License: MIT License
" Last Change: 2023/01/19
"
" =============================================================================

" Original theme colors
let s:rosewater = "#E9C0A5"
let s:flamingo = "#FFC0C0"
let s:pink = "#7FCF78"
let s:mauve = "#C695FF"
let s:red = "#FF7979"
let s:maroon = "#FFA0A0"
let s:peach = "#F8B471"
let s:yellow = "#F0E68C"
let s:green = "#7FCF78"
let s:teal = "#8AD3BE"
let s:sky = "#87CEEB"
let s:sapphire = "#FF7979"
let s:blue = "#81C0FF"
let s:lavender = "#8D8DE7"
"
let s:text = "#F5F5DC"
let s:subtext1 = "#A3ABB8"
let s:subtext0 = "#7A7662"
let s:overlay2 = "#607D85"
let s:overlay1 = "#7B786D"
let s:overlay0 = "#605C4D"
let s:surface2 = "#2B4A46"
let s:surface1 = "#1C1C1C"
let s:surface0 = "#141414"
"
let s:base = "#000000"
let s:mantle = "#080808"
let s:crust = "#121212"

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


let g:airline#themes#oasis_abyss_dark#palette = {}

let g:airline#themes#oasis_abyss_dark#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)

let g:airline#themes#oasis_abyss_dark#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)
let g:airline#themes#oasis_abyss_dark#palette.insert_replace = {
	\ 'airline_a': [ s:RE[0]   , s:I1[1]   , s:RE[1]   , s:I1[3]   , ''     ] }

let g:airline#themes#oasis_abyss_dark#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3)

let g:airline#themes#oasis_abyss_dark#palette.replace = copy(g:airline#themes#oasis_abyss_dark#palette.normal)
let g:airline#themes#oasis_abyss_dark#palette.replace.airline_a = [ s:RE[0] , s:RE[1] , s:RE[2] , s:RE[3] , '' ]

let s:IA = [ s:N1[1] , s:N3[1] , s:N1[3] , s:N3[3] , '' ]
let g:airline#themes#oasis_abyss_dark#palette.inactive = airline#themes#generate_color_map(s:IA, s:IA, s:IA)

let g:airline#themes#oasis_abyss_dark#palette.normal.airline_warning = s:WR
let g:airline#themes#oasis_abyss_dark#palette.insert.airline_warning = s:WR
let g:airline#themes#oasis_abyss_dark#palette.visual.airline_warning = s:WR
