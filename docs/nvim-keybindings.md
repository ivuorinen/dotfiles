# nvim keybindings

```txt

n  <Space>/    * <Lua 398: ~/.config/nvim/lua/plugins/telescope.lua:95>
                 [/] Fuzzily search in current buffer]
n  <Space>ht   * <Lua 393: ~/.config/nvim/lua/plugins/harpoon.lua:43>
                 Open Harpoon Quick menu
n  <Space>hw   * <Lua 390: ~/.config/nvim/lua/plugins/harpoon.lua:37>
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
o  R           * <Lua 102: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Treesitter Search
x  R           * <Lua 99: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Treesitter Search
n  Y           * y$
                 :help Y-default
n  Zk          * <Lua 98: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Flash Treesitter
o  Zk          * <Lua 96: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Flash Treesitter
x  Zk          * <Lua 95: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Flash Treesitter
o  [%            <Plug>(MatchitOperationMultiBackward)
x  [%            <Plug>(MatchitVisualMultiBackward)
n  [%            <Plug>(MatchitNormalMultiBackward)
o  [h          * V<Cmd>lua MiniDiff.goto_hunk('prev')<CR>
                 Previous hunk
x  [h          * <Cmd>lua MiniDiff.goto_hunk('prev')<CR>
                 Previous hunk
n  [h          * <Cmd>lua MiniDiff.goto_hunk('prev')<CR>
                 Previous hunk
o  [H          * V<Cmd>lua MiniDiff.goto_hunk('first')<CR>
                 First hunk
x  [H          * <Cmd>lua MiniDiff.goto_hunk('first')<CR>
                 First hunk
n  [H          * <Cmd>lua MiniDiff.goto_hunk('first')<CR>
                 First hunk
o  [i          * <Cmd>lua MiniIndentscope.operator('top')<CR>
                 Go to indent scope top
x  [i          * <Cmd>lua MiniIndentscope.operator('top')<CR>
                 Go to indent scope top
n  [i          * <Cmd>lua MiniIndentscope.operator('top', true)<CR>
                 Go to indent scope top
n  [d          * <Lua 15: vim/_defaults.lua:0>
                 Jump to the previous diagnostic
o  ]%            <Plug>(MatchitOperationMultiForward)
x  ]%            <Plug>(MatchitVisualMultiForward)
n  ]%            <Plug>(MatchitNormalMultiForward)
o  ]H          * V<Cmd>lua MiniDiff.goto_hunk('last')<CR>
                 Last hunk
x  ]H          * <Cmd>lua MiniDiff.goto_hunk('last')<CR>
                 Last hunk
n  ]H          * <Cmd>lua MiniDiff.goto_hunk('last')<CR>
                 Last hunk
o  ]h          * V<Cmd>lua MiniDiff.goto_hunk('next')<CR>
                 Next hunk
x  ]h          * <Cmd>lua MiniDiff.goto_hunk('next')<CR>
                 Next hunk
n  ]h          * <Cmd>lua MiniDiff.goto_hunk('next')<CR>
                 Next hunk
o  ]i          * <Cmd>lua MiniIndentscope.operator('bottom')<CR>
                 Go to indent scope bottom
x  ]i          * <Cmd>lua MiniIndentscope.operator('bottom')<CR>
                 Go to indent scope bottom
n  ]i          * <Cmd>lua MiniIndentscope.operator('bottom', true)<CR>
                 Go to indent scope bottom
n  ]d          * <Lua 14: vim/_defaults.lua:0>
                 Jump to the next diagnostic
x  a%            <Plug>(MatchitVisualTextObject)
o  ai          * <Cmd>lua MiniIndentscope.textobject(true)<CR>
                 Object scope with border
x  ai          * <Cmd>lua MiniIndentscope.textobject(true)<CR>
                 Object scope with border
n  gR          * :RegexplainerToggle<CR>
                 Toggle Regexplainer
o  g%            <Plug>(MatchitOperationBackward)
x  g%            <Plug>(MatchitVisualBackward)
n  g%            <Plug>(MatchitNormalBackward)
n  gP          * <Lua 454: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:132>
                 Close preview windows
n  gpr         * <Lua 453: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:114>
                 Preview references
n  gpD         * <Lua 452: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:105>
                 Preview declaration
n  gpi         * <Lua 451: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:91>
                 Preview implementation
n  gpt         * <Lua 450: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:77>
                 Preview type definition
n  gpd         * <Lua 449: ~/.local/share/nvim/lazy/goto-preview/lua/goto-preview.lua:63>
                 Preview definition
x  gS          * :<C-U>lua MiniSplitjoin.toggle({ region = MiniSplitjoin.get_visual_region() })<CR>
                 Toggle arguments
n  gS          * v:lua.MiniSplitjoin.operator("toggle") . " "
                 Toggle arguments
o  gh          * <Cmd>lua MiniDiff.textobject()<CR>
                 Hunk range textobject
x  gH          * <Lua 417: ~/.local/share/nvim/lazy/mini.diff/lua/mini/diff.lua:960>
                 Reset hunks
n  gH          * <Lua 416: ~/.local/share/nvim/lazy/mini.diff/lua/mini/diff.lua:960>
                 Reset hunks
x  gh          * <Lua 415: ~/.local/share/nvim/lazy/mini.diff/lua/mini/diff.lua:958>
                 Apply hunks
n  gh          * <Lua 414: ~/.local/share/nvim/lazy/mini.diff/lua/mini/diff.lua:958>
                 Apply hunks
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
o  ii          * <Cmd>lua MiniIndentscope.textobject(false)<CR>
                 Object scope
x  ii          * <Cmd>lua MiniIndentscope.textobject(false)<CR>
                 Object scope
n  j           * v:count == 0 ? 'gj' : 'j'
                 Move down
n  k           * v:count == 0 ? 'gk' : 'k'
                 Move up
o  r           * <Lua 97: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Remote Flash
n  shn         * <Lua 547: ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua:1260>
                 Highlight next surrounding
n  sFn         * <Lua 546: ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua:1260>
                 Find next left surrounding
n  sfn         * <Lua 545: ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua:1260>
                 Find next right surrounding
n  srn         * <Lua 544: ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua:1260>
                 Replace next surrounding
n  sdn         * <Lua 543: ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua:1260>
                 Delete next surrounding
n  shl         * <Lua 542: ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua:1260>
                 Highlight previous surrounding
n  sFl         * <Lua 541: ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua:1260>
                 Find previous left surrounding
n  sfl         * <Lua 540: ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua:1260>
                 Find previous right surrounding
n  srl         * <Lua 539: ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua:1260>
                 Replace previous surrounding
n  sdl         * <Lua 538: ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua:1260>
                 Delete previous surrounding
x  sa          * :<C-U>lua MiniSurround.add('visual')<CR>
                 Add surrounding to selection
n  sn          * <Lua 537: ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua:895>
                 Update `MiniSurround.config.n_lines`
n  sh          * <Lua 536: ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua:1260>
                 Highlight surrounding
n  sF          * <Lua 535: ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua:1260>
                 Find left surrounding
n  sf          * <Lua 534: ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua:1260>
                 Find right surrounding
n  sr          * <Lua 533: ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua:1260>
                 Replace surrounding
n  sd          * <Lua 532: ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua:1260>
                 Delete surrounding
n  sa          * <Lua 531: ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua:1260>
                 Add surrounding
n  zk          * <Lua 100: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Flash
o  zk          * <Lua 94: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Flash
x  zk          * <Lua 92: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
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
s  <Plug>luasnip-jump-prev * <Lua 345: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:57>
                 LuaSnip: Jump to the previous node
s  <Plug>luasnip-jump-next * <Lua 344: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:54>
                 LuaSnip: Jump to the next node
s  <Plug>luasnip-prev-choice * <Lua 343: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:51>
                 LuaSnip: Change to the previous choice from the choiceNode
s  <Plug>luasnip-next-choice * <Lua 342: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:48>
                 LuaSnip: Change to the next choice from the choiceNode
s  <Plug>luasnip-expand-snippet * <Lua 341: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:45>
                 LuaSnip: Expand the current snippet
s  <Plug>luasnip-expand-or-jump * <Lua 340: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:42>
                 LuaSnip: Expand or jump in the current snippet
   <Plug>luasnip-expand-repeat * <Lua 338: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:35>
                 LuaSnip: Repeat last node expansion
n  <Plug>luasnip-delete-check * <Lua 336: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:28>
                 LuaSnip: Removes current snippet from jumplist
n  <Plug>PlenaryTestFile * :lua require('plenary.test_harness').test_file(vim.fn.expand("%:p"))<CR>
n  <C-W><C-D>    <C-W>d
                 Show diagnostics under the cursor
n  <C-W>d      * <Lua 16: vim/_defaults.lua:0>
                 Show diagnostics under the cursor
n  <C-L>       * <Cmd>nohlsearch|diffupdate|normal! <C-L><CR>
                 :help CTRL-L-default
```

- Generated on Fri 22 Nov 2024 15:30:39 EET
