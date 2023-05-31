# nvim keybindings

```md
n  !           * <Cmd>lua require("which-key").show("!", {mode = "n", auto = true})<CR>
n  '           * <Cmd>lua require("which-key").show("'", {mode = "n", auto = true})<CR>
n  "           * <Cmd>lua require("which-key").show("\"", {mode = "n", auto = true})<CR>
n  [           * <Cmd>lua require("which-key").show("[", {mode = "n", auto = true})<CR>
n  [b          * <Lua 246: ~/.config/nvim/lua/astronvim/mappings.lua:54> Previous buffer
n  [g          * <Lua 277: ~/.config/nvim/lua/astronvim/mappings.lua:150> Previous Git hunk
n  [t          * <Lua 281: ~/.config/nvim/lua/astronvim/mappings.lua:120> Previous tab
n  ]           * <Cmd>lua require("which-key").show("]", {mode = "n", auto = true})<CR>
n  ]b          * <Lua 250: ~/.config/nvim/lua/astronvim/mappings.lua:52> Next buffer
n  ]g          * <Lua 278: ~/.config/nvim/lua/astronvim/mappings.lua:149> Next Git hunk
n  ]t          * <Lua 282: ~/.config/nvim/lua/astronvim/mappings.lua:119> Next tab
n  @           * <Cmd>lua require("which-key").show("@", {mode = "n", auto = true})<CR>
n  \           * <Cmd>split<CR> Horizontal Split
n  &           * :&&<CR> Nvim builtin
n  `* <Cmd>lua require("which-key").show("`", {mode = "n", auto = true})<CR>
n  <           * <Cmd>lua require("which-key").show("<", {mode = "n", auto = true})<CR>
n  <b          * <Lua 297: ~/.config/nvim/lua/astronvim/mappings.lua:62> Move buffer tab left
n  <C-'>       * <Cmd>ToggleTerm<CR> Toggle terminal
n  <C-Down>    * <Lua 263: ~/.config/nvim/lua/astronvim/mappings.lua:213> Resize split down
n  <C-H>       * <Lua 266: ~/.config/nvim/lua/astronvim/mappings.lua:208> Move to left split
n  <C-J>       * <Lua 283: ~/.config/nvim/lua/astronvim/mappings.lua:209> Move to below split
n  <C-K>       * <Lua 327: ~/.config/nvim/lua/astronvim/mappings.lua:210> Move to above split
n  <C-L>       * <Lua 265: ~/.config/nvim/lua/astronvim/mappings.lua:211> Move to right split
n  <C-Left>    * <Lua 262: ~/.config/nvim/lua/astronvim/mappings.lua:214> Resize split left
n  <C-N>       * <Lua 79: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Goto next mark
n  <C-P>       * <Lua 80: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Goto previous mark
n  <C-Q>       * <Cmd>q!<CR> Force quit
n  <C-Right>   * <Lua 261: ~/.config/nvim/lua/astronvim/mappings.lua:215> Resize split right
n  <C-S>       * <Cmd>w!<CR> Force write
n  <C-Up>      * <Lua 264: ~/.config/nvim/lua/astronvim/mappings.lua:212> Resize split up
n  <C-W>       * <Cmd>lua require("which-key").show("\23", {mode = "n", auto = true})<CR>
n  <CR>        *@<Lua 391: ~/.local/share/nvim/lazy/alpha-nvim/lua/alpha.lua:705>
n  <F10>       * <Lua 348: ~/.config/nvim/lua/astronvim/mappings.lua:353> Debugger: Step Over
n  <F11>       * <Lua 333: ~/.config/nvim/lua/astronvim/mappings.lua:354> Debugger: Step Into
n  <F17>       * <Lua 344: ~/.config/nvim/lua/astronvim/mappings.lua:341> Debugger: Stop
n  <F21>       * <Lua 342: ~/.config/nvim/lua/astronvim/mappings.lua:343> Debugger: Conditional Breakpoint
n  <F23>       * <Lua 331: ~/.config/nvim/lua/astronvim/mappings.lua:355> Debugger: Step Out
n  <F29>       * <Lua 334: ~/.config/nvim/lua/astronvim/mappings.lua:350> Debugger: Restart
n  <F5>        * <Lua 341: ~/.config/nvim/lua/astronvim/mappings.lua:340> Debugger: Start
n  <F6>        * <Lua 339: ~/.config/nvim/lua/astronvim/mappings.lua:351> Debugger: Pause
n  <F7>        * <Cmd>ToggleTerm<CR> Toggle terminal
n  <F9>        * <Lua 337: ~/.config/nvim/lua/astronvim/mappings.lua:352> Debugger: Toggle Breakpoint
n  <M-CR>      *@<Lua 394: ~/.local/share/nvim/lazy/alpha-nvim/lua/alpha.lua:708>
n  <Plug>PlenaryTestFile *:lua require('plenary.test_harness').test_directory(vim.fn.expand("%:p"))<CR>
n  <Space>     * <Cmd>lua require("which-key").show(" ", {mode = "n", auto = true})<CR>
n  <Space>/    * <Lua 279: ~/.config/nvim/lua/astronvim/mappings.lua:139> Comment line
n  <Space><Space> * <Lua 49: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Harpoon
n  <Space><Space>a * <Lua 81: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Add file
n  <Space><Space>e * <Lua 82: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Toggle quick menu
n  <Space><Space>j * <Lua 48: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Goto to TMUX tmux window
n  <Space><Space>m * <Lua 83: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Show marks in Telescope
n  <Space><Space>t * <Lua 84: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Goto to terminal window
n  <Space>a    * <Lua 102: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Annotation
n  <Space>a<CR> * <Lua 103: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Current
n  <Space>ac   * <Lua 104: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Class
n  <Space>af   * <Lua 105: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Function
n  <Space>aF   * <Lua 96: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> File
n  <Space>at   * <Lua 86: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Type
n  <Space>b\   * <Lua 285: ~/.config/nvim/lua/astronvim/mappings.lua:100> Horizontal split buffer from tabline
n  <Space>b|   * <Lua 284: ~/.config/nvim/lua/astronvim/mappings.lua:109> Vertical split buffer from tabline
n  <Space>bb   * <Lua 294: ~/.config/nvim/lua/astronvim/mappings.lua:71> Select buffer from tabline
n  <Space>bC   * <Lua 295: ~/.config/nvim/lua/astronvim/mappings.lua:69> Close all buffers
n  <Space>bc   * <Lua 296: ~/.config/nvim/lua/astronvim/mappings.lua:68> Close all buffers except current
n  <Space>bd   * <Lua 293: ~/.config/nvim/lua/astronvim/mappings.lua:77> Delete buffer from tabline
n  <Space>bD   * <Lua 320: ~/.config/astronvim/lua/user/mappings.lua:13> Pick to close
n  <Space>bl   * <Lua 292: ~/.config/nvim/lua/astronvim/mappings.lua:85> Close all buffers to the left
n  <Space>bn   * <Cmd>tabnew<CR> New tab
n  <Space>br   * <Lua 291: ~/.config/nvim/lua/astronvim/mappings.lua:87> Close all buffers to the right
n  <Space>bse  * <Lua 290: ~/.config/nvim/lua/astronvim/mappings.lua:90> Sort by extension (buffers)
n  <Space>bsi  * <Lua 287: ~/.config/nvim/lua/astronvim/mappings.lua:96> Sort by buffer number (buffers)
n  <Space>bsm  * <Lua 286: ~/.config/nvim/lua/astronvim/mappings.lua:98> Sort by modification (buffers)
n  <Space>bsp  * <Lua 288: ~/.config/nvim/lua/astronvim/mappings.lua:94> Sort by full path (buffers)
n  <Space>bsr  * <Lua 289: ~/.config/nvim/lua/astronvim/mappings.lua:92> Sort by relative path (buffers)
n  <Space>C    * <Lua 299: ~/.config/nvim/lua/astronvim/mappings.lua:50> Force close buffer
n  <Space>c    * <Lua 300: ~/.config/nvim/lua/astronvim/mappings.lua:49> Close buffer
n  <Space>dB   * <Lua 328: ~/.config/nvim/lua/astronvim/mappings.lua:357> Clear Breakpoints
n  <Space>db   * <Lua 329: ~/.config/nvim/lua/astronvim/mappings.lua:356> Toggle Breakpoint (F9)
n  <Space>dC   * <Lua 324: ~/.config/nvim/lua/astronvim/mappings.lua:360> Conditional Breakpoint (S-F9)
n  <Space>dc   * <Lua 326: ~/.config/nvim/lua/astronvim/mappings.lua:358> Start/Continue (F5)
n  <Space>dE   * <Lua 308: ~/.config/nvim/lua/astronvim/mappings.lua:379> Evaluate Input
n  <Space>dh   * <Lua 305: ~/.config/nvim/lua/astronvim/mappings.lua:388> Debugger Hover
n  <Space>di   * <Lua 323: ~/.config/nvim/lua/astronvim/mappings.lua:367> Step Into (F11)
n  <Space>dO   * <Lua 321: ~/.config/nvim/lua/astronvim/mappings.lua:369> Step Out (S-F11)
n  <Space>do   * <Lua 322: ~/.config/nvim/lua/astronvim/mappings.lua:368> Step Over (F10)
n  <Space>dp   * <Lua 316: ~/.config/nvim/lua/astronvim/mappings.lua:372> Pause (F6)
n  <Space>dQ   * <Lua 318: ~/.config/nvim/lua/astronvim/mappings.lua:371> Terminate Session (S-F5)
n  <Space>dq   * <Lua 319: ~/.config/nvim/lua/astronvim/mappings.lua:370> Close Session
n  <Space>dR   * <Lua 312: ~/.config/nvim/lua/astronvim/mappings.lua:374> Toggle REPL
n  <Space>dr   * <Lua 314: ~/.config/nvim/lua/astronvim/mappings.lua:373> Restart (C-F5)
n  <Space>ds   * <Lua 310: ~/.config/nvim/lua/astronvim/mappings.lua:375> Run To Cursor
n  <Space>du   * <Lua 315: ~/.config/nvim/lua/astronvim/mappings.lua:387> Toggle Debugger UI
n  <Space>e    * <Cmd>Neotree toggle<CR> Toggle Explorer
n  <Space>f'   * <Lua 255: ~/.config/nvim/lua/astronvim/mappings.lua:241> Find marks
n  <Space>f<CR> * <Lua 256: ~/.config/nvim/lua/astronvim/mappings.lua:240> Resume previous search
n  <Space>fa   * <Lua 254: ~/.config/nvim/lua/astronvim/mappings.lua:243> Find AstroNvim config files
n  <Space>fb   * <Lua 253: ~/.config/nvim/lua/astronvim/mappings.lua:263> Find buffers
n  <Space>fC   * <Lua 251: ~/.config/nvim/lua/astronvim/mappings.lua:266> Find commands
n  <Space>fc   * <Lua 252: ~/.config/nvim/lua/astronvim/mappings.lua:265> Find for word under cursor
n  <Space>fF   * <Lua 248: ~/.config/nvim/lua/astronvim/mappings.lua:269> Find all files
n  <Space>ff   * <Lua 249: ~/.config/nvim/lua/astronvim/mappings.lua:267> Find files
n  <Space>fh   * <Lua 247: ~/.config/nvim/lua/astronvim/mappings.lua:272> Find help
n  <Space>fk   * <Lua 245: ~/.config/nvim/lua/astronvim/mappings.lua:273> Find keymaps
n  <Space>fm   * <Lua 309: ~/.config/nvim/lua/astronvim/mappings.lua:274> Find man
n  <Space>fn   * <Lua 242: ~/.config/nvim/lua/astronvim/mappings.lua:277> Find notifications
n  <Space>fo   * <Lua 240: ~/.config/nvim/lua/astronvim/mappings.lua:279> Find history
n  <Space>fr   * <Lua 239: ~/.config/nvim/lua/astronvim/mappings.lua:280> Find registers
n  <Space>ft   * <Lua 238: ~/.config/nvim/lua/astronvim/mappings.lua:282> Find themes
n  <Space>fW   * <Lua 236: ~/.config/nvim/lua/astronvim/mappings.lua:285> Find words in all files
n  <Space>fw   * <Lua 237: ~/.config/nvim/lua/astronvim/mappings.lua:283> Find words
n  <Space>gb   * <Lua 259: ~/.config/nvim/lua/astronvim/mappings.lua:237> Git branches
n  <Space>gc   * <Lua 258: ~/.config/nvim/lua/astronvim/mappings.lua:238> Git commits
n  <Space>gd   * <Lua 268: ~/.config/nvim/lua/astronvim/mappings.lua:159> View Git diff
n  <Space>gg   * <Lua 304: ~/.config/nvim/lua/astronvim/mappings.lua:312> ToggleTerm lazygit
n  <Space>gh   * <Lua 273: ~/.config/nvim/lua/astronvim/mappings.lua:154> Reset Git hunk
n  <Space>gL   * <Lua 275: ~/.config/nvim/lua/astronvim/mappings.lua:152> View full Git blame
n  <Space>gl   * <Lua 276: ~/.config/nvim/lua/astronvim/mappings.lua:151> View Git blame
n  <Space>gp   * <Lua 274: ~/.config/nvim/lua/astronvim/mappings.lua:153> Preview Git hunk
n  <Space>gr   * <Lua 272: ~/.config/nvim/lua/astronvim/mappings.lua:155> Reset Git buffer
n  <Space>gS   * <Lua 270: ~/.config/nvim/lua/astronvim/mappings.lua:157> Stage Git buffer
n  <Space>gs   * <Lua 271: ~/.config/nvim/lua/astronvim/mappings.lua:156> Stage Git hunk
n  <Space>gt   * <Lua 257: ~/.config/nvim/lua/astronvim/mappings.lua:239> Git status
n  <Space>gu   * <Lua 269: ~/.config/nvim/lua/astronvim/mappings.lua:158> Unstage Git hunk
n  <Space>h    * <Lua 280: ~/.config/nvim/lua/astronvim/mappings.lua:125> Home Screen
n  <Space>lD   * <Lua 313: ~/.config/nvim/lua/astronvim/mappings.lua:293> Search diagnostics
n  <Space>ls   * <Lua 235: ~/.config/nvim/lua/astronvim/mappings.lua:295> Search symbols
n  <Space>lS   * <Lua 260: ~/.config/nvim/lua/astronvim/mappings.lua:230> Symbols outline
n  <Space>n    * <Cmd>enew<CR> New File
n  <Space>o    * <Lua 267: ~/.config/nvim/lua/astronvim/mappings.lua:166> Toggle Explorer Focus
n  <Space>p    * <Cmd>lua require("which-key").show(" p", {mode = "n", auto = true})<CR>
n  <Space>pA   * <Cmd>AstroUpdate<CR> AstroNvim Update
n  <Space>pa   * <Cmd>AstroUpdatePackages<CR> Update Plugins and Mason
n  <Space>pi   * <Lua 307: ~/.config/nvim/lua/astronvim/mappings.lua:36> Plugins Install
n  <Space>pl   * <Cmd>AstroChangelog<CR> AstroNvim Changelog
n  <Space>pm   * <Cmd>Mason<CR> Mason Installer
n  <Space>pM   * <Cmd>MasonUpdateAll<CR> Mason Update
n  <Space>pS   * <Lua 233: ~/.config/nvim/lua/astronvim/mappings.lua:38> Plugins Sync
n  <Space>ps   * <Lua 234: ~/.config/nvim/lua/astronvim/mappings.lua:37> Plugins Status
n  <Space>pU   * <Lua 229: ~/.config/nvim/lua/astronvim/mappings.lua:40> Plugins Update
n  <Space>pu   * <Lua 231: ~/.config/nvim/lua/astronvim/mappings.lua:39> Plugins Check Updates
n  <Space>pv   * <Cmd>AstroVersion<CR> AstroNvim Version
n  <Space>q    * <Cmd>confirm q<CR> Quit
n  <Space>s    * <Lua 45: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Search / Replace
n  <Space>S.   * <Cmd>SessionManager! load_current_dir_session<CR> Load current directory session
n  <Space>Sd   * <Cmd>SessionManager! delete_session<CR> Delete session
n  <Space>Sf   * <Cmd>SessionManager! load_session<CR> Search sessions
n  <Space>sf   * <Lua 36: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Spectre (current file)
n  <Space>Sl   * <Cmd>SessionManager! load_last_session<CR> Load last session
n  <Space>Ss   * <Cmd>SessionManager! save_current_session<CR> Save this session
n  <Space>ss   * <Lua 35: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Spectre
n  <Space>tf   * <Cmd>ToggleTerm direction=float<CR> ToggleTerm float
n  <Space>th   * <Cmd>ToggleTerm size=10 direction=horizontal<CR> ToggleTerm horizontal split
n  <Space>tl   * <Lua 232: ~/.config/nvim/lua/astronvim/mappings.lua:313> ToggleTerm lazygit
n  <Space>tn   * <Lua 230: ~/.config/nvim/lua/astronvim/mappings.lua:316> ToggleTerm node
n  <Space>tp   * <Lua 311: ~/.config/nvim/lua/astronvim/mappings.lua:325> ToggleTerm python
n  <Space>tt   * <Lua 306: ~/.config/nvim/lua/astronvim/mappings.lua:322> ToggleTerm btm
n  <Space>tu   * <Lua 355: ~/.config/nvim/lua/astronvim/mappings.lua:319> ToggleTerm gdu
n  <Space>tv   * <Cmd>ToggleTerm size=80 direction=vertical<CR> ToggleTerm vertical split
n  <Space>ua   * <Lua 350: ~/.config/nvim/lua/astronvim/utils/ui.lua:27> Toggle autopairs
n  <Space>ub   * <Lua 303: ~/.config/nvim/lua/astronvim/utils/ui.lua:58> Toggle background
n  <Space>uC   * <Cmd>ColorizerToggle<CR> Toggle color highlight
n  <Space>uc   * <Lua 354: ~/.config/nvim/lua/astronvim/utils/ui.lua:64> Toggle autocompletion
n  <Space>ud   * <Lua 353: ~/.config/nvim/lua/astronvim/utils/ui.lua:43> Toggle diagnostics
n  <Space>ug   * <Lua 301: ~/.config/nvim/lua/astronvim/utils/ui.lua:134> Toggle signcolumn
n  <Space>uh   * <Lua 352: ~/.config/nvim/lua/astronvim/utils/ui.lua:215> Toggle foldcolumn
n  <Space>ui   * <Lua 325: ~/.config/nvim/lua/astronvim/utils/ui.lua:146> Change indent setting
n  <Space>ul   * <Lua 330: ~/.config/nvim/lua/astronvim/utils/ui.lua:117> Toggle statusline
n  <Space>uL   * <Lua 345: ~/.config/nvim/lua/astronvim/utils/ui.lua:98> Toggle CodeLens
n  <Space>uN   * <Lua 340: ~/.config/nvim/lua/astronvim/utils/ui.lua:21> Toggle UI notifications
n  <Space>un   * <Lua 343: ~/.config/nvim/lua/astronvim/utils/ui.lua:161> Change line numbering
n  <Space>up   * <Lua 338: ~/.config/nvim/lua/astronvim/utils/ui.lua:183> Toggle paste mode
n  <Space>uS   * <Lua 332: ~/.config/nvim/lua/astronvim/utils/ui.lua:111> Toggle conceal
n  <Space>us   * <Lua 335: ~/.config/nvim/lua/astronvim/utils/ui.lua:177> Toggle spellcheck
n  <Space>uT   * <Cmd>TransparentToggle<CR> Toggle transparency
n  <Space>ut   * <Lua 302: ~/.config/nvim/lua/astronvim/utils/ui.lua:105> Toggle tabline
n  <Space>uu   * <Lua 351: ~/.config/nvim/lua/astronvim/utils/ui.lua:208> Toggle URL highlight
n  <Space>uw   * <Lua 349: ~/.config/nvim/lua/astronvim/utils/ui.lua:189> Toggle wrap
n  <Space>uy   * <Lua 346: ~/.config/nvim/lua/astronvim/utils/ui.lua:195> Toggle syntax highlight
n  <Space>w    * <Cmd>w<CR> Save
n  <Space>x    * <Lua 126: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Trouble
n  <Space>xl   * <Lua 171: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Location List (Trouble)
n  <Space>xq   * <Lua 172: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Quickfix List (Trouble)
n  <Space>xX   * <Lua 132: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Workspace Diagnostics (Trouble)
n  <Space>xx   * <Lua 170: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Document Diagnostics (Trouble)
n  >           * <Cmd>lua require("which-key").show(">", {mode = "n", auto = true})<CR>
n  >b          * <Lua 298: ~/.config/nvim/lua/astronvim/mappings.lua:58> Move buffer tab right
n  |           * <Cmd>vsplit<CR> Vertical Split
n  c           * <Cmd>lua require("which-key").show("c", {mode = "n", auto = true})<CR>
n  d           * <Cmd>lua require("which-key").show("d", {mode = "n", auto = true})<CR>
n  g           * <Cmd>lua require("which-key").show("g", {mode = "n", auto = true})<CR>
n  gb          * <Lua 123: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Comment toggle blockwise
n  gc          * <Lua 107: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Comment toggle linewise
n  gx          * <Lua 241: ~/.config/nvim/lua/astronvim/utils/init.lua:134> Open the file under cursor with system app
n  j           * v:count == 0 ? 'gj' : 'j' Move cursor down
n  k           * v:count == 0 ? 'gk' : 'k' Move cursor up
n  v           * <Cmd>lua require("which-key").show("v", {mode = "n", auto = true})<CR>
n  y           * <Cmd>lua require("which-key").show("y", {mode = "n", auto = true})<CR>
n  Y           * y$ Nvim builtin
n  z           * <Cmd>lua require("which-key").show("z", {mode = "n", auto = true})<CR>
n  zM          * <Lua 244: ~/.config/nvim/lua/astronvim/mappings.lua:395> Close all folds
n  zm          * <Lua 317: ~/.config/nvim/lua/astronvim/mappings.lua:397> Fold more
n  zp          * <Lua 347: ~/.config/nvim/lua/astronvim/mappings.lua:398> Peek fold
n  zr          * <Lua 243: ~/.config/nvim/lua/astronvim/mappings.lua:396> Fold less
n  zR          * <Lua 336: ~/.config/nvim/lua/astronvim/mappings.lua:394> Open all folds
v  <Tab>       * >gv indent line
v  <S-Tab>     * <gv unindent line
v  <Space>/    * <Esc><Cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR> Toggle comment line
v  <Space>dE   * <Lua 228: ~/.config/nvim/lua/astronvim/mappings.lua:386> Evaluate Input
v  gb          * <Lua 124: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Comment toggle blockwise
v  gc          * <Lua 114: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Comment toggle linewise
x  "           * <Cmd>lua require("which-key").show("\"", {mode = "v", auto = true})<CR>
x  ** y/\V<C-R>"<CR> Nvim builtin
x  #           * y?\V<C-R>"<CR> Nvim builtin
x  <Space>     * <Cmd>lua require("which-key").show(" ", {mode = "v", auto = true})<CR>
x  <Space>s    * <Lua 46: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Search / Replace
x  <Space>sw   * <Lua 47: ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/handler/keys.lua:67> Spectre (current word)
x  g           * <Cmd>lua require("which-key").show("g", {mode = "v", auto = true})<CR>
```
