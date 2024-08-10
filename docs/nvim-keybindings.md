# nvim keybindings

```txt

n  <Esc>       * <Cmd>nohlsearch<CR>
n  <Space>zg   * :Rg<CR>
                 FZF: search with rg (aka live grep).
n  <Space>zm   * :Maps<CR>
                 FZF: search mappings.
n  <Space>zh   * :History<CR>
                 FZF: search history of opened files
n  <Space>zb   * :Buffers<CR>
                 FZF: search open buffers.
n  <Space>zt   * :Windows<CR>
                 FZF: search open tabs.
n  <Space>zc   * :Commands<CR>
                 FZF: search commands.
n  <Space>zf   * :FZF<Space>
                 FZF: search for files in given path.
n  <Space>tc   * <Cmd>CloakToggle<CR>
                 [tc] Toggle Cloak
n  <Space>4    * <Lua 84: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon to file 4
n  <Space>3    * <Lua 83: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon to file 3
n  <Space>2    * <Lua 82: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon to file 2
n  <Space>1    * <Lua 81: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon to file 1
n  <Space>xn   * <Lua 80: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon to next file
n  <Space>xa   * <Lua 79: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon quick menu
n  <Space>xN   * <Lua 78: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon to previous file
n  <Space>xA   * <Lua 77: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon file
n  <Space>5    * <Lua 76: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon to file 5
n  <Space>tz   * <Lua 51: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 [tz] Toggle ZenMode
n  <Space>e    * <Lua 47: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
   <Space>f    * <Lua 40: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 [f] Format buffer
n  <Space>qq   * <Cmd>wq!<CR>
                 Quickly Quit
n  <Space>bq   * <Lua 28: ~/.local/share/bob/v0.10.0/nvim-macos-arm64/share/nvim/runtime/lua/vim/diagnostic.lua:1984>
                 Open diagnostic [Q]uickfix list
n  <Space>be   * <Lua 27: ~/.local/share/bob/v0.10.0/nvim-macos-arm64/share/nvim/runtime/lua/vim/diagnostic.lua:1694>
                 Show diagnostic [E]rror messages
x  #           * <Lua 7: vim/_defaults.lua:0>
                 :help v_#-default
o  %             <Plug>(MatchitOperationForward)
x  %             <Plug>(MatchitVisualForward)
n  %             <Plug>(MatchitNormalForward)
n  &           * :&&<CR>
                 :help &-default
x  *           * <Lua 3: vim/_defaults.lua:0>
                 :help v_star-default
x  @           * mode() == 'V' ? ':normal! @'.getcharstr().'<CR>' : '@'
                 :help v_@-default
x  Q           * mode() == 'V' ? ':normal! @<C-R>=reg_recorded()<CR><CR>' : 'Q'
                 :help v_Q-default
n  Y           * y$
                 :help Y-default
o  [%            <Plug>(MatchitOperationMultiBackward)
x  [%            <Plug>(MatchitVisualMultiBackward)
n  [%            <Plug>(MatchitNormalMultiBackward)
n  [d          * <Lua 15: vim/_defaults.lua:0>
                 Jump to the previous diagnostic
o  ]%            <Plug>(MatchitOperationMultiForward)
x  ]%            <Plug>(MatchitVisualMultiForward)
n  ]%            <Plug>(MatchitNormalMultiForward)
n  ]d          * <Lua 14: vim/_defaults.lua:0>
                 Jump to the next diagnostic
x  a%            <Plug>(MatchitVisualTextObject)
o  al            <Lua 247: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1172>
                 Around last textobject
o  an            <Lua 246: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1172>
                 Around next textobject
x  al            <Lua 243: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1172>
                 Around last textobject
x  an            <Lua 242: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1172>
                 Around next textobject
o  a             <Lua 240: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1172>
                 Around textobject
x  a             <Lua 238: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1172>
                 Around textobject
n  dj          * <Lua 26: ~/.local/share/bob/v0.10.0/nvim-macos-arm64/share/nvim/runtime/lua/vim/diagnostic.lua:1222>
                 Go to next [D]iagnostic message
n  dk          * <Lua 25: ~/.local/share/bob/v0.10.0/nvim-macos-arm64/share/nvim/runtime/lua/vim/diagnostic.lua:1145>
                 Go to previous [D]iagnostic message
o  g%            <Plug>(MatchitOperationBackward)
x  g%            <Plug>(MatchitVisualBackward)
n  g%            <Plug>(MatchitNormalBackward)
n  gR          * :RegexplainerToggle<CR>
                 Toggle Regexplainer
o  g]            <Lua 237: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1169>
                 Move to right "around"
x  g]            <Lua 236: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1169>
                 Move to right "around"
n  g]            <Lua 235: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1169>
                 Move to right "around"
o  g[            <Lua 234: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1168>
                 Move to left "around"
x  g[            <Lua 233: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1168>
                 Move to left "around"
n  g[            <Lua 232: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1168>
                 Move to left "around"
o  gc          * <Lua 13: vim/_defaults.lua:0>
                 Comment textobject
n  gcc         * <Lua 12: vim/_defaults.lua:0>
                 Toggle comment line
x  gc          * <Lua 11: vim/_defaults.lua:0>
                 Toggle comment
n  gc          * <Lua 10: vim/_defaults.lua:0>
                 Toggle comment
x  gx          * <Lua 9: vim/_defaults.lua:0>
                 Opens filepath or URI under cursor with the system handler (file explorer, web browser, …)
n  gx          * <Lua 8: vim/_defaults.lua:0>
                 Opens filepath or URI under cursor with the system handler (file explorer, web browser, …)
o  il            <Lua 249: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1172>
                 Inside last textobject
o  in            <Lua 248: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1172>
                 Inside next textobject
x  il            <Lua 245: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1172>
                 Inside last textobject
x  in            <Lua 244: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1172>
                 Inside next textobject
o  i             <Lua 241: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1172>
                 Inside textobject
x  i             <Lua 239: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1172>
                 Inside textobject
n  shn         * <Lua 266: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1252>
                 Highlight next surrounding
n  sFn         * <Lua 265: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1252>
                 Find next left surrounding
n  sfn         * <Lua 264: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1252>
                 Find next right surrounding
n  srn         * <Lua 263: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1252>
                 Replace next surrounding
n  sdn         * <Lua 262: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1252>
                 Delete next surrounding
n  shl         * <Lua 261: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1252>
                 Highlight previous surrounding
n  sFl         * <Lua 260: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1252>
                 Find previous left surrounding
n  sfl         * <Lua 259: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1252>
                 Find previous right surrounding
n  srl         * <Lua 258: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1252>
                 Replace previous surrounding
n  sdl         * <Lua 257: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1252>
                 Delete previous surrounding
x  sa          * :<C-U>lua MiniSurround.add('visual')<CR>
                 Add surrounding to selection
n  sn          * <Lua 256: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:892>
                 Update `MiniSurround.config.n_lines`
n  sh          * <Lua 255: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1252>
                 Highlight surrounding
n  sF          * <Lua 254: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1252>
                 Find left surrounding
n  sf          * <Lua 253: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1252>
                 Find right surrounding
n  sr          * <Lua 252: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1252>
                 Replace surrounding
n  sd          * <Lua 251: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1252>
                 Delete surrounding
n  sa          * <Lua 250: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1252>
                 Add surrounding
x  <Plug>(MatchitVisualTextObject)   <Plug>(MatchitVisualMultiBackward)o<Plug>(MatchitVisualMultiForward)
o  <Plug>(MatchitOperationMultiForward) * :<C-U>call matchit#MultiMatch("W",  "o")<CR>
o  <Plug>(MatchitOperationMultiBackward) * :<C-U>call matchit#MultiMatch("bW", "o")<CR>
x  <Plug>(MatchitVisualMultiForward) * :<C-U>call matchit#MultiMatch("W",  "n")<CR>m'gv``
x  <Plug>(MatchitVisualMultiBackward) * :<C-U>call matchit#MultiMatch("bW", "n")<CR>m'gv``
n  <Plug>(MatchitNormalMultiForward) * :<C-U>call matchit#MultiMatch("W",  "n")<CR>
n  <Plug>(MatchitNormalMultiBackward) * :<C-U>call matchit#MultiMatch("bW", "n")<CR>
o  <Plug>(MatchitOperationBackward) * :<C-U>call matchit#Match_wrapper('',0,'o')<CR>
o  <Plug>(MatchitOperationForward) * :<C-U>call matchit#Match_wrapper('',1,'o')<CR>
x  <Plug>(MatchitVisualBackward) * :<C-U>call matchit#Match_wrapper('',0,'v')<CR>m'gv``
x  <Plug>(MatchitVisualForward) * :<C-U>call matchit#Match_wrapper('',1,'v')<CR>:if col("''") != col("$") | exe ":normal! m'" | endif<CR>gv``
n  <Plug>(MatchitNormalBackward) * :<C-U>call matchit#Match_wrapper('',0,'n')<CR>
n  <Plug>(MatchitNormalForward) * :<C-U>call matchit#Match_wrapper('',1,'n')<CR>
n  <C-P>       * :Files<CR>
                 FZF: search for files starting at current directory.
o  <Plug>(fzf-maps-o) * <C-C>:<C-U>call fzf#vim#maps('o', 0)<CR>
x  <Plug>(fzf-maps-x) * :<C-U>call fzf#vim#maps('x', 0)<CR>
n  <Plug>(fzf-maps-n) * :<C-U>call fzf#vim#maps('n', 0)<CR>
n  <Plug>(fzf-normal) * <Nop>
n  <Plug>(fzf-insert) * i
n  <C-Bslash>  * <Lua 60: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
n  <C-S>       * <Cmd>w<CR>
                 Save file
n  <C-K>       * <Lua 57: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
n  <C-J>       * <Lua 56: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
n  <C-H>       * <Lua 58: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
n  <Down>      * <Cmd>echo "Use j to move!!"<CR>
n  <Up>        * <Cmd>echo "Use k to move!!"<CR>
n  <Right>     * <Cmd>echo "Use l to move!!"<CR>
n  <Left>      * <Cmd>echo "Use h to move!!"<CR>
n  <C-W><C-D>    <C-W>d
                 Show diagnostics under the cursor
n  <C-W>d      * <Lua 16: vim/_defaults.lua:0>
                 Show diagnostics under the cursor
n  <C-L>       * <Lua 59: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
```

- Generated on Sat 10 Aug 2024 13:01:59 EEST
