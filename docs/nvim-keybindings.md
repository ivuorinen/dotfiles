# Neovim Keybindings

## Global

### Normal Mode

| Key          | Description                                                                                | Command                                                    |
|--------------|--------------------------------------------------------------------------------------------|------------------------------------------------------------|
| ` ,`         | Find existing buffers                                                                      | `<Lua callback>`                                           |
| ` ba`        | Close all except current                                                                   | `<Lua callback>`                                           |
| ` bd`        | Delete buf                                                                                 | `<Cmd>lua MiniBufremove.delete()<CR>`                      |
| ` bh`        | Prev buf                                                                                   | `<Cmd>bprev<CR>`                                           |
| ` bj`        | First buf                                                                                  | `<Cmd>bfirst<CR>`                                          |
| ` bk`        | Last buf                                                                                   | `<Cmd>blast<CR>`                                           |
| ` bl`        | Next buf                                                                                   | `<Cmd>bnext<CR>`                                           |
| ` bn`        | New buf                                                                                    | `<Cmd>enew<CR>`                                            |
| ` bw`        | Wipeout                                                                                    | `<Cmd>lua MiniBufremove.wipeout()<CR>`                     |
| ` cci`       | Incoming calls                                                                             | `<Lua callback>`                                           |
| ` cco`       | Outgoing calls                                                                             | `<Lua callback>`                                           |
| ` cd`        | Definitions                                                                                | `<Lua callback>`                                           |
| ` cf`        | Format                                                                                     | `<Cmd>lua vim.lsp.buf.format()<CR>`                        |
| ` ci`        | Implementations                                                                            | `<Lua callback>`                                           |
| ` cp`        | Type Definition                                                                            | `<Lua callback>`                                           |
| ` cr`        | Rename file                                                                                | `<Lua callback>`                                           |
| ` cs`        | LSP Document Symbols                                                                       | `<Lua callback>`                                           |
| ` ct`        | Treesitter                                                                                 | `<Lua callback>`                                           |
| ` cws`       | Workspace Symbols                                                                          | `<Lua callback>`                                           |
| ` f`         | Find Files                                                                                 | `<Lua callback>`                                           |
| ` oO`        | org agenda                                                                                 | `<Cmd>lua require("orgmode").action("agenda.prompt")<CR>`  |
| ` oRc`       | Opens org-roam capture window                                                              | `<Lua callback>`                                           |
| ` oRd.`      | Navigate to dailies note directory                                                         | `<Lua callback>`                                           |
| ` oRdD`      | Capture a specific date's note                                                             | `<Lua callback>`                                           |
| ` oRdN`      | Capture today's note                                                                       | `<Lua callback>`                                           |
| ` oRdT`      | Capture tomorrow's note                                                                    | `<Lua callback>`                                           |
| ` oRdY`      | Capture yesterday's note                                                                   | `<Lua callback>`                                           |
| ` oRdb`      | Navigate to the previous available note                                                    | `<Lua callback>`                                           |
| ` oRdd`      | Navigate to a specific date's note                                                         | `<Lua callback>`                                           |
| ` oRdf`      | Navigate to the next available note                                                        | `<Lua callback>`                                           |
| ` oRdn`      | Navigate to today's note                                                                   | `<Lua callback>`                                           |
| ` oRdt`      | Navigate to tomorrow's note                                                                | `<Lua callback>`                                           |
| ` oRdy`      | Navigate to yesterday's note                                                               | `<Lua callback>`                                           |
| ` oRf`       | Finds org-roam node and moves to it, creating new one if missing                           | `<Lua callback>`                                           |
| ` oS`        | orgmode super agenda fullscreen                                                            | `<Cmd>OrgSuperAgenda!<CR>`                                 |
| ` oW`        | OrgSuperAgenda: Work This Week                                                             | `<Lua callback>`                                           |
| ` oa`        | orgmode super agenda                                                                       | `<Cmd>OrgSuperAgenda<CR>`                                  |
| ` oc`        | org capture                                                                                | `<Cmd>lua require("orgmode").action("capture.prompt")<CR>` |
| ` op`        | OrgSuperAgenda: Personal                                                                   | `<Lua callback>`                                           |
| ` pp`        | Open plugin manager                                                                        | `<Cmd>Pack<CR>`                                            |
| ` qQ`        | Force quit without saving                                                                  | `<Lua callback>`                                           |
| ` qf`        | Quicker close split                                                                        | `<Cmd>q<CR>`                                               |
| ` qq`        | Quit with force saving                                                                     | `<Lua callback>`                                           |
| ` qw`        | Write and quit                                                                             | `<Cmd>wq<CR>`                                              |
| ` sd`        | Search Diagnostics                                                                         | `<Lua callback>`                                           |
| ` sf`        | Grep String                                                                                | `<Lua callback>`                                           |
| ` sg`        | Live Grep                                                                                  | `<Lua callback>`                                           |
| ` sh`        | Help tags                                                                                  | `<Lua callback>`                                           |
| ` sk`        | Search Keymaps                                                                             | `<Lua callback>`                                           |
| ` sn`        | Message History                                                                            | `<Lua callback>`                                           |
| ` so`        | Old Files                                                                                  | `<Lua callback>`                                           |
| ` sq`        | Quickfix                                                                                   | `<Lua callback>`                                           |
| ` ss`        | Search Buffer Lines                                                                        | `<Lua callback>`                                           |
| ` te`        | File Explorer (cwd)                                                                        | `<Lua callback>`                                           |
| ` tf`        | Toggle autoformat on save                                                                  | `<Cmd>ToggleFormat<CR>`                                    |
| ` tl`        | Toggle Light/Dark Mode                                                                     | `<Lua callback>`                                           |
| ` tmC`       | Toggle cursorcolumn                                                                        | `<Lua callback>`                                           |
| ` tmc`       | Toggle cursorline                                                                          | `<Lua callback>`                                           |
| ` tmd`       | Toggle diagnostics                                                                         | `<Lua callback>`                                           |
| ` tmh`       | Toggle hlsearch                                                                            | `<Lua callback>`                                           |
| ` tml`       | Toggle list                                                                                | `<Lua callback>`                                           |
| ` tmn`       | Toggle number                                                                              | `<Lua callback>`                                           |
| ` tmr`       | Toggle relativenumber                                                                      | `<Lua callback>`                                           |
| ` tms`       | Toggle spell                                                                               | `<Lua callback>`                                           |
| ` tmw`       | Toggle wrap                                                                                | `<Lua callback>`                                           |
| ` tn`        | Dismiss Messages                                                                           | `<Lua callback>`                                           |
| ` tt`        | Toggle Terminal                                                                            | `<Lua callback>`                                           |
| ` xc`        | Cascade (most severe)                                                                      | `<Cmd>Trouble cascade<CR>`                                 |
| ` xl`        | Location List                                                                              | `<Cmd>Trouble loclist<CR>`                                 |
| ` xq`        | Quickfix                                                                                   | `<Cmd>Trouble quickfix<CR>`                                |
| ` xt`        | Test (split preview)                                                                       | `<Cmd>Trouble test<CR>`                                    |
| ` xx`        | Diagnostics                                                                                | `<Cmd>Trouble diagnostics<CR>`                             |
| `%`          | Go to matching bracket (matchit)                                                           | `<Plug>(MatchitNormalForward)`                             |
| `&`          | :help &amp;-default                                                                        | `:&&<CR>`                                                  |
| `-`          | File Explorer (current file)                                                               | `<Lua callback>`                                           |
| `<C-Down>`   | Disabled (use hjkl / word motions)                                                         | `<Lua callback>`                                           |
| `<C-J>`      | Move Block Down                                                                            | `<Cmd>m '>+1<CR>gv=gv`                                     |
| `<C-K>`      | Move Block Up                                                                              | `<Cmd>m '<-2<CR>gv=gv`                                     |
| `<C-L>`      | Signature                                                                                  | `<Cmd>lua vim.lsp.buf.signature_help()<CR>`                |
| `<C-Left>`   | Disabled (use hjkl / word motions)                                                         | `<Lua callback>`                                           |
| `<C-Right>`  | Disabled (use hjkl / word motions)                                                         | `<Lua callback>`                                           |
| `<C-S>`      | Save                                                                                       | `<Cmd>w!<CR>`                                              |
| `<C-Up>`     | Disabled (use hjkl / word motions)                                                         | `<Lua callback>`                                           |
| `<C-W>+`     | H Resize +                                                                                 | `<Cmd>resize +10<CR>`                                      |
| `<C-W>,`     | V Resize -                                                                                 | `<Cmd>vertical resize -10<CR>`                             |
| `<C-W>-`     | H Resize -                                                                                 | `<Cmd>resize -10<CR>`                                      |
| `<C-W>.`     | V Resize +                                                                                 | `<Cmd>vertical resize +10<CR>`                             |
| `<C-W><C-D>` | Show diagnostics under the cursor                                                          | `<C-W>d`                                                   |
| `<C-W>d`     | Show diagnostics under the cursor                                                          | `<Lua callback>`                                           |
| `<Down>`     | Disabled (use hjkl / word motions)                                                         | `<Lua callback>`                                           |
| `<Esc><Esc>` | Clear search highlight                                                                     | `<Cmd>nohlsearch<CR>`                                      |
| `<Left>`     | Disabled (use hjkl / word motions)                                                         | `<Lua callback>`                                           |
| `<Right>`    | Disabled (use hjkl / word motions)                                                         | `<Lua callback>`                                           |
| `<Up>`       | Disabled (use hjkl / word motions)                                                         | `<Lua callback>`                                           |
| `<`          | Indent Left                                                                                | `<gv`                                                      |
| `>`          | Indent Right                                                                               | `>gv`                                                      |
| `Y`          | :help Y-default                                                                            | `y$`                                                       |
| `[ `         | Add empty line above cursor                                                                | `<Lua callback>`                                           |
| `[%`         | Previous unmatched group (matchit)                                                         | `<Plug>(MatchitNormalMultiBackward)`                       |
| `[<C-L>`     | :lpfile                                                                                    | `<Lua callback>`                                           |
| `[<C-Q>`     | :cpfile                                                                                    | `<Lua callback>`                                           |
| `[<C-T>`     | :ptprevious                                                                                | `<Lua callback>`                                           |
| `[A`         | :rewind                                                                                    | `<Lua callback>`                                           |
| `[B`         | :brewind                                                                                   | `<Lua callback>`                                           |
| `[D`         | Jump to the first diagnostic in the current buffer                                         | `<Lua callback>`                                           |
| `[H`         | First hunk                                                                                 | `<Cmd>lua MiniDiff.goto_hunk('first')<CR>`                 |
| `[L`         | :lrewind                                                                                   | `<Lua callback>`                                           |
| `[Q`         | :crewind                                                                                   | `<Lua callback>`                                           |
| `[T`         | :trewind                                                                                   | `<Lua callback>`                                           |
| `[a`         | :previous                                                                                  | `<Lua callback>`                                           |
| `[b`         | :bprevious                                                                                 | `<Lua callback>`                                           |
| `[d`         | Jump to the previous diagnostic in the current buffer                                      | `<Lua callback>`                                           |
| `[h`         | Previous hunk                                                                              | `<Cmd>lua MiniDiff.goto_hunk('prev')<CR>`                  |
| `[i`         | Go to indent scope top                                                                     | `<Cmd>lua MiniIndentscope.operator('top', true)<CR>`       |
| `[l`         | :lprevious                                                                                 | `<Lua callback>`                                           |
| `[q`         | :cprevious                                                                                 | `<Lua callback>`                                           |
| `[t`         | :tprevious                                                                                 | `<Lua callback>`                                           |
| `] `         | Add empty line below cursor                                                                | `<Lua callback>`                                           |
| `]%`         | Next unmatched group (matchit)                                                             | `<Plug>(MatchitNormalMultiForward)`                        |
| `]<C-L>`     | :lnfile                                                                                    | `<Lua callback>`                                           |
| `]<C-Q>`     | :cnfile                                                                                    | `<Lua callback>`                                           |
| `]<C-T>`     | :ptnext                                                                                    | `<Lua callback>`                                           |
| `]A`         | :last                                                                                      | `<Lua callback>`                                           |
| `]B`         | :blast                                                                                     | `<Lua callback>`                                           |
| `]D`         | Jump to the last diagnostic in the current buffer                                          | `<Lua callback>`                                           |
| `]H`         | Last hunk                                                                                  | `<Cmd>lua MiniDiff.goto_hunk('last')<CR>`                  |
| `]L`         | :llast                                                                                     | `<Lua callback>`                                           |
| `]Q`         | :clast                                                                                     | `<Lua callback>`                                           |
| `]T`         | :tlast                                                                                     | `<Lua callback>`                                           |
| `]a`         | :next                                                                                      | `<Lua callback>`                                           |
| `]b`         | :bnext                                                                                     | `<Lua callback>`                                           |
| `]d`         | Jump to the next diagnostic in the current buffer                                          | `<Lua callback>`                                           |
| `]h`         | Next hunk                                                                                  | `<Cmd>lua MiniDiff.goto_hunk('next')<CR>`                  |
| `]i`         | Go to indent scope bottom                                                                  | `<Cmd>lua MiniIndentscope.operator('bottom', true)<CR>`    |
| `]l`         | :lnext                                                                                     | `<Lua callback>`                                           |
| `]q`         | :cnext                                                                                     | `<Lua callback>`                                           |
| `]t`         | :tnext                                                                                     | `<Lua callback>`                                           |
| `g%`         | Reverse matching bracket (matchit)                                                         | `<Plug>(MatchitNormalBackward)`                            |
| `g=`         | Evaluate                                                                                   | `v:lua.MiniOperators.evaluate()`                           |
| `g=​=`       | Evaluate line                                                                              | `g=_`                                                      |
| `gH`         | Reset hunks                                                                                | `<Lua callback>`                                           |
| `gO`         | vim.lsp.buf.document_symbol()                                                              | `<Lua callback>`                                           |
| `gR`         | Replace                                                                                    | `v:lua.MiniOperators.replace()`                            |
| `gRR`        | Replace line                                                                               | `gR_`                                                      |
| `gS`         | Toggle arguments                                                                           | `v:lua.MiniSplitjoin.operator("toggle") . " "`             |
| `gX`         | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) | `<Lua callback>`                                           |
| `g[`         | Move to left "around"                                                                      | `<Lua callback>`                                           |
| `g]`         | Move to right "around"                                                                     | `<Lua callback>`                                           |
| `gc`         | Comment                                                                                    | `<Lua callback>`                                           |
| `gcc`        | Comment line                                                                               | `<Lua callback>`                                           |
| `gh`         | Apply hunks                                                                                | `<Lua callback>`                                           |
| `gm`         | Multiply                                                                                   | `v:lua.MiniOperators.multiply()`                           |
| `gmm`        | Multiply line                                                                              | `gm_`                                                      |
| `gra`        | vim.lsp.buf.code_action()                                                                  | `<Lua callback>`                                           |
| `gri`        | vim.lsp.buf.implementation()                                                               | `<Lua callback>`                                           |
| `grn`        | vim.lsp.buf.rename()                                                                       | `<Lua callback>`                                           |
| `grr`        | vim.lsp.buf.references()                                                                   | `<Lua callback>`                                           |
| `grt`        | vim.lsp.buf.type_definition()                                                              | `<Lua callback>`                                           |
| `grx`        | vim.lsp.codelens.run()                                                                     | `<Lua callback>`                                           |
| `gs`         | Sort                                                                                       | `v:lua.MiniOperators.sort()`                               |
| `gss`        | Sort line                                                                                  | `^gsg_`                                                    |
| `gx`         | Exchange                                                                                   | `v:lua.MiniOperators.exchange()`                           |
| `gxx`        | Exchange line                                                                              | `gx_`                                                      |
| `j`          | Move down                                                                                  | `v:count =​= 0 ? 'gj' : 'j'`                               |
| `k`          | Move up                                                                                    | `v:count =​= 0 ? 'gk' : 'k'`                               |
| `s`          | Surround (mini.surround)                                                                   | `<Lua callback>`                                           |
| `sF`         | Find left surrounding                                                                      | `<Lua callback>`                                           |
| `sFl`        | Find previous left surrounding                                                             | `<Lua callback>`                                           |
| `sFn`        | Find next left surrounding                                                                 | `<Lua callback>`                                           |
| `sa`         | Add surrounding                                                                            | `<Lua callback>`                                           |
| `sd`         | Delete surrounding                                                                         | `<Lua callback>`                                           |
| `sdl`        | Delete previous surrounding                                                                | `<Lua callback>`                                           |
| `sdn`        | Delete next surrounding                                                                    | `<Lua callback>`                                           |
| `sf`         | Find right surrounding                                                                     | `<Lua callback>`                                           |
| `sfl`        | Find previous right surrounding                                                            | `<Lua callback>`                                           |
| `sfn`        | Find next right surrounding                                                                | `<Lua callback>`                                           |
| `sh`         | Highlight surrounding                                                                      | `<Lua callback>`                                           |
| `shl`        | Highlight previous surrounding                                                             | `<Lua callback>`                                           |
| `shn`        | Highlight next surrounding                                                                 | `<Lua callback>`                                           |
| `sr`         | Replace surrounding                                                                        | `<Lua callback>`                                           |
| `srl`        | Replace previous surrounding                                                               | `<Lua callback>`                                           |
| `srn`        | Replace next surrounding                                                                   | `<Lua callback>`                                           |

### Insert Mode

| Key       | Description                                         | Command          |
|-----------|-----------------------------------------------------|------------------|
| `<C-S>`   | vim.lsp.buf.signature_help()                        | `<Lua callback>` |
| `<C-U>`   | :help i_CTRL-U-default                              | `<C-G>u<C-U>`    |
| `<C-W>`   | :help i_CTRL-W-default                              | `<C-G>u<C-W>`    |
| `<S-Tab>` | vim.snippet.jump if active, otherwise &lt;S-Tab&gt; | `<Lua callback>` |
| `<Tab>`   | vim.snippet.jump if active, otherwise &lt;Tab&gt;   | `<Lua callback>` |

### Visual + Select Mode

| Key       | Description                                                                                | Command                                                                              |
|-----------|--------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| ` cf`     | Format                                                                                     | `<Cmd>lua vim.lsp.buf.format()<CR>`                                                  |
| ` oRc`    | Opens org-roam capture window                                                              | `<Lua callback>`                                                                     |
| ` oRf`    | Finds org-roam node and moves to it, creating new one if missing                           | `<Lua callback>`                                                                     |
| `#`       | :help v_#-default                                                                          | `<Lua callback>`                                                                     |
| `%`       | Go to matching bracket (matchit)                                                           | `<Plug>(MatchitVisualForward)`                                                       |
| `*`       | :help v_star-default                                                                       | `<Lua callback>`                                                                     |
| `<C-J>`   | Move Block Down                                                                            | `<Cmd>m '>+1<CR>gv=gv`                                                               |
| `<C-K>`   | Move Block Up                                                                              | `<Cmd>m '<-2<CR>gv=gv`                                                               |
| `<C-S>`   | vim.lsp.buf.signature_help()                                                               | `<Lua callback>`                                                                     |
| `<S-Tab>` | vim.snippet.jump if active, otherwise &lt;S-Tab&gt;                                        | `<Lua callback>`                                                                     |
| `<Tab>`   | vim.snippet.jump if active, otherwise &lt;Tab&gt;                                          | `<Lua callback>`                                                                     |
| `<`       | Indent Left                                                                                | `<gv`                                                                                |
| `>`       | Indent Right                                                                               | `>gv`                                                                                |
| `@`       | :help v_@-default                                                                          | `mode() =​=# 'V' ? ':normal! @'.getcharstr().'<CR>' : '@'`                           |
| `Q`       | :help v_Q-default                                                                          | `mode() =​=# 'V' ? ':normal! @<C-R>=reg_recorded()<CR><CR>' : 'Q'`                   |
| `[%`      | Previous unmatched group (matchit)                                                         | `<Plug>(MatchitVisualMultiBackward)`                                                 |
| `[H`      | First hunk                                                                                 | `<Cmd>lua MiniDiff.goto_hunk('first')<CR>`                                           |
| `[N`      | Select previous sibling node                                                               | `<Lua callback>`                                                                     |
| `[h`      | Previous hunk                                                                              | `<Cmd>lua MiniDiff.goto_hunk('prev')<CR>`                                            |
| `[i`      | Go to indent scope top                                                                     | `<Cmd>lua MiniIndentscope.operator('top')<CR>`                                       |
| `[n`      | Select previous node                                                                       | `<Lua callback>`                                                                     |
| `]%`      | Next unmatched group (matchit)                                                             | `<Plug>(MatchitVisualMultiForward)`                                                  |
| `]H`      | Last hunk                                                                                  | `<Cmd>lua MiniDiff.goto_hunk('last')<CR>`                                            |
| `]N`      | Select next sibling node                                                                   | `<Lua callback>`                                                                     |
| `]h`      | Next hunk                                                                                  | `<Cmd>lua MiniDiff.goto_hunk('next')<CR>`                                            |
| `]i`      | Go to indent scope bottom                                                                  | `<Cmd>lua MiniIndentscope.operator('bottom')<CR>`                                    |
| `]n`      | Select next node                                                                           | `<Lua callback>`                                                                     |
| `a`       | Around textobject                                                                          | `<Lua callback>`                                                                     |
| `a%`      | Select matching group (matchit)                                                            | `<Plug>(MatchitVisualTextObject)`                                                    |
| `ai`      | Object scope with border                                                                   | `<Cmd>lua MiniIndentscope.textobject(true)<CR>`                                      |
| `al`      | Around last textobject                                                                     | `<Lua callback>`                                                                     |
| `an`      | Around next textobject                                                                     | `<Lua callback>`                                                                     |
| `g%`      | Reverse matching bracket (matchit)                                                         | `<Plug>(MatchitVisualBackward)`                                                      |
| `g=`      | Evaluate selection                                                                         | `<Cmd>lua MiniOperators.evaluate('visual')<CR>`                                      |
| `gH`      | Reset hunks                                                                                | `<Lua callback>`                                                                     |
| `gR`      | Replace selection                                                                          | `<Cmd>lua MiniOperators.replace('visual')<CR>`                                       |
| `gS`      | Toggle arguments                                                                           | `:<C-U>lua MiniSplitjoin.toggle({ region = MiniSplitjoin.get_visual_region() })<CR>` |
| `gX`      | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) | `<Lua callback>`                                                                     |
| `g[`      | Move to left "around"                                                                      | `<Lua callback>`                                                                     |
| `g]`      | Move to right "around"                                                                     | `<Lua callback>`                                                                     |
| `gc`      | Comment selection                                                                          | `<Lua callback>`                                                                     |
| `gh`      | Apply hunks                                                                                | `<Lua callback>`                                                                     |
| `gm`      | Multiply selection                                                                         | `<Cmd>lua MiniOperators.multiply('visual')<CR>`                                      |
| `gra`     | vim.lsp.buf.code_action()                                                                  | `<Lua callback>`                                                                     |
| `gs`      | Sort selection                                                                             | `<Cmd>lua MiniOperators.sort('visual')<CR>`                                          |
| `gx`      | Exchange selection                                                                         | `<Cmd>lua MiniOperators.exchange('visual')<CR>`                                      |
| `i`       | Inside textobject                                                                          | `<Lua callback>`                                                                     |
| `ii`      | Object scope                                                                               | `<Cmd>lua MiniIndentscope.textobject(false)<CR>`                                     |
| `il`      | Inside last textobject                                                                     | `<Lua callback>`                                                                     |
| `in`      | Inside next textobject                                                                     | `<Lua callback>`                                                                     |
| `s`       | Surround (mini.surround)                                                                   | `<Lua callback>`                                                                     |
| `sF`      | Find left surrounding                                                                      | `<Lua callback>`                                                                     |
| `sFl`     | Find previous left surrounding                                                             | `<Lua callback>`                                                                     |
| `sFn`     | Find next left surrounding                                                                 | `<Lua callback>`                                                                     |
| `sa`      | Add surrounding to selection                                                               | `:<C-U>lua MiniSurround.add("visual")<CR>`                                           |
| `sf`      | Find right surrounding                                                                     | `<Lua callback>`                                                                     |
| `sfl`     | Find previous right surrounding                                                            | `<Lua callback>`                                                                     |
| `sfn`     | Find next right surrounding                                                                | `<Lua callback>`                                                                     |

### Visual Mode

| Key     | Description                                                                                | Command                                                                              |
|---------|--------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| ` cf`   | Format                                                                                     | `<Cmd>lua vim.lsp.buf.format()<CR>`                                                  |
| ` oRc`  | Opens org-roam capture window                                                              | `<Lua callback>`                                                                     |
| ` oRf`  | Finds org-roam node and moves to it, creating new one if missing                           | `<Lua callback>`                                                                     |
| `#`     | :help v_#-default                                                                          | `<Lua callback>`                                                                     |
| `%`     | Go to matching bracket (matchit)                                                           | `<Plug>(MatchitVisualForward)`                                                       |
| `*`     | :help v_star-default                                                                       | `<Lua callback>`                                                                     |
| `<C-J>` | Move Block Down                                                                            | `<Cmd>m '>+1<CR>gv=gv`                                                               |
| `<C-K>` | Move Block Up                                                                              | `<Cmd>m '<-2<CR>gv=gv`                                                               |
| `<`     | Indent Left                                                                                | `<gv`                                                                                |
| `>`     | Indent Right                                                                               | `>gv`                                                                                |
| `@`     | :help v_@-default                                                                          | `mode() =​=# 'V' ? ':normal! @'.getcharstr().'<CR>' : '@'`                           |
| `Q`     | :help v_Q-default                                                                          | `mode() =​=# 'V' ? ':normal! @<C-R>=reg_recorded()<CR><CR>' : 'Q'`                   |
| `[%`    | Previous unmatched group (matchit)                                                         | `<Plug>(MatchitVisualMultiBackward)`                                                 |
| `[H`    | First hunk                                                                                 | `<Cmd>lua MiniDiff.goto_hunk('first')<CR>`                                           |
| `[N`    | Select previous sibling node                                                               | `<Lua callback>`                                                                     |
| `[h`    | Previous hunk                                                                              | `<Cmd>lua MiniDiff.goto_hunk('prev')<CR>`                                            |
| `[i`    | Go to indent scope top                                                                     | `<Cmd>lua MiniIndentscope.operator('top')<CR>`                                       |
| `[n`    | Select previous node                                                                       | `<Lua callback>`                                                                     |
| `]%`    | Next unmatched group (matchit)                                                             | `<Plug>(MatchitVisualMultiForward)`                                                  |
| `]H`    | Last hunk                                                                                  | `<Cmd>lua MiniDiff.goto_hunk('last')<CR>`                                            |
| `]N`    | Select next sibling node                                                                   | `<Lua callback>`                                                                     |
| `]h`    | Next hunk                                                                                  | `<Cmd>lua MiniDiff.goto_hunk('next')<CR>`                                            |
| `]i`    | Go to indent scope bottom                                                                  | `<Cmd>lua MiniIndentscope.operator('bottom')<CR>`                                    |
| `]n`    | Select next node                                                                           | `<Lua callback>`                                                                     |
| `a`     | Around textobject                                                                          | `<Lua callback>`                                                                     |
| `a%`    | Select matching group (matchit)                                                            | `<Plug>(MatchitVisualTextObject)`                                                    |
| `ai`    | Object scope with border                                                                   | `<Cmd>lua MiniIndentscope.textobject(true)<CR>`                                      |
| `al`    | Around last textobject                                                                     | `<Lua callback>`                                                                     |
| `an`    | Around next textobject                                                                     | `<Lua callback>`                                                                     |
| `g%`    | Reverse matching bracket (matchit)                                                         | `<Plug>(MatchitVisualBackward)`                                                      |
| `g=`    | Evaluate selection                                                                         | `<Cmd>lua MiniOperators.evaluate('visual')<CR>`                                      |
| `gH`    | Reset hunks                                                                                | `<Lua callback>`                                                                     |
| `gR`    | Replace selection                                                                          | `<Cmd>lua MiniOperators.replace('visual')<CR>`                                       |
| `gS`    | Toggle arguments                                                                           | `:<C-U>lua MiniSplitjoin.toggle({ region = MiniSplitjoin.get_visual_region() })<CR>` |
| `gX`    | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) | `<Lua callback>`                                                                     |
| `g[`    | Move to left "around"                                                                      | `<Lua callback>`                                                                     |
| `g]`    | Move to right "around"                                                                     | `<Lua callback>`                                                                     |
| `gc`    | Comment selection                                                                          | `<Lua callback>`                                                                     |
| `gh`    | Apply hunks                                                                                | `<Lua callback>`                                                                     |
| `gm`    | Multiply selection                                                                         | `<Cmd>lua MiniOperators.multiply('visual')<CR>`                                      |
| `gra`   | vim.lsp.buf.code_action()                                                                  | `<Lua callback>`                                                                     |
| `gs`    | Sort selection                                                                             | `<Cmd>lua MiniOperators.sort('visual')<CR>`                                          |
| `gx`    | Exchange selection                                                                         | `<Cmd>lua MiniOperators.exchange('visual')<CR>`                                      |
| `i`     | Inside textobject                                                                          | `<Lua callback>`                                                                     |
| `ii`    | Object scope                                                                               | `<Cmd>lua MiniIndentscope.textobject(false)<CR>`                                     |
| `il`    | Inside last textobject                                                                     | `<Lua callback>`                                                                     |
| `in`    | Inside next textobject                                                                     | `<Lua callback>`                                                                     |
| `s`     | Surround (mini.surround)                                                                   | `<Lua callback>`                                                                     |
| `sF`    | Find left surrounding                                                                      | `<Lua callback>`                                                                     |
| `sFl`   | Find previous left surrounding                                                             | `<Lua callback>`                                                                     |
| `sFn`   | Find next left surrounding                                                                 | `<Lua callback>`                                                                     |
| `sa`    | Add surrounding to selection                                                               | `:<C-U>lua MiniSurround.add("visual")<CR>`                                           |
| `sf`    | Find right surrounding                                                                     | `<Lua callback>`                                                                     |
| `sfl`   | Find previous right surrounding                                                            | `<Lua callback>`                                                                     |
| `sfn`   | Find next right surrounding                                                                | `<Lua callback>`                                                                     |

### Select Mode

| Key       | Description                                                      | Command                |
|-----------|------------------------------------------------------------------|------------------------|
| ` oRc`    | Opens org-roam capture window                                    | `<Lua callback>`       |
| ` oRf`    | Finds org-roam node and moves to it, creating new one if missing | `<Lua callback>`       |
| `<C-J>`   | Move Block Down                                                  | `<Cmd>m '>+1<CR>gv=gv` |
| `<C-K>`   | Move Block Up                                                    | `<Cmd>m '<-2<CR>gv=gv` |
| `<C-S>`   | vim.lsp.buf.signature_help()                                     | `<Lua callback>`       |
| `<S-Tab>` | vim.snippet.jump if active, otherwise &lt;S-Tab&gt;              | `<Lua callback>`       |
| `<Tab>`   | vim.snippet.jump if active, otherwise &lt;Tab&gt;                | `<Lua callback>`       |
| `<`       | Indent Left                                                      | `<gv`                  |
| `>`       | Indent Right                                                     | `>gv`                  |

### Operator-pending Mode

| Key   | Description                        | Command                                           |
|-------|------------------------------------|---------------------------------------------------|
| `%`   | Go to matching bracket (matchit)   | `<Plug>(MatchitOperationForward)`                 |
| `[%`  | Previous unmatched group (matchit) | `<Plug>(MatchitOperationMultiBackward)`           |
| `[H`  | First hunk                         | `V<Cmd>lua MiniDiff.goto_hunk('first')<CR>`       |
| `[h`  | Previous hunk                      | `V<Cmd>lua MiniDiff.goto_hunk('prev')<CR>`        |
| `[i`  | Go to indent scope top             | `<Cmd>lua MiniIndentscope.operator('top')<CR>`    |
| `]%`  | Next unmatched group (matchit)     | `<Plug>(MatchitOperationMultiForward)`            |
| `]H`  | Last hunk                          | `V<Cmd>lua MiniDiff.goto_hunk('last')<CR>`        |
| `]h`  | Next hunk                          | `V<Cmd>lua MiniDiff.goto_hunk('next')<CR>`        |
| `]i`  | Go to indent scope bottom          | `<Cmd>lua MiniIndentscope.operator('bottom')<CR>` |
| `a`   | Around textobject                  | `<Lua callback>`                                  |
| `ai`  | Object scope with border           | `<Cmd>lua MiniIndentscope.textobject(true)<CR>`   |
| `al`  | Around last textobject             | `<Lua callback>`                                  |
| `an`  | Around next textobject             | `<Lua callback>`                                  |
| `g%`  | Reverse matching bracket (matchit) | `<Plug>(MatchitOperationBackward)`                |
| `g[`  | Move to left "around"              | `<Lua callback>`                                  |
| `g]`  | Move to right "around"             | `<Lua callback>`                                  |
| `gc`  | Comment textobject                 | `<Cmd>lua MiniComment.textobject()<CR>`           |
| `gh`  | Hunk range textobject              | `<Cmd>lua MiniDiff.textobject()<CR>`              |
| `i`   | Inside textobject                  | `<Lua callback>`                                  |
| `ii`  | Object scope                       | `<Cmd>lua MiniIndentscope.textobject(false)<CR>`  |
| `il`  | Inside last textobject             | `<Lua callback>`                                  |
| `in`  | Inside next textobject             | `<Lua callback>`                                  |
| `s`   | Surround (mini.surround)           | `<Lua callback>`                                  |
| `sF`  | Find left surrounding              | `<Lua callback>`                                  |
| `sFl` | Find previous left surrounding     | `<Lua callback>`                                  |
| `sFn` | Find next left surrounding         | `<Lua callback>`                                  |
| `sf`  | Find right surrounding             | `<Lua callback>`                                  |
| `sfl` | Find previous right surrounding    | `<Lua callback>`                                  |
| `sfn` | Find next right surrounding        | `<Lua callback>`                                  |

### Command-line Mode

| Key       | Description                                              | Command          |
|-----------|----------------------------------------------------------|------------------|
| `<C-E>`   | blink.cmp: Cancel                                        | `<Lua callback>` |
| `<C-L>`   | blink.cmp: Show                                          | `<Lua callback>` |
| `<C-N>`   | blink.cmp: Select Next                                   | `<Lua callback>` |
| `<C-P>`   | blink.cmp: Select Prev                                   | `<Lua callback>` |
| `<C-Y>`   | blink.cmp: Select And Accept                             | `<Lua callback>` |
| `<End>`   | blink.cmp: Hide                                          | `<Lua callback>` |
| `<Left>`  | blink.cmp: Select Prev                                   | `<Lua callback>` |
| `<Right>` | blink.cmp: Select Next                                   | `<Lua callback>` |
| `<S-Tab>` | blink.cmp: &lt;Custom Fn&gt;, Select Prev                | `<Lua callback>` |
| `<Tab>`   | blink.cmp: Show And Insert Or Accept Single, Select Next | `<Lua callback>` |

## Every buffer

Buffer-local maps that every file buffer gets.

### Every buffer: Insert Mode

| Key       | Description                                             | Command          |
|-----------|---------------------------------------------------------|------------------|
| `<C-B>`   | blink.cmp: Scroll Documentation Up                      | `<Lua callback>` |
| `<C-E>`   | blink.cmp: Cancel                                       | `<Lua callback>` |
| `<C-F>`   | blink.cmp: Scroll Documentation Down                    | `<Lua callback>` |
| `<C-K>`   | blink.cmp: Show Signature, Hide Signature               | `<Lua callback>` |
| `<C-L>`   | blink.cmp: Show, Show Documentation, Hide Documentation | `<Lua callback>` |
| `<C-N>`   | blink.cmp: Select Next                                  | `<Lua callback>` |
| `<C-P>`   | blink.cmp: Select Prev                                  | `<Lua callback>` |
| `<C-Y>`   | blink.cmp: Select And Accept                            | `<Lua callback>` |
| `<Down>`  | blink.cmp: Select Next                                  | `<Lua callback>` |
| `<S-Tab>` | blink.cmp: Snippet Backward                             | `<Lua callback>` |
| `<Tab>`   | blink.cmp: Snippet Forward                              | `<Lua callback>` |
| `<Up>`    | blink.cmp: Select Prev                                  | `<Lua callback>` |

### Every buffer: Visual + Select Mode

| Key       | Description                               | Command          |
|-----------|-------------------------------------------|------------------|
| `<C-K>`   | blink.cmp: Show Signature, Hide Signature | `<Lua callback>` |
| `<S-Tab>` | blink.cmp: Snippet Backward               | `<Lua callback>` |
| `<Tab>`   | blink.cmp: Snippet Forward                | `<Lua callback>` |

### Every buffer: Select Mode

| Key       | Description                               | Command          |
|-----------|-------------------------------------------|------------------|
| `<C-K>`   | blink.cmp: Show Signature, Hide Signature | `<Lua callback>` |
| `<S-Tab>` | blink.cmp: Snippet Backward               | `<Lua callback>` |
| `<Tab>`   | blink.cmp: Snippet Forward                | `<Lua callback>` |

## Org buffers

Buffer-local maps an org buffer adds to those above.

### Org buffers: Normal Mode

| Key        | Description                                                                                                | Command                                                                                      |
|------------|------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| ` <CR>`    | org meta return                                                                                            | `<Cmd>lua require("orgmode").action("org_mappings.meta_return")<CR>`                         |
| ` o$`      | org archive subtree                                                                                        | `<Cmd>lua require("orgmode").action("org_mappings.archive")<CR>`                             |
| ` o'`      | org edit special                                                                                           | `<Cmd>lua require("orgmode").action("org_mappings.edit_special")<CR>`                        |
| ` o*`      | org toggle headline                                                                                        | `<Cmd>lua require("orgmode").action("org_mappings.toggle_heading")<CR>`                      |
| ` o,`      | org cycle priority                                                                                         | `<Cmd>lua require("orgmode").action("org_mappings.set_priority")<CR>`                        |
| ` oA`      | org toggle archive tag                                                                                     | `<Cmd>lua require("orgmode").action("org_mappings.toggle_archive_tag")<CR>`                  |
| ` oJ`      | org move subtree down                                                                                      | `<Cmd>lua require("orgmode").action("org_mappings.move_subtree_down")<CR>`                   |
| ` oK`      | org move subtree up                                                                                        | `<Cmd>lua require("orgmode").action("org_mappings.move_subtree_up")<CR>`                     |
| ` oR.`     | Completes link to a node based on expression under cursor                                                  | `<Lua callback>`                                                                             |
| ` oRaa`    | Adds an alias to the roam node under cursor                                                                | `<Lua callback>`                                                                             |
| ` oRar`    | Removes an alias from the roam node under cursor                                                           | `<Lua callback>`                                                                             |
| ` oRb`     | Toggles org-roam buffer for a specific node, not changing                                                  | `<Lua callback>`                                                                             |
| ` oRi`     | Inserts at cursor position the selected node, creating new one if missing                                  | `<Lua callback>`                                                                             |
| ` oRl`     | Toggles org-roam buffer for node under cursor                                                              | `<Lua callback>`                                                                             |
| ` oRm`     | Inserts at cursor position the selected node, creating new one if missing without opening a capture buffer | `<Lua callback>`                                                                             |
| ` oRn`     | Goes to the next node sequentially based on origin of the node under cursor                                | `<Lua callback>`                                                                             |
| ` oRoa`    | Adds an origin to the roam node under cursor                                                               | `<Lua callback>`                                                                             |
| ` oRor`    | Removes the origin from the roam node under cursor                                                         | `<Lua callback>`                                                                             |
| ` oRp`     | Goes to the previous node sequentially based on origin of the node under cursor                            | `<Lua callback>`                                                                             |
| ` oRq`     | Open quickfix of backlinks for org-roam node under cursor                                                  | `<Lua callback>`                                                                             |
| ` oX`      | org toggle checkbox                                                                                        | `<Cmd>lua require("orgmode").action("org_mappings.toggle_checkbox")<CR>`                     |
| ` obt`     | org tangle                                                                                                 | `<Cmd>lua require("orgmode").action("org_mappings.org_babel_tangle")<CR>`                    |
| ` od!`     | org toggle timestamp type                                                                                  | `<Cmd>lua require("orgmode").action("org_mappings.org_toggle_timestamp_type")<CR>`           |
| ` oe`      | org export                                                                                                 | `<Cmd>lua require("orgmode").action("org_mappings.export")<CR>`                              |
| ` oi!`     | org timestamp (inactive)                                                                                   | `<Cmd>lua require("orgmode").action("org_mappings.org_time_stamp","true")<CR>`               |
| ` oi.`     | org timestamp                                                                                              | `<Cmd>lua require("orgmode").action("org_mappings.org_time_stamp")<CR>`                      |
| ` oiT`     | org insert todo                                                                                            | `<Cmd>lua require("orgmode").action("org_mappings.insert_todo_heading")<CR>`                 |
| ` oid`     | org deadline                                                                                               | `<Cmd>lua require("orgmode").action("org_mappings.org_deadline")<CR>`                        |
| ` oih`     | org insert headline (respect content)                                                                      | `<Cmd>lua require("orgmode").action("org_mappings.insert_heading_respect_content")<CR>`      |
| ` ois`     | org schedule                                                                                               | `<Cmd>lua require("orgmode").action("org_mappings.org_schedule")<CR>`                        |
| ` oit`     | org insert todo (respect content)                                                                          | `<Cmd>lua require("orgmode").action("org_mappings.insert_todo_heading_respect_content")<CR>` |
| ` oli`     | org insert link                                                                                            | `<Cmd>lua require("orgmode").action("org_mappings.insert_link")<CR>`                         |
| ` ols`     | org store link                                                                                             | `<Cmd>lua require("orgmode").action("org_mappings.store_link")<CR>`                          |
| ` ona`     | org add note                                                                                               | `<Cmd>lua require("orgmode").action("org_mappings.add_note")<CR>`                            |
| ` oo`      | org open                                                                                                   | `<Cmd>lua require("orgmode").action("org_mappings.open_at_point")<CR>`                       |
| ` or`      | org refile                                                                                                 | `<Cmd>lua require("orgmode").action("capture.refile_headline_to_destination")<CR>`           |
| ` ot`      | org set tags                                                                                               | `<Cmd>lua require("orgmode").action("org_mappings.set_tags")<CR>`                            |
| ` oxe`     | org set effort                                                                                             | `<Cmd>lua require("orgmode").action("clock.org_set_effort")<CR>`                             |
| ` oxi`     | org clock in                                                                                               | `<Cmd>lua require("orgmode").action("clock.org_clock_in")<CR>`                               |
| ` oxj`     | org clock goto                                                                                             | `<Cmd>lua require("orgmode").action("clock.org_clock_goto")<CR>`                             |
| ` oxo`     | org clock out                                                                                              | `<Cmd>lua require("orgmode").action("clock.org_clock_out")<CR>`                              |
| ` oxq`     | org clock cancel                                                                                           | `<Cmd>lua require("orgmode").action("clock.org_clock_cancel")<CR>`                           |
| `<C-A>`    | org increase timestamp                                                                                     | `<Cmd>lua require("orgmode").action("org_mappings.timestamp_up")<CR>`                        |
| `<C-X>`    | org decrease timestamp                                                                                     | `<Cmd>lua require("orgmode").action("org_mappings.timestamp_down")<CR>`                      |
| `<S-Down>` | org decrease timestamp (day)                                                                               | `<Cmd>lua require("orgmode").action("org_mappings.timestamp_down_day")<CR>`                  |
| `<S-Tab>`  | org toggle fold (whole file)                                                                               | `<Cmd>lua require("orgmode").action("org_mappings.global_cycle")<CR>`                        |
| `<S-Up>`   | org increase timestamp (day)                                                                               | `<Cmd>lua require("orgmode").action("org_mappings.timestamp_up_day")<CR>`                    |
| `<Tab>`    | org toggle fold                                                                                            | `<Cmd>lua require("orgmode").action("org_mappings.cycle")<CR>`                               |
| `<<`       | org promote headline                                                                                       | `<Cmd>lua require("orgmode").action("org_mappings.do_promote")<CR>`                          |
| `<s`       | org promote subtree                                                                                        | `<Cmd>lua require("orgmode").action("org_mappings.do_promote","true")<CR>`                   |
| `>>`       | org demote headline                                                                                        | `<Cmd>lua require("orgmode").action("org_mappings.do_demote")<CR>`                           |
| `>s`       | org demote subtree                                                                                         | `<Cmd>lua require("orgmode").action("org_mappings.do_demote","true")<CR>`                    |
| `[[`       | org prev headline (same level)                                                                             | `<Cmd>lua require("orgmode").action("org_mappings.backward_heading_same_level")<CR>`         |
| `]]`       | org next headline (same level)                                                                             | `<Cmd>lua require("orgmode").action("org_mappings.forward_heading_same_level")<CR>`          |
| `ciR`      | org increase priority                                                                                      | `<Cmd>lua require("orgmode").action("org_mappings.priority_up")<CR>`                         |
| `ciT`      | org prev todo state                                                                                        | `<Cmd>lua require("orgmode").action("org_mappings.todo_prev_state")<CR>`                     |
| `cid`      | org change date                                                                                            | `<Cmd>lua require("orgmode").action("org_mappings.change_date")<CR>`                         |
| `cir`      | org decrease priority                                                                                      | `<Cmd>lua require("orgmode").action("org_mappings.priority_down")<CR>`                       |
| `cit`      | org next todo state                                                                                        | `<Cmd>lua require("orgmode").action("org_mappings.todo_next_state")<CR>`                     |
| `g?`       | org show help                                                                                              | `<Cmd>lua require("orgmode").action("org_mappings.show_help","org")<CR>`                     |
| `gri`      | LSP textDocument/implementation (capability-checked)                                                       | `<Lua callback>`                                                                             |
| `grt`      | LSP textDocument/typeDefinition (capability-checked)                                                       | `<Lua callback>`                                                                             |
| `g{`       | org goto parent headline                                                                                   | `<Cmd>lua require("orgmode").action("org_mappings.outline_up_heading")<CR>`                  |
| `{`        | org prev visible headline                                                                                  | `<Cmd>lua require("orgmode").action("org_mappings.previous_visible_heading")<CR>`            |
| `}`        | org next visible headline                                                                                  | `<Cmd>lua require("orgmode").action("org_mappings.next_visible_heading")<CR>`                |

### Org buffers: Insert Mode

| Key    | Description | Command                                                             |
|--------|-------------|---------------------------------------------------------------------|
| `<CR>` | org return  | `<Cmd>lua require("orgmode").action("org_mappings.org_return")<CR>` |

### Org buffers: Visual + Select Mode

| Key     | Description                                                                                                | Command                                                                           |
|---------|------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|
| ` oRi`  | Inserts at cursor position the selected node, creating new one if missing                                  | `<Lua callback>`                                                                  |
| ` oRm`  | Inserts at cursor position the selected node, creating new one if missing without opening a capture buffer | `<Lua callback>`                                                                  |
| ` oli`  | org insert link                                                                                            | `<Cmd>lua require("orgmode").action("org_mappings.insert_link")<CR>`              |
| `<C-B>` | org: bold                                                                                                  | `<Lua callback>`                                                                  |
| `<C-E>` | org: code (source block when linewise)                                                                     | `<Lua callback>`                                                                  |
| `<C-I>` | org: italic                                                                                                | `<Lua callback>`                                                                  |
| `<C-K>` | org: link                                                                                                  | `<Lua callback>`                                                                  |
| `OH`    | Select around headline from root headline (orgmode)                                                        | `:<C-U>lua require("orgmode.org.text_objects").around_heading_from_root()<CR>`    |
| `OR`    | Select around subtree from root headline (orgmode)                                                         | `:<C-U>lua require("orgmode.org.text_objects").around_subtree_from_root()<CR>`    |
| `Oh`    | Select inner headline from root headline (orgmode)                                                         | `:<C-U>lua require("orgmode.org.text_objects").inner_heading_from_root()<CR>`     |
| `Or`    | Select inner subtree from root headline (orgmode)                                                          | `:<C-U>lua require("orgmode.org.text_objects").inner_subtree_from_root()<CR>`     |
| `a*`    | Select around bold markers (orgmode)                                                                       | `:<C-U>normal! F*vf*<CR>`                                                         |
| `a+`    | Select around strikethrough markers (orgmode)                                                              | `:<C-U>normal! F+vf+<CR>`                                                         |
| `a/`    | Select around italic markers (orgmode)                                                                     | `:<C-U>normal! F/vf/<CR>`                                                         |
| `a=`    | Select around verbatim markers (orgmode)                                                                   | `:<C-U>normal! F=vf=<CR>`                                                         |
| `a_`    | Select around underline markers (orgmode)                                                                  | `:<C-U>normal! F_vf_<CR>`                                                         |
| `ah`    | Select around headline (orgmode)                                                                           | `:<C-U>lua require("orgmode.org.text_objects").around_heading()<CR>`              |
| `ar`    | Select around subtree (orgmode)                                                                            | `:<C-U>lua require("orgmode.org.text_objects").around_subtree()<CR>`              |
| `a~`    | Select around code markers (orgmode)                                                                       | `:<C-U>normal! F~vf~<CR>`                                                         |
| `i*`    | Select inside bold markers (orgmode)                                                                       | `:<C-U>normal! T*vt*<CR>`                                                         |
| `i+`    | Select inside strikethrough markers (orgmode)                                                              | `:<C-U>normal! T+vt+<CR>`                                                         |
| `i/`    | Select inside italic markers (orgmode)                                                                     | `:<C-U>normal! T/vt/<CR>`                                                         |
| `i=`    | Select inside verbatim markers (orgmode)                                                                   | `:<C-U>normal! T=vt=<CR>`                                                         |
| `i_`    | Select inside underline markers (orgmode)                                                                  | `:<C-U>normal! T_vt_<CR>`                                                         |
| `ih`    | Select inner headline (orgmode)                                                                            | `:<C-U>lua require("orgmode.org.text_objects").inner_heading()<CR>`               |
| `ir`    | Select inner subtree (orgmode)                                                                             | `:<C-U>lua require("orgmode.org.text_objects").inner_subtree()<CR>`               |
| `i~`    | Select inside code markers (orgmode)                                                                       | `:<C-U>normal! T~vt~<CR>`                                                         |
| `{`     | org prev visible headline                                                                                  | `<Cmd>lua require("orgmode").action("org_mappings.previous_visible_heading")<CR>` |
| `}`     | org next visible headline                                                                                  | `<Cmd>lua require("orgmode").action("org_mappings.next_visible_heading")<CR>`     |

### Org buffers: Visual Mode

| Key     | Description                                                                                                | Command                                                                           |
|---------|------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|
| ` oRi`  | Inserts at cursor position the selected node, creating new one if missing                                  | `<Lua callback>`                                                                  |
| ` oRm`  | Inserts at cursor position the selected node, creating new one if missing without opening a capture buffer | `<Lua callback>`                                                                  |
| ` oli`  | org insert link                                                                                            | `<Cmd>lua require("orgmode").action("org_mappings.insert_link")<CR>`              |
| `<C-B>` | org: bold                                                                                                  | `<Lua callback>`                                                                  |
| `<C-E>` | org: code (source block when linewise)                                                                     | `<Lua callback>`                                                                  |
| `<C-I>` | org: italic                                                                                                | `<Lua callback>`                                                                  |
| `<C-K>` | org: link                                                                                                  | `<Lua callback>`                                                                  |
| `OH`    | Select around headline from root headline (orgmode)                                                        | `:<C-U>lua require("orgmode.org.text_objects").around_heading_from_root()<CR>`    |
| `OR`    | Select around subtree from root headline (orgmode)                                                         | `:<C-U>lua require("orgmode.org.text_objects").around_subtree_from_root()<CR>`    |
| `Oh`    | Select inner headline from root headline (orgmode)                                                         | `:<C-U>lua require("orgmode.org.text_objects").inner_heading_from_root()<CR>`     |
| `Or`    | Select inner subtree from root headline (orgmode)                                                          | `:<C-U>lua require("orgmode.org.text_objects").inner_subtree_from_root()<CR>`     |
| `a*`    | Select around bold markers (orgmode)                                                                       | `:<C-U>normal! F*vf*<CR>`                                                         |
| `a+`    | Select around strikethrough markers (orgmode)                                                              | `:<C-U>normal! F+vf+<CR>`                                                         |
| `a/`    | Select around italic markers (orgmode)                                                                     | `:<C-U>normal! F/vf/<CR>`                                                         |
| `a=`    | Select around verbatim markers (orgmode)                                                                   | `:<C-U>normal! F=vf=<CR>`                                                         |
| `a_`    | Select around underline markers (orgmode)                                                                  | `:<C-U>normal! F_vf_<CR>`                                                         |
| `ah`    | Select around headline (orgmode)                                                                           | `:<C-U>lua require("orgmode.org.text_objects").around_heading()<CR>`              |
| `ar`    | Select around subtree (orgmode)                                                                            | `:<C-U>lua require("orgmode.org.text_objects").around_subtree()<CR>`              |
| `a~`    | Select around code markers (orgmode)                                                                       | `:<C-U>normal! F~vf~<CR>`                                                         |
| `i*`    | Select inside bold markers (orgmode)                                                                       | `:<C-U>normal! T*vt*<CR>`                                                         |
| `i+`    | Select inside strikethrough markers (orgmode)                                                              | `:<C-U>normal! T+vt+<CR>`                                                         |
| `i/`    | Select inside italic markers (orgmode)                                                                     | `:<C-U>normal! T/vt/<CR>`                                                         |
| `i=`    | Select inside verbatim markers (orgmode)                                                                   | `:<C-U>normal! T=vt=<CR>`                                                         |
| `i_`    | Select inside underline markers (orgmode)                                                                  | `:<C-U>normal! T_vt_<CR>`                                                         |
| `ih`    | Select inner headline (orgmode)                                                                            | `:<C-U>lua require("orgmode.org.text_objects").inner_heading()<CR>`               |
| `ir`    | Select inner subtree (orgmode)                                                                             | `:<C-U>lua require("orgmode.org.text_objects").inner_subtree()<CR>`               |
| `i~`    | Select inside code markers (orgmode)                                                                       | `:<C-U>normal! T~vt~<CR>`                                                         |
| `{`     | org prev visible headline                                                                                  | `<Cmd>lua require("orgmode").action("org_mappings.previous_visible_heading")<CR>` |
| `}`     | org next visible headline                                                                                  | `<Cmd>lua require("orgmode").action("org_mappings.next_visible_heading")<CR>`     |

### Org buffers: Select Mode

| Key    | Description                                                                                                | Command          |
|--------|------------------------------------------------------------------------------------------------------------|------------------|
| ` oRi` | Inserts at cursor position the selected node, creating new one if missing                                  | `<Lua callback>` |
| ` oRm` | Inserts at cursor position the selected node, creating new one if missing without opening a capture buffer | `<Lua callback>` |

### Org buffers: Operator-pending Mode

| Key  | Description                                         | Command           |
|------|-----------------------------------------------------|-------------------|
| `OH` | Select around headline from root headline (orgmode) | `:normal vOH<CR>` |
| `OR` | Select around subtree from root headline (orgmode)  | `:normal vOR<CR>` |
| `Oh` | Select inner headline from root headline (orgmode)  | `:normal vOh<CR>` |
| `Or` | Select inner subtree from root headline (orgmode)   | `:normal vOr<CR>` |
| `a*` | Select around bold markers (orgmode)                | `:normal va*<CR>` |
| `a+` | Select around strikethrough markers (orgmode)       | `:normal va+<CR>` |
| `a/` | Select around italic markers (orgmode)              | `:normal va/<CR>` |
| `a=` | Select around verbatim markers (orgmode)            | `:normal va=<CR>` |
| `a_` | Select around underline markers (orgmode)           | `:normal va_<CR>` |
| `ah` | Select around headline (orgmode)                    | `:normal vah<CR>` |
| `ar` | Select around subtree (orgmode)                     | `:normal var<CR>` |
| `a~` | Select around code markers (orgmode)                | `:normal va~<CR>` |
| `i*` | Select inside bold markers (orgmode)                | `:normal vi*<CR>` |
| `i+` | Select inside strikethrough markers (orgmode)       | `:normal vi+<CR>` |
| `i/` | Select inside italic markers (orgmode)              | `:normal vi/<CR>` |
| `i=` | Select inside verbatim markers (orgmode)            | `:normal vi=<CR>` |
| `i_` | Select inside underline markers (orgmode)           | `:normal vi_<CR>` |
| `ih` | Select inner headline (orgmode)                     | `:normal vih<CR>` |
| `ir` | Select inner subtree (orgmode)                      | `:normal vir<CR>` |
| `i~` | Select inside code markers (orgmode)                | `:normal vi~<CR>` |

- Generated on 2026-10-30
