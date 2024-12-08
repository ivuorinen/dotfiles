# nvim keybindings

```txt

x  <Space>     *@~/.local/share/nvim/lazy/mini.clue/lua/mini/clue.lua
                 Query keys after "<Space>"
n  <Space>     *@~/.local/share/nvim/lazy/mini.clue/lua/mini/clue.lua
                 Query keys after "<Space>"
x  "           *@~/.local/share/nvim/lazy/mini.clue/lua/mini/clue.lua
                 Query keys after """
n  "           *@~/.local/share/nvim/lazy/mini.clue/lua/mini/clue.lua
                 Query keys after """
x  '           *@~/.local/share/nvim/lazy/mini.clue/lua/mini/clue.lua
                 Query keys after "'"
n  '           *@~/.local/share/nvim/lazy/mini.clue/lua/mini/clue.lua
                 Query keys after "'"
x  `           *@~/.local/share/nvim/lazy/mini.clue/lua/mini/clue.lua
                 Query keys after "`"
n  `           *@~/.local/share/nvim/lazy/mini.clue/lua/mini/clue.lua
                 Query keys after "`"
x  g           *@~/.local/share/nvim/lazy/mini.clue/lua/mini/clue.lua
                 Query keys after "g"
n  g           *@~/.local/share/nvim/lazy/mini.clue/lua/mini/clue.lua
                 Query keys after "g"
x  z           *@~/.local/share/nvim/lazy/mini.clue/lua/mini/clue.lua
                 Query keys after "z"
n  z           *@~/.local/share/nvim/lazy/mini.clue/lua/mini/clue.lua
                 Query keys after "z"
n  <C-W>       *@~/.local/share/nvim/lazy/mini.clue/lua/mini/clue.lua
                 Query keys after "<C-W>"
n  <Esc><Esc>  * :nohlsearch<CR>
                 Clear Search Highlighting
n  <Space>qw   * :wq<CR>
                 Write and quit
n  <Space>qq   * :wq!<CR>
                 Quit with force saving
n  <Space>qf   * :q<CR>
                 Quicker close split
n  <Space>tn   * :Noice dismiss<CR>
                 Noice: Dismiss Notification
n  <Space>tl   * :exec &bg=="light" ? "set bg=dark" : "set bg=light"<CR>
                 Toggle Light/Dark Mode
n  <Space>te   * :Neotree toggle<CR>
                 Toggle Neotree
n  <Space>tc   * :CloakToggle<CR>
                 Cloak: Toggle
n  <Space>xx   * :Trouble diagnostics<CR>
                 Trouble: Diagnostic
n  <Space>xw   * :Trouble workspace_diagnostics<CR>
                 Trouble: Workspace Diagnostics
n  <Space>xq   * :Trouble quickfix<CR>
                 Trouble: Quickfix
n  <Space>xl   * :Trouble loclist<CR>
                 Trouble: Location List
n  <Space>xd   * :Trouble document_diagnostics<CR>
                 Trouble: Document Diagnostics
n  <Space>sx   * :Telescope import
                 Telescope: Import
n  <Space>sw   * :Telescope grep_string<CR>
                 Grep String
n  <Space>st   * :TodoTelescope<CR>
                 Search Todos
n  <Space>ss   * :Telescope treesitter<CR>
                 Treesitter
n  <Space>srw  * :Telescope lsp_workspace_symbols<CR>
                 LSP Workspace Symbols
n  <Space>srt  * :Telescope lsp_type_definitions<CR>
                 LSP Type Definitions
n  <Space>srr  * :Telescope lsp_references<CR>
                 LSP References
n  <Space>srp  * :Telescope lsp_document_symbols<CR>
                 LSP Document Symbols
n  <Space>sri  * :Telescope lsp_implementations<CR>
                 LSP Implementations
n  <Space>srd  * :Telescope lsp_definitions<CR>
                 LSP Definitions
n  <Space>sq   * :Telescope quickfix<CR>
                 Quickfix
n  <Space>sp   * :lua require("telescope").extensions.lazy_plugins.lazy_plugins()<CR>
                 Lazy Plugins
n  <Space>so   * :Telescope oldfiles<CR>
                 Old Files
n  <Space>sn   * :lua require("telescope").extensions.notify.notify()<CR>
                 Show Notifications
n  <Space>sl   * :Telescope luasnip<CR>
                 Search LuaSnip
n  <Space>sh   * :Telescope highlights<CR>
                 List Highlights
n  <Space>sg   * :Telescope live_grep<CR>
                 Search by Grep
n  <Space>sd   * :Telescope diagnostics<CR>
                 Search Diagnostics
n  <Space>sc   * :Telescope commands<CR>
                 Commands
n  <Space>sb   * :Telescope buffers<CR>
                 Find existing buffers
n  <Space>f    * :Telescope find_files<CR>
                 Find Files
n  <Space>ls   * :lua require("telescope.builtin").lsp_document_symbols()<CR>
                 Document Symbols
n  <Space>lR   * :lua vim.lsp.buf.references()<CR>
                 References
n  <Space>lr   * :lua vim.lsp.buf.rename()<CR>
                 Rename
x  <Space>lf   * :lua vim.lsp.buf.format()<CR>
                 Format
n  <Space>lf   * :lua vim.lsp.buf.format()<CR>
                 Format
n  <Space>la   * :lua vim.lsp.buf.code_action()<CR>
                 Code Action
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
n  <Space>cw   * :Lspsaga diagnostic_jump_next<CR>
                 Diagnostic Jump Next
n  <Space>cv   * :Lspsaga diagnostic_jump_prev<CR>
                 Diagnostic Jump Prev
n  <Space>cu   * :Lspsaga preview_definition<CR>
                 Preview Definition
n  <Space>ct   * :Lspsaga peek_type_definition<CR>
                 Peek Type Definition
n  <Space>cs   * :Lspsaga signature_help<CR>
                 Signature Documentation
n  <Space>cR   * :Lspsaga rename ++project<CR>
                 Rename Project wide
n  <Space>cr   * :Lspsaga rename<CR>
                 Rename
n  <Space>cp   * :Lspsaga peek_definition<CR>
                 Peek Definition
n  <Space>cl   * :Lspsaga show_cursor_diagnostics<CR>
                 Show Cursor Diagnostics
n  <Space>ci   * :Lspsaga implement<CR>
                 Implementations
n  <Space>cco  * :Lspsaga outgoing_calls<CR>
                 Outgoing Calls
n  <Space>cci  * :Lspsaga incoming_calls<CR>
                 Incoming Calls
n  <Space>cd   * :Lspsaga show_line_diagnostics<CR>
                 Line Diagnostics
n  <Space>ca   * :Lspsaga code_action<CR>
                 Code Action
n  <Space>cg   * :lua require("neogen").generate()<CR>
                 Generate annotations
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
n  <Space>/    * ~/.config/nvim/lua/plugins/telescope.lua
                 [/] Fuzzily search in current buffer]
x  #           * vim/_defaults.lua
                 :help v_#-default
o  %             <Plug>(MatchitOperationForward)
x  %             <Plug>(MatchitVisualForward)
n  %             <Plug>(MatchitNormalForward)
n  &           * :&&<CR>
                 :help &-default
x  *           * vim/_defaults.lua
                 :help v_star-default
o  ;           * ~/.local/share/nvim/lazy/mini.jump/lua/mini/jump.lua
                 Repeat jump
x  ;           * <Cmd>lua MiniJump.jump()<CR>
                 Repeat jump
n  ;           * <Cmd>lua MiniJump.jump()<CR>
                 Repeat jump
v  <           * <gv
                 Indent Left
n  <           * <gv
                 Indent Left
v  >           * >gv
                 Indent Right
n  >           * >gv
                 Indent Right
n  @           * ~/.local/share/nvim/lazy/mini.clue/lua/mini/clue.lua
                 Execute macro without 'mini.clue' triggers
x  @           * mode() ==# 'V' ? ':normal! @'.getcharstr().'<CR>' : '@'
                 :help v_@-default
o  F           * ~/.local/share/nvim/lazy/mini.jump/lua/mini/jump.lua
                 Jump backward
x  F           * <Cmd>lua MiniJump.smart_jump(true, false)<CR>
                 Jump backward
n  F           * <Cmd>lua MiniJump.smart_jump(true, false)<CR>
                 Jump backward
n  K           * :Lspsaga hover_doc<CR>
                 Hover Documentation
n  Q           * ~/.local/share/nvim/lazy/mini.clue/lua/mini/clue.lua
                 Execute macro without 'mini.clue' triggers
x  Q           * mode() ==# 'V' ? ':normal! @<C-R>=reg_recorded()<CR><CR>' : 'Q'
                 :help v_Q-default
o  T           * ~/.local/share/nvim/lazy/mini.jump/lua/mini/jump.lua
                 Jump backward till
x  T           * <Cmd>lua MiniJump.smart_jump(true, true)<CR>
                 Jump backward till
n  T           * <Cmd>lua MiniJump.smart_jump(true, true)<CR>
                 Jump backward till
n  Y           * y$
                 :help Y-default
x  Zk          * ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua
                 Flash Treesitter
o  Zk          * ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua
                 Flash Treesitter
n  Zk          * ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua
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
x  a%            <Plug>(MatchitVisualTextObject)
o  ai          * <Cmd>lua MiniIndentscope.textobject(true)<CR>
                 Object scope with border
x  ai          * <Cmd>lua MiniIndentscope.textobject(true)<CR>
                 Object scope with border
o  f           * ~/.local/share/nvim/lazy/mini.jump/lua/mini/jump.lua
                 Jump forward
x  f           * <Cmd>lua MiniJump.smart_jump(false, false)<CR>
                 Jump forward
n  f           * <Cmd>lua MiniJump.smart_jump(false, false)<CR>
                 Jump forward
n  gR          * :RegexplainerToggle<CR>
                 Toggle Regexplainer
o  g%            <Plug>(MatchitOperationBackward)
x  g%            <Plug>(MatchitVisualBackward)
n  g%            <Plug>(MatchitNormalBackward)
x  gS          * :<C-U>lua MiniSplitjoin.toggle({ region = MiniSplitjoin.get_visual_region() })<CR>
                 Toggle arguments
n  gS          * v:lua.MiniSplitjoin.operator("toggle") . " "
                 Toggle arguments
o  gh          * <Cmd>lua MiniDiff.textobject()<CR>
                 Hunk range textobject
x  gH          * ~/.local/share/nvim/lazy/mini.diff/lua/mini/diff.lua
                 Reset hunks
n  gH          * ~/.local/share/nvim/lazy/mini.diff/lua/mini/diff.lua
                 Reset hunks
x  gh          * ~/.local/share/nvim/lazy/mini.diff/lua/mini/diff.lua
                 Apply hunks
n  gh          * ~/.local/share/nvim/lazy/mini.diff/lua/mini/diff.lua
                 Apply hunks
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
o  gc          * <Cmd>lua MiniComment.textobject()<CR>
                 Comment textobject
n  gcc         * ~/.local/share/nvim/lazy/mini.comment/lua/mini/comment.lua
                 Comment line
x  gc          * ~/.local/share/nvim/lazy/mini.comment/lua/mini/comment.lua
                 Comment selection
n  gc          * ~/.local/share/nvim/lazy/mini.comment/lua/mini/comment.lua
                 Comment
x  gx          * <Cmd>lua MiniOperators.exchange('visual')<CR>
                 Exchange selection
n  gx          * v:lua.MiniOperators.exchange()
                 Exchange operator
o  ii          * <Cmd>lua MiniIndentscope.textobject(false)<CR>
                 Object scope
x  ii          * <Cmd>lua MiniIndentscope.textobject(false)<CR>
                 Object scope
n  j           * v:count == 0 ? 'gj' : 'j'
                 Move down
n  k           * v:count == 0 ? 'gk' : 'k'
                 Move up
n  shn         * ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua
                 Highlight next surrounding
n  sFn         * ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua
                 Find next left surrounding
n  sfn         * ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua
                 Find next right surrounding
n  srn         * ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua
                 Replace next surrounding
n  sdn         * ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua
                 Delete next surrounding
n  shl         * ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua
                 Highlight previous surrounding
n  sFl         * ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua
                 Find previous left surrounding
n  sfl         * ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua
                 Find previous right surrounding
n  srl         * ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua
                 Replace previous surrounding
n  sdl         * ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua
                 Delete previous surrounding
x  sa          * :<C-U>lua MiniSurround.add('visual')<CR>
                 Add surrounding to selection
n  sn          * ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua
                 Update `MiniSurround.config.n_lines`
n  sh          * ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua
                 Highlight surrounding
n  sF          * ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua
                 Find left surrounding
n  sf          * ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua
                 Find right surrounding
n  sr          * ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua
                 Replace surrounding
n  sd          * ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua
                 Delete surrounding
n  sa          * ~/.local/share/nvim/lazy/mini.surround/lua/mini/surround.lua
                 Add surrounding
o  t           * ~/.local/share/nvim/lazy/mini.jump/lua/mini/jump.lua
                 Jump forward till
x  t           * <Cmd>lua MiniJump.smart_jump(false, true)<CR>
                 Jump forward till
n  t           * <Cmd>lua MiniJump.smart_jump(false, true)<CR>
                 Jump forward till
n  zk          * ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua
                 Flash
o  zk          * ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua
                 Flash
x  zk          * ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua
                 Flash
n  <C-W>.      * :vertical resize +10<CR>
                 V Resize +
n  <C-W>,      * :vertical resize -10<CR>
                 V Resize -
n  <C-H>       * :lua vim.lsp.buf.hover()<CR>
                 Hover
n  <C-K>       * :lua vim.lsp.buf.signature_help()<CR>
                 Signature Help
n  <C-S>       * :w!<CR>
                 Save
n  <Down>      * :echo "Use j to move!!"<CR>
n  <Up>        * :echo "Use k to move!!"<CR>
n  <Right>     * :echo "Use l to move!!"<CR>
n  <Left>      * :echo "Use h to move!!"<CR>
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
n  <M-k>       * :m '<-2<CR>gv=gv
                 Move Block Up
n  <M-j>       * :m '>+1<CR>gv=gv
                 Move Block Down
n  <M-l>       * <Cmd>lua MiniMove.move_line('right')<CR>
                 Move line right
n  <M-h>       * <Cmd>lua MiniMove.move_line('left')<CR>
                 Move line left
v  <M-k>       * :m '<-2<CR>gv=gv
                 Move Block Up
v  <M-j>       * :m '>+1<CR>gv=gv
                 Move Block Down
x  <M-l>       * <Cmd>lua MiniMove.move_selection('right')<CR>
                 Move right
x  <M-h>       * <Cmd>lua MiniMove.move_selection('left')<CR>
                 Move left
n  <C-W><C-D>    <C-W>d
                 Show diagnostics under the cursor
n  <C-W>d      * vim/_defaults.lua
                 Show diagnostics under the cursor
n  <C-L>       * <Cmd>nohlsearch|diffupdate|normal! <C-L><CR>
                 :help CTRL-L-default
```

- Generated on Sun  8 Dec 2024 02:56:08 EET
