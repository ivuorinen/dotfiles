# Warm Burnout colour roles

Warm Burnout, derived from `../catppuccin/ROLES.md` by the colour-role map
below.

Palette source: <https://github.com/felipefdl/warm-burnout> (Warm Burnout Light),
`nvim/lua/warm-burnout/palette.lua` and `vim/colors/warm-burnout-light.vim` at
upstream 6e1f75fd.

Upstream's syntax colours reach WCAG AA on `#f5ede0`; these do not, and are
changed in HSL lightness only wherever they are used: the accent `#b8522e` ->
`#b04e2c` (4.22 -> 4.55; dark `#cd5d36`, 3.70 -> 4.50), ANSI bright yellow
`#9a7008` -> `#8b6507`, bright blue `#2870b0` -> `#286faf` and bright cyan
`#208870` -> `#1d7964`, and vim's line-number grey `#a89f8c` -> `#938871`
(muted, 2.26 -> 3.01).

Each Catppuccin role takes one Warm Burnout key, in the Warm Burnout tmux
palettes and in vim and COSMIC (nvim and wezterm use upstream's own colours
with the fixes above); `tests/theme-contrast.bats` recomputes the ratios.
Role, key, dark, light:

```text
rosewater cursor           #f5c56e  #8a6600
flamingo  tag              #dc9e92  #8e4632
pink      keyword          #ff8f40  #924800
mauve     number           #d4a8b8  #7e4060
red       error            #f49090  #b03434
maroon    member           #ec9878  #883850
peach     operator         #f29668  #8f4418
yellow    func             #ffb454  #855700
green     string           #b4bc78  #4d5c1a
teal      regex            #96b898  #286a48
sky       type             #90aec0  #285464
sapphire  decorator        #e6c08a  #7a5a1c
blue      modified         #73b8ff  #2868a0
lavender  property         #deb074  #74501c
text      fg               #bfbdb6  #3a3630
subtext1  fg_dim           #ada69c  #5c5750
subtext0  comment          #b4a89c  #544c40
overlay2  fg_gutter_active #a59f96  #6a6258
overlay1  fg_gutter        #746f67  #8a8070
overlay0  line_nr          #6b6860  #938871
surface2  bg_search        #4c4126  #e0c890
surface1  visual           #2e3a41  #cfdae2
surface0  cursor_line      #222018  #ece4d6
base      bg               #1a1510  #f5ede0
mantle    bg_dim           #14120f  #ede6da
crust     bg_dim           #14120f  #ede6da
```
