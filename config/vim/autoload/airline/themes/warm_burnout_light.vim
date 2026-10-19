" warm_burnout_light — Warm Burnout Light (https://github.com/felipefdl/warm-burnout),
" derived from catppuccin_latte.vim by the colour-role map in
" config/theme/palettes.d/warm-burnout/light/starship.toml.
" =============================================================================
" Filename: autoload/airline/themes/warm_burnout_light.vim
" Author: tilmaneggers
" License: MIT License
" Last Change: 2023/01/19
"
" =============================================================================

" Theme colors.
let s:rosewater = "#8A6600"
let s:flamingo = "#8E4632"
let s:pink = "#924800"
let s:mauve = "#7E4060"
let s:red = "#B03434"
let s:maroon = "#883850"
let s:peach = "#8F4418"
let s:yellow = "#855700"
let s:green = "#4D5C1A"
let s:teal = "#286A48"
let s:sky = "#285464"
let s:sapphire = "#7a5a1c"
let s:blue = "#2868A0"
let s:lavender = "#74501C"
"
let s:text = "#3A3630"
let s:subtext1 = "#5C5750"
let s:subtext0 = "#544C40"
let s:overlay2 = "#6A6258"
let s:overlay1 = "#8A8070"
let s:overlay0 = "#938871"
let s:surface2 = "#E0C890"
let s:surface1 = "#CFDAE2"
let s:surface0 = "#ECE4D6"
"
let s:base = "#F5EDE0"
let s:mantle = "#EDE6DA"
let s:crust = "#EDE6DA"

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


let g:airline#themes#warm_burnout_light#palette = {}

let g:airline#themes#warm_burnout_light#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)

let g:airline#themes#warm_burnout_light#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)
let g:airline#themes#warm_burnout_light#palette.insert_replace = {
	\ 'airline_a': [ s:RE[0]   , s:I1[1]   , s:RE[1]   , s:I1[3]   , ''     ] }

let g:airline#themes#warm_burnout_light#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3)

let g:airline#themes#warm_burnout_light#palette.replace = copy(g:airline#themes#warm_burnout_light#palette.normal)
let g:airline#themes#warm_burnout_light#palette.replace.airline_a = [ s:RE[0] , s:RE[1] , s:RE[2] , s:RE[3] , '' ]

let s:IA = [ s:N1[1] , s:N3[1] , s:N1[3] , s:N3[3] , '' ]
let g:airline#themes#warm_burnout_light#palette.inactive = airline#themes#generate_color_map(s:IA, s:IA, s:IA)

let g:airline#themes#warm_burnout_light#palette.normal.airline_warning = s:WR
let g:airline#themes#warm_burnout_light#palette.insert.airline_warning = s:WR
let g:airline#themes#warm_burnout_light#palette.visual.airline_warning = s:WR
