# nvim keybindings

```txt

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
n  <Space>/    * <Lua 189: ~/.config/nvim/lua/plugins/telescope.lua:85>
                 [/] Fuzzily search in current buffer]
n  <Space>ht   * <Lua 267: ~/.config/nvim/lua/plugins/harpoon.lua:16>
n  <Space>1    * <Lua 65: ~/.config/nvim/lua/plugins/harpoon.lua:68>
                 harpoon to file 1
n  <Space>xn   * <Lua 64: ~/.config/nvim/lua/plugins/harpoon.lua:61>
                 harpoon to next file
n  <Space>xN   * <Lua 63: ~/.config/nvim/lua/plugins/harpoon.lua:54>
                 harpoon to previous file
n  <Space>xa   * <Lua 136: ~/.config/nvim/lua/plugins/harpoon.lua:40>
                 Open harpoon window
n  <Space>5    * <Lua 61: ~/.config/nvim/lua/plugins/harpoon.lua:96>
                 harpoon to file 5
n  <Space>4    * <Lua 60: ~/.config/nvim/lua/plugins/harpoon.lua:89>
                 harpoon to file 4
n  <Space>3    * <Lua 59: ~/.config/nvim/lua/plugins/harpoon.lua:82>
                 harpoon to file 3
n  <Space>2    * <Lua 57: ~/.config/nvim/lua/plugins/harpoon.lua:75>
                 harpoon to file 2
n  <Space>gB   * :G blame<CR>
n  <Space>gb   * :Telescope git_branches<CR>
n  <Space>gP   * :Neogit push<CR>
n  <Space>gp   * :Neogit pull<CR>
n  <Space>gc   * :Neogit commit<CR>
n  <Space>gs   * <Lua 121: ~/.local/share/nvim/lazy/neogit/lua/neogit.lua:151>
n  <Space>e    * <Lua 96: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 NeoTree reveal
n  <Space>ca   * <Lua 95: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 LSP: Code Action
n  <Space>wl   * <Lua 94: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 LSP: Workspace List Folders
n  <Space>wr   * <Lua 93: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 LSP: Workspace Remove Folder
n  <Space>wa   * <Lua 92: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 LSP: Workspace Add Folder
n  <Space>ws   * <Lua 91: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 LSP: Workspace Symbols
n  <Space>D    * <Lua 89: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 LSP: Type Definition
n  <Space>dq   * <Lua 87: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Diagnostic: Set loc list
n  <Space>do   * <Lua 86: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Diagnostic: Open float
n  <Space>cr   * <Lua 84: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 LSP: Rename
n  <Space>ds   * <Lua 83: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 LSP: Document Symbols
n  <Space>?s   * <Lua 78: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Neoconf: Show merged config
n  <Space>?m   * <Lua 77: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Neoconf: Show merged LSP config
n  <Space>?l   * <Lua 76: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Neoconf: Local
n  <Space>?g   * <Lua 75: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Neoconf: Global
n  <Space>?c   * <Lua 73: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Neoconf: Open
   <Space>f    * <Lua 37: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 [f] Format buffer
n  <Space>qq   * <Cmd>wq!<CR>
                 [qq] Quickly Quit
n  <Space>xe   * <Cmd>GoIfErr<CR>
                 Go If Error
v  <Space>     * <Nop>
n  <Space>     * <Nop>
n  <Space>qf   * :q<CR>
                 Quicker close split
n  <Space>bw     :Bwipeout<CR>
                 Buffer: Wipeout
n  <Space>bd     :Bdelete<CR>
                 Buffer: Delete
n  <Space>bl     :bnext<CR>
                 Buffer: Next
n  <Space>bh     :bprev<CR>
                 Buffer: Prev
n  <Space>bj     :bfirst<CR>
                 Buffer: First
n  <Space>bk     :blast<CR>
                 Buffer: Last
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
n  B             ^
n  E             $
n  K           * <Lua 82: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 LSP: Hover Documentation
n  QQ            :q!<CR>
                 Quickly Quit
x  Q           * mode() == 'V' ? ':normal! @<C-R>=reg_recorded()<CR><CR>' : 'Q'
                 :help v_Q-default
x  S             <Plug>VSurround
n  WW            :w!<CR>
                 Force write
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
n  cS            <Plug>CSurround
n  cs            <Plug>Csurround
n  ds            <Plug>Dsurround
n  dn          * <Lua 81: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Diagnostic: Goto Next
n  dp          * <Lua 80: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Diagnostic: Goto Prev
o  g%            <Plug>(MatchitOperationBackward)
x  g%            <Plug>(MatchitVisualBackward)
n  g%            <Plug>(MatchitNormalBackward)
x  gS            <Plug>VgSurround
n  gP          * <Lua 265: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:132>
                 Close preview windows
n  gpr         * <Lua 264: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:114>
                 Preview references
n  gpD         * <Lua 263: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:105>
                 Preview declaration
n  gpi         * <Lua 262: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:91>
                 Preview implementation
n  gpt         * <Lua 261: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:77>
                 Preview type definition
n  gpd         * <Lua 259: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:63>
                 Preview definition
n  gR          * :RegexplainerToggle<CR>
                 Toggle Regexplainer
n  gd          * <Lua 90: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 LSP: Goto Definition
n  gr          * <Lua 88: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 LSP: Goto References
n  gI          * <Lua 85: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 LSP: Goto Implementation
n  gD          * <Lua 79: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 LSP: Goto Declaration
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
n  j           * v:count == 0 ? 'gj' : 'j'
n  k           * v:count == 0 ? 'gk' : 'k'
n  n           * <Lua 71: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Twilight
n  ss          * :noh<CR>
n  tT          * :TransparentToggle<CR>
                 Toggle Transparency
n  ySS           <Plug>YSsurround
n  ySs           <Plug>YSsurround
n  yss           <Plug>Yssurround
n  yS            <Plug>YSurround
n  ys            <Plug>Ysurround
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
n  <C-Bslash>  * :<C-U>TmuxNavigatePrevious<CR>
n  <C-J>       * :<C-U>TmuxNavigateDown<CR>
n  <C-L>       * :<C-U>TmuxNavigateRight<CR>
n  <C-H>       * :<C-U>TmuxNavigateLeft<CR>
v  <Plug>VgSurround * :<C-U>call <SNR>28_opfunc(visualmode(),visualmode() ==# 'V' ? 0 : 1)<CR>
v  <Plug>VSurround * :<C-U>call <SNR>28_opfunc(visualmode(),visualmode() ==# 'V' ? 1 : 0)<CR>
n  <Plug>YSurround * <SNR>28_opfunc2('setup')
n  <Plug>Ysurround * <SNR>28_opfunc('setup')
n  <Plug>YSsurround * <SNR>28_opfunc2('setup').'_'
n  <Plug>Yssurround * '^'.v:count1.<SNR>28_opfunc('setup').'g_'
n  <Plug>CSurround * :<C-U>call <SNR>28_changesurround(1)<CR>
n  <Plug>Csurround * :<C-U>call <SNR>28_changesurround()<CR>
n  <Plug>Dsurround * :<C-U>call <SNR>28_dosurround(<SNR>28_inputtarget())<CR>
n  <Plug>SurroundRepeat * .
n  <C-P>       * :Files<CR>
                 FZF: search for files starting at current directory.
o  <Plug>(fzf-maps-o) * <C-C>:<C-U>call fzf#vim#maps('o', 0)<CR>
x  <Plug>(fzf-maps-x) * :<C-U>call fzf#vim#maps('x', 0)<CR>
n  <Plug>(fzf-maps-n) * :<C-U>call fzf#vim#maps('n', 0)<CR>
n  <Plug>(fzf-normal) * <Nop>
n  <Plug>(fzf-insert) * i
s  <Plug>luasnip-jump-prev * <Lua 292: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:57>
                 LuaSnip: Jump to the previous node
s  <Plug>luasnip-jump-next * <Lua 291: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:54>
                 LuaSnip: Jump to the next node
s  <Plug>luasnip-prev-choice * <Lua 290: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:51>
                 LuaSnip: Change to the previous choice from the choiceNode
s  <Plug>luasnip-next-choice * <Lua 289: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:48>
                 LuaSnip: Change to the next choice from the choiceNode
s  <Plug>luasnip-expand-snippet * <Lua 288: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:45>
                 LuaSnip: Expand the current snippet
s  <Plug>luasnip-expand-or-jump * <Lua 287: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:42>
                 LuaSnip: Expand or jump in the current snippet
   <Plug>luasnip-expand-repeat * <Lua 285: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:35>
                 LuaSnip: Repeat last node expansion
n  <Plug>luasnip-delete-check * <Lua 283: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:28>
                 LuaSnip: Removes current snippet from jumplist
n  <Plug>PlenaryTestFile * :lua require('plenary.test_harness').test_file(vim.fn.expand("%:p"))<CR>
n  <C-S>       * <Cmd>w<CR>
                 Save file
n  <C-K>       * :<C-U>TmuxNavigateUp<CR>
n  <Down>      * <Cmd>echo "Use j to move!!"<CR>
n  <Up>        * <Cmd>echo "Use k to move!!"<CR>
n  <Right>     * <Cmd>echo "Use l to move!!"<CR>
n  <Left>      * <Cmd>echo "Use h to move!!"<CR>
n  <C-W>.      * :vertical resize +10<CR>
                 V Resize +
n  <C-W>,      * :vertical resize -10<CR>
                 V Resize -
n  <C-W><C-D>    <C-W>d
                 Show diagnostics under the cursor
n  <C-W>d      * <Lua 16: vim/_defaults.lua:0>
                 Show diagnostics under the cursor
```

- Generated on Mon 23 Sep 2024 10:24:56 EEST
