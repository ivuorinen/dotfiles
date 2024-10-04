# nvim keybindings

```txt

n  <Space>/    * <Lua 196: ~/.config/nvim/lua/plugins/telescope.lua:68>
                 [/] Fuzzily search in current buffer]
n  <Space>ht   * <Lua 192: ~/.config/nvim/lua/plugins/harpoon.lua:43>
                 Open Harpoon Quick menu
n  <Space>hw   * <Lua 189: ~/.config/nvim/lua/plugins/harpoon.lua:37>
                 Open harpoon window with telescope
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
x  R           * <Lua 70: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Treesitter Search
o  R           * <Lua 69: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Treesitter Search
n  Y           * y$
                 :help Y-default
o  Zk          * <Lua 67: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Flash Treesitter
x  Zk          * <Lua 66: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Flash Treesitter
n  Zk          * <Lua 59: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Flash Treesitter
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
n  gR          * :RegexplainerToggle<CR>
                 Toggle Regexplainer
o  g%            <Plug>(MatchitOperationBackward)
x  g%            <Plug>(MatchitVisualBackward)
n  g%            <Plug>(MatchitNormalBackward)
n  gP          * <Lua 52: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:132>
                 Close preview windows
n  gpr         * <Lua 25: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:114>
                 Preview references
n  gpD         * <Lua 244: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:105>
                 Preview declaration
n  gpi         * <Lua 242: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:91>
                 Preview implementation
n  gpt         * <Lua 241: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:77>
                 Preview type definition
n  gpd         * <Lua 237: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:63>
                 Preview definition
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
                 Move down
n  k           * v:count == 0 ? 'gk' : 'k'
                 Move up
o  r           * <Lua 68: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Remote Flash
o  zk          * <Lua 65: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Flash
x  zk          * <Lua 64: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Flash
n  zk          * <Lua 63: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Flash
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
s  <Plug>luasnip-jump-prev * <Lua 315: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:57>
                 LuaSnip: Jump to the previous node
s  <Plug>luasnip-jump-next * <Lua 314: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:54>
                 LuaSnip: Jump to the next node
s  <Plug>luasnip-prev-choice * <Lua 313: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:51>
                 LuaSnip: Change to the previous choice from the choiceNode
s  <Plug>luasnip-next-choice * <Lua 312: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:48>
                 LuaSnip: Change to the next choice from the choiceNode
s  <Plug>luasnip-expand-snippet * <Lua 311: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:45>
                 LuaSnip: Expand the current snippet
s  <Plug>luasnip-expand-or-jump * <Lua 310: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:42>
                 LuaSnip: Expand or jump in the current snippet
   <Plug>luasnip-expand-repeat * <Lua 308: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:35>
                 LuaSnip: Repeat last node expansion
n  <Plug>luasnip-delete-check * <Lua 306: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:28>
                 LuaSnip: Removes current snippet from jumplist
n  <Plug>PlenaryTestFile * :lua require('plenary.test_harness').test_file(vim.fn.expand("%:p"))<CR>
n  <C-W><C-D>    <C-W>d
                 Show diagnostics under the cursor
n  <C-W>d      * <Lua 16: vim/_defaults.lua:0>
                 Show diagnostics under the cursor
n  <C-L>       * <Cmd>nohlsearch|diffupdate|normal! <C-L><CR>
                 :help CTRL-L-default
```

- Generated on Fri  4 Oct 2024 14:49:00 EEST
