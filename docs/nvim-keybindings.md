# nvim keybindings

```txt

n  <Space>/    * <Lua 380: ~/.config/nvim/lua/plugins/telescope.lua:82>
                 [/] Fuzzily search in current buffer]
n  <Space>hw   * <Lua 42: ~/.config/nvim/lua/plugins/harpoon.lua:40>
                 Open harpoon window with telescope
n  <Space>1    * <Lua 40: ~/.config/nvim/lua/plugins/harpoon.lua:68>
                 harpoon to file 1
n  <Space>hn   * <Lua 39: ~/.config/nvim/lua/plugins/harpoon.lua:61>
                 harpoon to next file
n  <Space>hp   * <Lua 38: ~/.config/nvim/lua/plugins/harpoon.lua:54>
                 harpoon to previous file
n  <Space>ha   * <Lua 37: ~/.config/nvim/lua/plugins/harpoon.lua:47>
                 harpoon file
n  <Space>5    * <Lua 36: ~/.config/nvim/lua/plugins/harpoon.lua:96>
                 harpoon to file 5
n  <Space>4    * <Lua 35: ~/.config/nvim/lua/plugins/harpoon.lua:89>
                 harpoon to file 4
n  <Space>3    * <Lua 34: ~/.config/nvim/lua/plugins/harpoon.lua:82>
                 harpoon to file 3
n  <Space>2    * <Lua 33: ~/.config/nvim/lua/plugins/harpoon.lua:75>
                 harpoon to file 2
n  <Space>tc   * <Cmd>CloakToggle<CR>
                 [tc] Toggle Cloak
n  <Space>xx   * <Cmd>Trouble<CR>
                 Toggle Trouble
n  <Space>xq   * <Cmd>Trouble quickfix<CR>
                 Toggle Quickfix
n  <Space>xl   * <Cmd>Trouble loclist<CR>
                 Toggle Loclist
n  <Space>xd   * <Cmd>Trouble document_diagnostics<CR>
                 Toggle Document Diagnostics
n  <Space>xw   * <Cmd>Trouble workspace_diagnostics<CR>
                 Toggle Workspace Diagnostics
n  <Space>?s   * <Cmd>Neoconf show<CR>
                 Neoconf: Show merged config
n  <Space>?m   * <Cmd>Neoconf lsp<CR>
                 Neoconf: Show merged LSP config
n  <Space>?l   * <Cmd>Neoconf local<CR>
                 Neoconf: Local
n  <Space>?g   * <Cmd>Neoconf global<CR>
                 Neoconf: Global
n  <Space>?c   * <Cmd>Neoconf<CR>
                 Neoconf: Open
n  <Space>wl   * <Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>
                 LSP: Workspace List Folders
n  <Space>wr   * <Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>
                 LSP: Workspace Remove Folder
n  <Space>wa   * <Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>
                 LSP: Workspace Add Folder
n  <Space>ws   * <Cmd>lua require("telescope.builtin").lsp_dynamic_workspace_symbols()<CR>
                 LSP: Workspace Symbols
n  <Space>ds   * <Cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>
                 LSP: Document Symbols
n  <Space>D    * <Cmd>lua vim.lsp.buf.type_definition()<CR>
                 LSP: Type Definition
n  <Space>ca   * <Cmd>lua vim.lsp.buf.code_action()<CR>
                 LSP: Code Action
n  <Space>cr   * <Cmd>lua vim.lsp.buf.rename()<CR>
                 LSP: Rename
n  <Space>dq   * <Cmd>lua vim.diagnostic.setloclist()<CR>
                 Diagnostic: Set loc list
n  <Space>do   * <Cmd>lua vim.diagnostic.open_float()<CR>
                 Diagnostic: Open float
   <Space>cf   * <Lua 107: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 [f] Format buffer
n  <Space>e    * <Lua 81: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 NeoTree reveal
n  <Space>cg   * <Lua 50: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Generate annotations
n  <Space>zm   * <Lua 49: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 FZF: search mappings.
n  <Space>zh   * <Lua 48: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 FZF: search history of opened files
n  <Space>zb   * <Lua 47: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 FZF: search open buffers.
n  <Space>zt   * <Lua 46: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 FZF: search open tabs.
n  <Space>zc   * <Lua 32: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 FZF: search commands.
n  <Space>zf   * <Lua 31: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 FZF: search for files in given path.
n  <Space>zg   * <Lua 25: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 FZF: search with rg (aka live grep).
n  <Space>dc   * <Lua 45: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 DAP: Continue
n  <Space>db   * <Lua 44: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 DAP: Toggle Breakpoint
n  <Space>dt   * <Lua 43: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 DAP: Toggle UI
n  <Space>ht   * <Lua 369: ~/.config/nvim/lua/plugins/harpoon.lua:16>
                 Open Harpoon Quick menu
n  <Space>dr   * <Lua 41: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 DAP: Reset
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
n  K           * <Cmd>lua vim.lsp.buf.hover()<CR>
                 LSP: Hover Documentation
x  Q           * mode() == 'V' ? ':normal! @<C-R>=reg_recorded()<CR><CR>' : 'Q'
                 :help v_Q-default
x  S             <Plug>VSurround
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
n  dp          * <Cmd>lua vim.diagnostic.goto_prev()<CR>
                 Diagnostic: Goto Prev
n  dn          * <Cmd>lua vim.diagnostic.goto_next()<CR>
                 Diagnostic: Goto Next
o  g%            <Plug>(MatchitOperationBackward)
x  g%            <Plug>(MatchitVisualBackward)
n  g%            <Plug>(MatchitNormalBackward)
x  gS            <Plug>VgSurround
n  gR          * :RegexplainerToggle<CR>
                 Toggle Regexplainer
n  gD          * <Cmd>lua vim.lsp.buf.declaration()<CR>
                 LSP: Goto Declaration
n  gd          * <Cmd>lua vim.lsp.buf.definition()<CR>
                 LSP: Goto Definition
n  gr          * <Cmd>lua require("telescope.builtin").lsp_references()<CR>
                 LSP: Goto References
n  gI          * <Cmd>lua vim.lsp.buf.implementation()<CR>
                 LSP: Goto Implementation
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
n  n           * <Lua 51: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 Twilight
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
v  <Plug>VgSurround * :<C-U>call <SNR>27_opfunc(visualmode(),visualmode() ==# 'V' ? 0 : 1)<CR>
v  <Plug>VSurround * :<C-U>call <SNR>27_opfunc(visualmode(),visualmode() ==# 'V' ? 1 : 0)<CR>
n  <Plug>YSurround * <SNR>27_opfunc2('setup')
n  <Plug>Ysurround * <SNR>27_opfunc('setup')
n  <Plug>YSsurround * <SNR>27_opfunc2('setup').'_'
n  <Plug>Yssurround * '^'.v:count1.<SNR>27_opfunc('setup').'g_'
n  <Plug>CSurround * :<C-U>call <SNR>27_changesurround(1)<CR>
n  <Plug>Csurround * :<C-U>call <SNR>27_changesurround()<CR>
n  <Plug>Dsurround * :<C-U>call <SNR>27_dosurround(<SNR>27_inputtarget())<CR>
n  <Plug>SurroundRepeat * .
n  <C-L>       * :<C-U>TmuxNavigateRight<CR>
n  <C-Bslash>  * :<C-U>TmuxNavigatePrevious<CR>
n  <C-J>       * :<C-U>TmuxNavigateDown<CR>
n  <C-H>       * :<C-U>TmuxNavigateLeft<CR>
n  <C-K>       * :<C-U>TmuxNavigateUp<CR>
s  <Plug>luasnip-jump-prev * <Lua 283: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:57>
                 LuaSnip: Jump to the previous node
s  <Plug>luasnip-jump-next * <Lua 282: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:54>
                 LuaSnip: Jump to the next node
s  <Plug>luasnip-prev-choice * <Lua 281: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:51>
                 LuaSnip: Change to the previous choice from the choiceNode
s  <Plug>luasnip-next-choice * <Lua 280: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:48>
                 LuaSnip: Change to the next choice from the choiceNode
s  <Plug>luasnip-expand-snippet * <Lua 279: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:45>
                 LuaSnip: Expand the current snippet
s  <Plug>luasnip-expand-or-jump * <Lua 278: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:42>
                 LuaSnip: Expand or jump in the current snippet
   <Plug>luasnip-expand-repeat * <Lua 276: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:35>
                 LuaSnip: Repeat last node expansion
n  <Plug>luasnip-delete-check * <Lua 274: ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua:28>
                 LuaSnip: Removes current snippet from jumplist
n  <Plug>PlenaryTestFile * :lua require('plenary.test_harness').test_file(vim.fn.expand("%:p"))<CR>
n  <C-P>       * <Lua 26: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:121>
                 FZF: search for files starting at current directory.
n  <C-W><C-D>    <C-W>d
                 Show diagnostics under the cursor
n  <C-W>d      * <Lua 16: vim/_defaults.lua:0>
                 Show diagnostics under the cursor
```

- Generated on Wed 25 Sep 2024 14:52:25 EEST
