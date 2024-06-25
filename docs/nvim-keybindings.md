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
                 Toggle Cloak
   <Space>f    * <Lua 76: ~/.dotfiles/config/nvim-kickstart/init.lua:515>
                 [F]ormat buffer
n  <Space>1    * <Lua 58: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon to file 1
n  <Space>xn   * <Lua 57: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon to next file
n  <Space>xN   * <Lua 56: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon to previous file
n  <Space>xa   * <Lua 55: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon quick menu
n  <Space>xA   * <Lua 54: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon file
n  <Space>5    * <Lua 53: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon to file 5
n  <Space>4    * <Lua 52: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon to file 4
n  <Space>3    * <Lua 51: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon to file 3
n  <Space>2    * <Lua 49: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 harpoon to file 2
n  <Space>tz   * <Lua 43: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Toggle ZenMode
n  <Space>e    * <Lua 41: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
n  <Space>qq   * <Cmd>wq!<CR>
                 Quickly Quit
n  <Space>bq   * <Lua 27: ~/.local/share/bob/v0.10.0/nvim-macos-arm64/share/nvim/runtime/lua/vim/diagnostic.lua:1984>
                 Open diagnostic [Q]uickfix list
n  <Space>be   * <Lua 26: ~/.local/share/bob/v0.10.0/nvim-macos-arm64/share/nvim/runtime/lua/vim/diagnostic.lua:1694>
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
o  al            <Lua 388: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1145>
                 Around last textobject
o  an            <Lua 387: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1145>
                 Around next textobject
x  al            <Lua 384: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1145>
                 Around last textobject
x  an            <Lua 383: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1145>
                 Around next textobject
o  a             <Lua 381: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1145>
                 Around textobject
x  a             <Lua 379: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1145>
                 Around textobject
n  dj          * <Lua 25: ~/.local/share/bob/v0.10.0/nvim-macos-arm64/share/nvim/runtime/lua/vim/diagnostic.lua:1222>
                 Go to next [D]iagnostic message
n  dk          * <Lua 23: ~/.local/share/bob/v0.10.0/nvim-macos-arm64/share/nvim/runtime/lua/vim/diagnostic.lua:1145>
                 Go to previous [D]iagnostic message
o  g%            <Plug>(MatchitOperationBackward)
x  g%            <Plug>(MatchitVisualBackward)
n  g%            <Plug>(MatchitNormalBackward)
o  g]            <Lua 378: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1142>
                 Move to right "around"
x  g]            <Lua 377: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1142>
                 Move to right "around"
n  g]            <Lua 376: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1142>
                 Move to right "around"
o  g[            <Lua 374: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1141>
                 Move to left "around"
x  g[            <Lua 372: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1141>
                 Move to left "around"
n  g[            <Lua 368: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1141>
                 Move to left "around"
n  gcA         * <Lua 365: ~/.local/share/nvim-kickstart/lazy/Comment.nvim/lua/Comment/api.lua:218>
                 Comment insert end of line
n  gcO         * <Lua 364: ~/.local/share/nvim-kickstart/lazy/Comment.nvim/lua/Comment/api.lua:179>
                 Comment insert above
n  gco         * <Lua 11: ~/.local/share/nvim-kickstart/lazy/Comment.nvim/lua/Comment/api.lua:182>
                 Comment insert below
x  gb          * <Plug>(comment_toggle_blockwise_visual)
                 Comment toggle blockwise (visual)
n  gbc         * <Lua 12: ~/.local/share/nvim-kickstart/lazy/Comment.nvim/lua/Comment/init.lua:107>
                 Comment toggle current block
n  gb          * <Plug>(comment_toggle_blockwise)
                 Comment toggle blockwise
o  gc          * <Lua 13: vim/_defaults.lua:0>
                 Comment textobject
n  gcc         * <Lua 10: ~/.local/share/nvim-kickstart/lazy/Comment.nvim/lua/Comment/init.lua:103>
                 Comment toggle current line
x  gc          * <Plug>(comment_toggle_linewise_visual)
                 Comment toggle linewise (visual)
n  gc          * <Plug>(comment_toggle_linewise)
                 Comment toggle linewise
x  gx          * <Lua 9: vim/_defaults.lua:0>
                 Opens filepath or URI under cursor with the system handler (file explorer, web browser, …)
n  gx          * <Lua 8: vim/_defaults.lua:0>
                 Opens filepath or URI under cursor with the system handler (file explorer, web browser, …)
o  il            <Lua 390: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1145>
                 Inside last textobject
o  in            <Lua 389: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1145>
                 Inside next textobject
x  il            <Lua 386: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1145>
                 Inside last textobject
x  in            <Lua 385: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1145>
                 Inside next textobject
o  i             <Lua 382: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1145>
                 Inside textobject
x  i             <Lua 380: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/ai.lua:1145>
                 Inside textobject
n  shn         * <Lua 407: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1220>
                 Highlight next surrounding
n  sFn         * <Lua 406: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1220>
                 Find next left surrounding
n  sfn         * <Lua 405: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1220>
                 Find next right surrounding
n  srn         * <Lua 404: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1220>
                 Replace next surrounding
n  sdn         * <Lua 403: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1220>
                 Delete next surrounding
n  shl         * <Lua 402: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1220>
                 Highlight previous surrounding
n  sFl         * <Lua 401: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1220>
                 Find previous left surrounding
n  sfl         * <Lua 400: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1220>
                 Find previous right surrounding
n  srl         * <Lua 399: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1220>
                 Replace previous surrounding
n  sdl         * <Lua 398: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1220>
                 Delete previous surrounding
x  sa          * :<C-U>lua MiniSurround.add('visual')<CR>
                 Add surrounding to selection
n  sn          * <Lua 397: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:861>
                 Update `MiniSurround.config.n_lines`
n  sh          * <Lua 396: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1220>
                 Highlight surrounding
n  sF          * <Lua 395: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1220>
                 Find left surrounding
n  sf          * <Lua 394: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1220>
                 Find right surrounding
n  sr          * <Lua 393: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1220>
                 Replace surrounding
n  sd          * <Lua 392: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1220>
                 Delete surrounding
n  sa          * <Lua 391: ~/.local/share/nvim-kickstart/lazy/mini.nvim/lua/mini/surround.lua:1220>
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
n  <Plug>PlenaryTestFile * :lua require('plenary.test_harness').test_file(vim.fn.expand("%:p"))<CR>
n  <C-P>       * :Files<CR>
                 FZF: search for files starting at current directory.
o  <Plug>(fzf-maps-o) * <C-C>:<C-U>call fzf#vim#maps('o', 0)<CR>
x  <Plug>(fzf-maps-x) * :<C-U>call fzf#vim#maps('x', 0)<CR>
n  <Plug>(fzf-maps-n) * :<C-U>call fzf#vim#maps('n', 0)<CR>
n  <Plug>(fzf-normal) * <Nop>
n  <Plug>(fzf-insert) * i
x  <Plug>(comment_toggle_blockwise_visual) * <Esc><Cmd>lua require("Comment.api").locked("toggle.blockwise")(vim.fn.visualmode())<CR>
                 Comment toggle blockwise (visual)
x  <Plug>(comment_toggle_linewise_visual) * <Esc><Cmd>lua require("Comment.api").locked("toggle.linewise")(vim.fn.visualmode())<CR>
                 Comment toggle linewise (visual)
n  <Plug>(comment_toggle_blockwise_count) * <Lua 362: ~/.local/share/nvim-kickstart/lazy/Comment.nvim/lua/Comment/api.lua:246>
                 Comment toggle blockwise with count
n  <Plug>(comment_toggle_linewise_count) * <Lua 361: ~/.local/share/nvim-kickstart/lazy/Comment.nvim/lua/Comment/api.lua:246>
                 Comment toggle linewise with count
n  <Plug>(comment_toggle_blockwise_current) * <Lua 360: ~/.local/share/nvim-kickstart/lazy/Comment.nvim/lua/Comment/api.lua:246>
                 Comment toggle current block
n  <Plug>(comment_toggle_linewise_current) * <Lua 359: ~/.local/share/nvim-kickstart/lazy/Comment.nvim/lua/Comment/api.lua:246>
                 Comment toggle current line
n  <Plug>(comment_toggle_blockwise) * <Lua 358: ~/.local/share/nvim-kickstart/lazy/Comment.nvim/lua/Comment/api.lua:246>
                 Comment toggle blockwise
n  <Plug>(comment_toggle_linewise) * <Lua 357: ~/.local/share/nvim-kickstart/lazy/Comment.nvim/lua/Comment/api.lua:246>
                 Comment toggle linewise
n  <C-Bslash>  * <Lua 72: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
n  <C-S>       * <Cmd>w<CR>
                 Save file
n  <C-K>       * <Lua 75: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
n  <C-J>       * <Lua 73: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
n  <C-H>       * <Lua 74: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
n  <Down>      * <Cmd>echo "Use j to move!!"<CR>
n  <Up>        * <Cmd>echo "Use k to move!!"<CR>
n  <Right>     * <Cmd>echo "Use l to move!!"<CR>
n  <Left>      * <Cmd>echo "Use h to move!!"<CR>
n  <C-W><C-D>    <C-W>d
                 Show diagnostics under the cursor
n  <C-W>d      * <Lua 16: vim/_defaults.lua:0>
                 Show diagnostics under the cursor
n  <C-L>       * <Lua 70: ~/.local/share/nvim-kickstart/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
```

- Generated on Tue 25 Jun 2024 09:49:41 EEST
