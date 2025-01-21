# nvim keybindings

```txt

x  <Space>     *@~/.local/share/nvim/lazy/mini.nvim/lua/mini/clue.lua
                 Query keys after "<Space>"
n  <Space>     *@~/.local/share/nvim/lazy/mini.nvim/lua/mini/clue.lua
                 Query keys after "<Space>"
x  "           *@~/.local/share/nvim/lazy/mini.nvim/lua/mini/clue.lua
                 Query keys after """
n  "           *@~/.local/share/nvim/lazy/mini.nvim/lua/mini/clue.lua
                 Query keys after """
x  '           *@~/.local/share/nvim/lazy/mini.nvim/lua/mini/clue.lua
                 Query keys after "'"
n  '           *@~/.local/share/nvim/lazy/mini.nvim/lua/mini/clue.lua
                 Query keys after "'"
x  `           *@~/.local/share/nvim/lazy/mini.nvim/lua/mini/clue.lua
                 Query keys after "`"
n  `           *@~/.local/share/nvim/lazy/mini.nvim/lua/mini/clue.lua
                 Query keys after "`"
x  g           *@~/.local/share/nvim/lazy/mini.nvim/lua/mini/clue.lua
                 Query keys after "g"
n  g           *@~/.local/share/nvim/lazy/mini.nvim/lua/mini/clue.lua
                 Query keys after "g"
x  z           *@~/.local/share/nvim/lazy/mini.nvim/lua/mini/clue.lua
                 Query keys after "z"
n  z           *@~/.local/share/nvim/lazy/mini.nvim/lua/mini/clue.lua
                 Query keys after "z"
n  <C-W>       *@~/.local/share/nvim/lazy/mini.nvim/lua/mini/clue.lua
                 Query keys after "<C-W>"
n  <Esc><Esc>  * :nohlsearch<CR>
                 Clear Search Highlighting
n  <Space>qQ   * ~/.config/nvim/lua/keymaps.lua
                 Force quit without saving
n  <Space>qw   * :wq<CR>
                 Write and quit
n  <Space>qq   * ~/.config/nvim/lua/keymaps.lua
                 Quit with force saving
n  <Space>qf   * :q<CR>
                 Quicker close split
n  <Space>tn   * :Noice dismiss<CR>
                 Noice: Dismiss Notification
n  <Space>tl   * ~/.config/nvim/lua/utils.lua
                 Toggle Light/Dark Mode
n  <Space>te   * :Neotree toggle<CR>
                 Toggle Neotree
n  <Space>tc   * :CloakToggle<CR>
                 Cloak: Toggle
n  <Space>xx   * :Trouble diagnostics<CR>
                 Diagnostic
n  <Space>xw   * :Trouble workspace_diagnostics<CR>
                 Workspace Diagnostics
n  <Space>xq   * :Trouble quickfix<CR>
                 Quickfix
n  <Space>xl   * :Trouble loclist<CR>
                 Location List
n  <Space>xd   * :Trouble diagnostics<CR>
                 Document Diagnostics
n  <Space>sx   * :Telescope import<CR>
                 Telescope: Import
n  <Space>sw   * :Telescope grep_string<CR>
                 Grep String
n  <Space>ss   * :Telescope treesitter<CR>
                 Treesitter
n  <Space>sq   * :Telescope quickfix<CR>
                 Quickfix
n  <Space>sp   * ~/.config/nvim/lua/keymaps.lua
                 Lazy Plugins
n  <Space>so   * :Telescope oldfiles<CR>
                 Old Files
n  <Space>sl   * :Telescope luasnip<CR>
                 Search LuaSnip
n  <Space>sk   * :Telescope keymaps<CR>
                 Search Keymaps
n  <Space>sh   * :Telescope help_tags<CR>
                 Help tags
n  <Space>sg   * :Telescope live_grep<CR>
                 Search by Grep
n  <Space>sd   * :Telescope diagnostics<CR>
                 Search Diagnostics
n  <Space>sc   * :Telescope commands<CR>
                 Commands
n  <Space>/    * ~/.config/nvim/lua/keymaps.lua
                 Fuzzily search in current buffer
n  <Space>,    * :Telescope buffers<CR>
                 Find existing buffers
n  <Space>f    * :Telescope fd --hidden=true<CR>
                 Find Files
n  <Space>cbt  * <Cmd>CBllline<CR>
                 CB: Titled Line
n  <Space>cbm  * <Cmd>CBllbox14<CR>
                 CB: Marked
n  <Space>cbl  * <Cmd>CBline<CR>
                 CB: Simple Line
n  <Space>cbd  * <Cmd>CBd<CR>
                 CB: Remove a box
n  <Space>cbb  * <Cmd>CBccbox<CR>
                 CB: Box Title
n  <Space>cwd  * ~/.config/nvim/lua/keymaps.lua
                 Dynamic Workspace Symbols
n  <Space>cws  * ~/.config/nvim/lua/keymaps.lua
                 Workspace Symbols
n  <Space>ct   * ~/.config/nvim/lua/keymaps.lua
                 treesitter
n  <Space>cs   * :Telescope lsp_document_symbols<CR>
                 LSP Document Symbols
n  <Space>cr   * ~/.local/share/bob/v0.10.2/nvim-macos-arm64/share/nvim/runtime/lua/vim/lsp/buf.lua
                 Rename
n  <Space>cp   * ~/.config/nvim/lua/keymaps.lua
                 Type Definition
n  <Space>ci   * ~/.config/nvim/lua/keymaps.lua
                 Implementations
n  <Space>cg   * :lua require("neogen").generate()<CR>
                 Generate annotations
x  <Space>cf   * :lua vim.lsp.buf.format()<CR>
                 Format
n  <Space>cf   * :lua vim.lsp.buf.format()<CR>
                 Format
n  <Space>cd   * ~/.config/nvim/lua/keymaps.lua
                 Definitions
n  <Space>cco  * ~/.config/nvim/lua/keymaps.lua
                 Outgoing calls
n  <Space>cci  * ~/.config/nvim/lua/keymaps.lua
                 Incoming calls
n  <Space>ca   * :lua vim.lsp.buf.code_action()<CR>
                 Code Action
n  <Space>bw   * :lua MiniBufremove.wipeout()<CR>
                 Wipeout
n  <Space>bl   * :bnext<CR>
                 Next
n  <Space>bk   * :blast<CR>
                 Last
n  <Space>bj   * :bfirst<CR>
                 First
n  <Space>bh   * :bprev<CR>
                 Prev
n  <Space>bd   * :lua MiniBufremove.delete()<CR>
                 Delete
n  <Space>ba   * :%bd|e#|bd#<CR>
                 Close all except current
n  <Space>apt  * :PhpactorTransform<CR>
                 PHPactor: Transform
n  <Space>aps  * :PhpactorClassSearch<CR>
                 PHPactor: Class Search
n  <Space>apn  * :PhpactorClassNew<CR>
                 PHPactor: Class New
n  <Space>apm  * :PhpactorContextMenu<CR>
                 PHPactor: Context Menu
n  <Space>av   * :silent TestVisit<CR>
                 Test Visit
n  <Space>al   * :silent TestLast<CR>
                 Test Last
n  <Space>as   * :silent TestSuite<CR>
                 Test Suite
n  <Space>af   * :silent TestFile<CR>
                 Test File
n  <Space>an   * :silent TestNearest<CR>
                 Test Nearest
n  <Space>o    * ~/.config/nvim/lua/keymaps.lua
                 Open repo in browser
n  <Space>tmw  * <Cmd>setlocal wrap! wrap?<CR>
                 Toggle 'wrap'
n  <Space>tms  * <Cmd>setlocal spell! spell?<CR>
                 Toggle 'spell'
n  <Space>tmr  * <Cmd>setlocal relativenumber! relativenumber?<CR>
                 Toggle 'relativenumber'
n  <Space>tmn  * <Cmd>setlocal number! number?<CR>
                 Toggle 'number'
n  <Space>tml  * <Cmd>setlocal list! list?<CR>
                 Toggle 'list'
n  <Space>tmi  * <Cmd>setlocal ignorecase! ignorecase?<CR>
                 Toggle 'ignorecase'
n  <Space>tmh  * <Cmd>let v:hlsearch = 1 - v:hlsearch | echo (v:hlsearch ? "  " : "no") . "hlsearch"<CR>
                 Toggle search highlight
n  <Space>tmd  * <Cmd>lua print(MiniBasics.toggle_diagnostic())<CR>
                 Toggle diagnostic
n  <Space>tmC  * <Cmd>setlocal cursorcolumn! cursorcolumn?<CR>
                 Toggle 'cursorcolumn'
n  <Space>tmc  * <Cmd>setlocal cursorline! cursorline?<CR>
                 Toggle 'cursorline'
n  <Space>tmb  * <Cmd>lua vim.o.bg = vim.o.bg == "dark" and "light" or "dark"; print(vim.o.bg)<CR>
                 Toggle 'background'
os <Space>cf   * ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua
                 Format buffer
x  #           * vim/_defaults.lua
                 :help v_#-default
o  %             <Plug>(MatchitOperationForward)
x  %             <Plug>(MatchitVisualForward)
n  %             <Plug>(MatchitNormalForward)
n  &           * :&&<CR>
                 :help &-default
n  '?          & :<C-U>echo ":Start" dispatch#start_focus(v:count > 1 ? 0 : v:count ? line(".") : -1)<CR>
n  '!          & <SNR>10_:.Start!
n  '<Space>    & <SNR>10_:.Start<Space>
n  '<CR>       & <SNR>10_:.Start<CR>
x  *           * vim/_defaults.lua
                 :help v_star-default
v  <           * <gv
                 Indent Left
n  <           * <gv
                 Indent Left
v  >           * >gv
                 Indent Right
n  >           * >gv
                 Indent Right
n  @           * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/clue.lua
                 Execute macro without 'mini.clue' triggers
x  @           * mode() ==# 'V' ? ':normal! @'.getcharstr().'<CR>' : '@'
                 :help v_@-default
n  K           * :lua vim.lsp.buf.hover()<CR>
                 Hover Documentation
n  Q           * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/clue.lua
                 Execute macro without 'mini.clue' triggers
x  Q           * mode() ==# 'V' ? ':normal! @<C-R>=reg_recorded()<CR><CR>' : 'Q'
                 :help v_Q-default
n  Y           * y$
                 :help Y-default
o  Zk          * ~/.config/nvim/lua/keymaps.lua
                 Flash Treesitter
x  Zk          * ~/.config/nvim/lua/keymaps.lua
                 Flash Treesitter
n  Zk          * ~/.config/nvim/lua/keymaps.lua
                 Flash Treesitter
o  [%            <Plug>(MatchitOperationMultiBackward)
x  [%            <Plug>(MatchitVisualMultiBackward)
n  [%            <Plug>(MatchitNormalMultiBackward)
o  [i          * <Cmd>lua MiniIndentscope.operator('top')<CR>
                 Go to indent scope top
x  [i          * <Cmd>lua MiniIndentscope.operator('top')<CR>
                 Go to indent scope top
n  [i          * <Cmd>lua MiniIndentscope.operator('top', true)<CR>
                 Go to indent scope top
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
n  [d          * vim/_defaults.lua
                 Jump to the previous diagnostic
o  ]%            <Plug>(MatchitOperationMultiForward)
x  ]%            <Plug>(MatchitVisualMultiForward)
n  ]%            <Plug>(MatchitNormalMultiForward)
o  ]i          * <Cmd>lua MiniIndentscope.operator('bottom')<CR>
                 Go to indent scope bottom
x  ]i          * <Cmd>lua MiniIndentscope.operator('bottom')<CR>
                 Go to indent scope bottom
n  ]i          * <Cmd>lua MiniIndentscope.operator('bottom', true)<CR>
                 Go to indent scope bottom
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
n  ]d          * vim/_defaults.lua
                 Jump to the next diagnostic
n  `?          & <SNR>10_:.FocusDispatch<CR>
n  `!          & <SNR>10_:.Dispatch!
n  `<Space>    & <SNR>10_:.Dispatch<Space>
n  `<CR>       & <SNR>10_:.Dispatch<CR>
x  a%            <Plug>(MatchitVisualTextObject)
o  ax            <Plug>(textobj-xmlattr-attr-a)
x  ax            <Plug>(textobj-xmlattr-attr-a)
o  ai          * <Cmd>lua MiniIndentscope.textobject(true)<CR>
                 Object scope with border
x  ai          * <Cmd>lua MiniIndentscope.textobject(true)<CR>
                 Object scope with border
n  gR          * :RegexplainerToggle<CR>
                 Toggle Regexplainer
o  g%            <Plug>(MatchitOperationBackward)
x  g%            <Plug>(MatchitVisualBackward)
n  g%            <Plug>(MatchitNormalBackward)
n  g`?         & :<C-U>echo ":Spawn" dispatch#spawn_focus(v:count > 1 ? 0 : v:count ? line(".") : -1)<CR>
n  g`!         & <SNR>10_:.Spawn!
n  g`<Space>   & <SNR>10_:.Spawn<Space>
n  g`<CR>      & <SNR>10_:.Spawn<CR>
n  g'?         & :<C-U>echo ":Spawn" dispatch#spawn_focus(v:count > 1 ? 0 : v:count ? line(".") : -1)<CR>
n  g'!         & <SNR>10_:.Spawn!
n  g'<Space>   & <SNR>10_:.Spawn<Space>
n  g'<CR>      & <SNR>10_:.Spawn<CR>
x  gS          * :<C-U>lua MiniSplitjoin.toggle({ region = MiniSplitjoin.get_visual_region() })<CR>
                 Toggle arguments
n  gS          * v:lua.MiniSplitjoin.operator("toggle") . " "
                 Toggle arguments
x  gs          * <Cmd>lua MiniOperators.sort('visual')<CR>
                 Sort selection
n  gss           ^gsg_
                 Sort line
n  gs          * v:lua.MiniOperators.sort()
                 Sort operator
x  gr          * <Cmd>lua MiniOperators.replace('visual')<CR>
                 Replace selection
n  grr           gr_
                 Replace line
n  gr          * v:lua.MiniOperators.replace()
                 Replace operator
x  gm          * <Cmd>lua MiniOperators.multiply('visual')<CR>
                 Multiply selection
n  gmm           gm_
                 Multiply line
n  gm          * v:lua.MiniOperators.multiply()
                 Multiply operator
n  gxx           gx_
                 Exchange line
x  g=          * <Cmd>lua MiniOperators.evaluate('visual')<CR>
                 Evaluate selection
n  g==           g=_
                 Evaluate line
n  g=          * v:lua.MiniOperators.evaluate()
                 Evaluate operator
o  gh          * <Cmd>lua MiniDiff.textobject()<CR>
                 Hunk range textobject
x  gH          * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/diff.lua
                 Reset hunks
n  gH          * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/diff.lua
                 Reset hunks
x  gh          * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/diff.lua
                 Apply hunks
n  gh          * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/diff.lua
                 Apply hunks
x  g/          * <Esc>/\%V
                 Search inside visual selection
n  gV          * "`[" . strpart(getregtype(), 0, 1) . "`]"
                 Visually select changed text
x  gp          * "+P
                 Paste from system clipboard
n  gp          * "+p
                 Paste from system clipboard
x  gy          * "+y
                 Copy to system clipboard
n  gy          * "+y
                 Copy to system clipboard
n  go          * v:lua.MiniBasics.put_empty_line(v:false)
                 Put empty line below
n  gO          * v:lua.MiniBasics.put_empty_line(v:true)
                 Put empty line above
o  gc          * <Cmd>lua MiniComment.textobject()<CR>
                 Comment textobject
n  gcc         * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/comment.lua
                 Comment line
x  gc          * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/comment.lua
                 Comment selection
n  gc          * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/comment.lua
                 Comment
x  gx          * <Cmd>lua MiniOperators.exchange('visual')<CR>
                 Exchange selection
n  gx          * v:lua.MiniOperators.exchange()
                 Exchange operator
o  ix            <Plug>(textobj-xmlattr-attr-i)
x  ix            <Plug>(textobj-xmlattr-attr-i)
o  ii          * <Cmd>lua MiniIndentscope.textobject(false)<CR>
                 Object scope
x  ii          * <Cmd>lua MiniIndentscope.textobject(false)<CR>
                 Object scope
x  j           * v:count == 0 ? 'gj' : 'j'
n  j           * v:count == 0 ? 'gj' : 'j'
                 Move down
x  k           * v:count == 0 ? 'gk' : 'k'
n  k           * v:count == 0 ? 'gk' : 'k'
                 Move up
n  m?          & :<C-U>echo ":Dispatch" dispatch#make_focus(v:count > 1 ? 0 : v:count ? line(".") : -1)<CR>
n  m!          & <SNR>10_:.Make!
n  m<Space>    & <SNR>10_:.Make<Space>
n  m<CR>       & <SNR>10_:.Make<CR>
n  shn         * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/surround.lua
                 Highlight next surrounding
n  sFn         * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/surround.lua
                 Find next left surrounding
n  sfn         * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/surround.lua
                 Find next right surrounding
n  srn         * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/surround.lua
                 Replace next surrounding
n  sdn         * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/surround.lua
                 Delete next surrounding
n  shl         * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/surround.lua
                 Highlight previous surrounding
n  sFl         * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/surround.lua
                 Find previous left surrounding
n  sfl         * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/surround.lua
                 Find previous right surrounding
n  srl         * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/surround.lua
                 Replace previous surrounding
n  sdl         * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/surround.lua
                 Delete previous surrounding
x  sa          * :<C-U>lua MiniSurround.add('visual')<CR>
                 Add surrounding to selection
n  sn          * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/surround.lua
                 Update `MiniSurround.config.n_lines`
n  sh          * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/surround.lua
                 Highlight surrounding
n  sF          * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/surround.lua
                 Find left surrounding
n  sf          * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/surround.lua
                 Find right surrounding
n  sr          * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/surround.lua
                 Replace surrounding
n  sd          * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/surround.lua
                 Delete surrounding
n  sa          * ~/.local/share/nvim/lazy/mini.nvim/lua/mini/surround.lua
                 Add surrounding
o  zk          * ~/.config/nvim/lua/keymaps.lua
                 Flash
x  zk          * ~/.config/nvim/lua/keymaps.lua
                 Flash
n  zk          * ~/.config/nvim/lua/keymaps.lua
                 Flash
n  <F1>        * :FloatermToggle<CR>
                 Toggle Floaterm
v  <C-J>       * :m '>+1<CR>gv=gv
                 Move Block Down
n  <C-J>       * :m '>+1<CR>gv=gv
                 Move Block Down
v  <C-K>       * :m '<-2<CR>gv=gv
                 Move Block Up
n  <C-K>       * :m '<-2<CR>gv=gv
                 Move Block Up
n  <C-W>=      * <C-W>=
                 Equal Size Splits
n  <C-W>+      * :resize +10<CR>
                 H Resize +
n  <C-W>-      * :resize -10<CR>
                 H Resize -
n  <C-W>.      * :vertical resize +10<CR>
                 V Resize +
n  <C-W>,      * :vertical resize -10<CR>
                 V Resize -
n  <Down>      * :echo "Use j to move!!"<CR>
                 ?
n  <Up>        * :echo "Use k to move!!"<CR>
                 ?
n  <Right>     * :echo "Use l to move!!"<CR>
                 ?
n  <Left>      * :echo "Use h to move!!"<CR>
                 ?
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
s  <Plug>luasnip-jump-prev * ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua
                 LuaSnip: Jump to the previous node
s  <Plug>luasnip-jump-next * ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua
                 LuaSnip: Jump to the next node
s  <Plug>luasnip-prev-choice * ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua
                 LuaSnip: Change to the previous choice from the choiceNode
s  <Plug>luasnip-next-choice * ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua
                 LuaSnip: Change to the next choice from the choiceNode
s  <Plug>luasnip-expand-snippet * ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua
                 LuaSnip: Expand the current snippet
s  <Plug>luasnip-expand-or-jump * ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua
                 LuaSnip: Expand or jump in the current snippet
   <Plug>luasnip-expand-repeat * ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua
                 LuaSnip: Repeat last node expansion
n  <Plug>luasnip-delete-check * ~/.local/share/nvim/lazy/LuaSnip/plugin/luasnip.lua
                 LuaSnip: Removes current snippet from jumplist
n  <Plug>PlenaryTestFile * :lua require('plenary.test_harness').test_file(vim.fn.expand("%:p"))<CR>
o  <Plug>(textobj-xmlattr-attr-i) & <SNR>14_(save-cursor-pos):<C-U>call g:__textobj_xmlattr.do_by_pattern("select","attr-i","o")<CR>
v  <Plug>(textobj-xmlattr-attr-i) & <SNR>14_(save-cursor-pos):<C-U>call g:__textobj_xmlattr.do_by_pattern("select","attr-i","v")<CR>
o  <Plug>(textobj-xmlattr-attr-a) & <SNR>14_(save-cursor-pos):<C-U>call g:__textobj_xmlattr.do_by_pattern("select","attr-a","o")<CR>
v  <Plug>(textobj-xmlattr-attr-a) & <SNR>14_(save-cursor-pos):<C-U>call g:__textobj_xmlattr.do_by_pattern("select","attr-a","v")<CR>
n  <SNR>14_    * <SNR>14_
   <SNR>14_(save-cursor-pos) * <SNR>14_save_cursor_pos()
n  <SNR>10_:.  & :<C-R>=getcmdline() =~ ',' ? "\0250" : ""<CR>
x  <C-S>       * <Esc><Cmd>silent! update | redraw<CR>
                 Save and go to Normal mode
n  <C-S>       * :w!<CR>
                 Save
n  <C-W><C-D>    <C-W>d
                 Show diagnostics under the cursor
n  <C-W>d      * vim/_defaults.lua
                 Show diagnostics under the cursor
n  <C-L>       * :lua vim.lsp.buf.signature_help()<CR>
                 Signature
```

- Generated on Tue 21 Jan 2025 15:03:23 EET
