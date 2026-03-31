# Neovim Keybindings

## Normal Mode

| Key          | Description                                                                                | Command                                                 |
|--------------|--------------------------------------------------------------------------------------------|---------------------------------------------------------|
| ` ,`         | Find existing buffers                                                                      | `:Telescope buffers<CR>`                                |
| ` ba`        | Close all except current                                                                   | `:%bd\|e#\|bd#<CR>`                                     |
| ` bd`        | Delete buf                                                                                 | `:lua MiniBufremove.delete()<CR>`                       |
| ` bh`        | Prev buf                                                                                   | `:bprev<CR>`                                            |
| ` bj`        | First buf                                                                                  | `:bfirst<CR>`                                           |
| ` bk`        | Last buf                                                                                   | `:blast<CR>`                                            |
| ` bl`        | Next buf                                                                                   | `:bnext<CR>`                                            |
| ` bw`        | Wipeout                                                                                    | `:lua MiniBufremove.wipeout()<CR>`                      |
| ` cbb`       | CB: Box Title                                                                              | `<Cmd>CBccbox<CR>`                                      |
| ` cbd`       | CB: Remove a box                                                                           | `<Cmd>CBd<CR>`                                          |
| ` cbl`       | CB: Simple Line                                                                            | `<Cmd>CBline<CR>`                                       |
| ` cbm`       | CB: Marked                                                                                 | `<Cmd>CBllbox14<CR>`                                    |
| ` cbt`       | CB: Titled Line                                                                            | `<Cmd>CBllline<CR>`                                     |
| ` cci`       | Incoming calls                                                                             | `<Lua callback>`                                        |
| ` cco`       | Outgoing calls                                                                             | `<Lua callback>`                                        |
| ` cd`        | Definitions                                                                                | `<Lua callback>`                                        |
| ` cf`        | Format                                                                                     | `:lua vim.lsp.buf.format()<CR>`                         |
| ` ci`        | Implementations                                                                            | `<Lua callback>`                                        |
| ` cp`        | Type Definition                                                                            | `<Lua callback>`                                        |
| ` cs`        | LSP Document Symbols                                                                       | `:Telescope lsp_document_symbols<CR>`                   |
| ` ct`        | treesitter                                                                                 | `<Lua callback>`                                        |
| ` cwd`       | Dynamic Workspace Symbols                                                                  | `<Lua callback>`                                        |
| ` cws`       | Workspace Symbols                                                                          | `<Lua callback>`                                        |
| ` f`         | Find Files                                                                                 | `:Telescope find_files<CR>`                             |
| ` qf`        | Quicker close split                                                                        | `:q<CR>`                                                |
| ` sd`        | Search Diagnostics                                                                         | `:Telescope diagnostics<CR>`                            |
| ` sf`        | Grep String                                                                                | `:Telescope grep_string<CR>`                            |
| ` sg`        | Live Grep                                                                                  | `:Telescope live_grep<CR>`                              |
| ` sh`        | Help tags                                                                                  | `:Telescope help_tags<CR>`                              |
| ` sk`        | Search Keymaps                                                                             | `:Telescope keymaps<CR>`                                |
| ` sn`        | Noice Messages                                                                             | `:Noice telescope<CR>`                                  |
| ` so`        | Old Files                                                                                  | `:Telescope oldfiles<CR>`                               |
| ` sp`        | Lazy Plugins                                                                               | `<Lua callback>`                                        |
| ` sq`        | Quickfix                                                                                   | `:Telescope quickfix<CR>`                               |
| ` ss`        | Treesitter                                                                                 | `:Telescope treesitter<CR>`                             |
| ` sx`        | Telescope: Import                                                                          | `:Telescope import<CR>`                                 |
| ` te`        | File Explorer (cwd)                                                                        | `<Lua callback>`                                        |
| ` tf`        | Toggle autoformat on save                                                                  | `:ToggleFormat<CR>`                                     |
| ` tl`        | Toggle Light/Dark Mode                                                                     | `<Lua callback>`                                        |
| ` tmC`       | Toggle cursorcolumn                                                                        | `<Lua callback>`                                        |
| ` tmc`       | Toggle cursorline                                                                          | `<Lua callback>`                                        |
| ` tmd`       | Toggle diagnostics                                                                         | `<Lua callback>`                                        |
| ` tmh`       | Toggle hlsearch                                                                            | `<Lua callback>`                                        |
| ` tml`       | Toggle list                                                                                | `<Lua callback>`                                        |
| ` tmm`       | Toggle markdown render                                                                     | `:RenderMarkdown toggle<CR>`                            |
| ` tmn`       | Toggle number                                                                              | `<Lua callback>`                                        |
| ` tmr`       | Toggle relativenumber                                                                      | `<Lua callback>`                                        |
| ` tms`       | Toggle spell                                                                               | `<Lua callback>`                                        |
| ` tmw`       | Toggle wrap                                                                                | `<Lua callback>`                                        |
| ` tn`        | Noice: Dismiss Notification                                                                | `:Noice dismiss<CR>`                                    |
| ` xc`        | Cascade (most severe)                                                                      | `:Trouble cascade<CR>`                                  |
| ` xl`        | Location List                                                                              | `:Trouble loclist<CR>`                                  |
| ` xq`        | Quickfix                                                                                   | `:Trouble quickfix<CR>`                                 |
| ` xt`        | Test (split preview)                                                                       | `:Trouble test<CR>`                                     |
| ` xx`        | Diagnostics                                                                                | `:Trouble diagnostics<CR>`                              |
| `%`          | Go to matching bracket (matchit)                                                           | `<Plug>(MatchitNormalForward)`                          |
| `&`          | :help &amp;-default                                                                        | `:&&<CR>`                                               |
| `-`          | File Explorer (current file)                                                               | `<Lua callback>`                                        |
| `<C-J>`      | Move Block Down                                                                            | `:m '>+1<CR>gv=gv`                                      |
| `<C-K>`      | Move Block Up                                                                              | `:m '<-2<CR>gv=gv`                                      |
| `<C-L>`      | Signature                                                                                  | `:lua vim.lsp.buf.signature_help()<CR>`                 |
| `<C-S>`      | Save                                                                                       | `:w!<CR>`                                               |
| `<C-W>+`     | H Resize +                                                                                 | `:resize +10<CR>`                                       |
| `<C-W>,`     | V Resize -                                                                                 | `:vertical resize -10<CR>`                              |
| `<C-W>-`     | H Resize -                                                                                 | `:resize -10<CR>`                                       |
| `<C-W>.`     | V Resize +                                                                                 | `:vertical resize +10<CR>`                              |
| `<C-W><C-D>` | Show diagnostics under the cursor                                                          | `<C-W>d`                                                |
| `<C-W>d`     | Show diagnostics under the cursor                                                          | `<Lua callback>`                                        |
| `<`          | Indent Left                                                                                | `<gv`                                                   |
| `>`          | Indent Right                                                                               | `>gv`                                                   |
| `@`          | Execute macro without 'mini.clue' triggers                                                 | `<Lua callback>`                                        |
| `Q`          | Execute macro without 'mini.clue' triggers                                                 | `<Lua callback>`                                        |
| `Y`          | :help Y-default                                                                            | `y$`                                                    |
| `[ `         | Add empty line above cursor                                                                | `<Lua callback>`                                        |
| `[%`         | Previous unmatched group (matchit)                                                         | `<Plug>(MatchitNormalMultiBackward)`                    |
| `[<C-L>`     | :lpfile                                                                                    | `<Lua callback>`                                        |
| `[<C-Q>`     | :cpfile                                                                                    | `<Lua callback>`                                        |
| `[<C-T>`     | :ptprevious                                                                                | `<Lua callback>`                                        |
| `[A`         | :rewind                                                                                    | `<Lua callback>`                                        |
| `[B`         | :brewind                                                                                   | `<Lua callback>`                                        |
| `[D`         | Jump to the first diagnostic in the current buffer                                         | `<Lua callback>`                                        |
| `[H`         | First hunk                                                                                 | `<Cmd>lua MiniDiff.goto_hunk('first')<CR>`              |
| `[L`         | :lrewind                                                                                   | `<Lua callback>`                                        |
| `[Q`         | :crewind                                                                                   | `<Lua callback>`                                        |
| `[T`         | :trewind                                                                                   | `<Lua callback>`                                        |
| `[a`         | :previous                                                                                  | `<Lua callback>`                                        |
| `[b`         | :bprevious                                                                                 | `<Lua callback>`                                        |
| `[d`         | Jump to the previous diagnostic in the current buffer                                      | `<Lua callback>`                                        |
| `[h`         | Previous hunk                                                                              | `<Cmd>lua MiniDiff.goto_hunk('prev')<CR>`               |
| `[i`         | Go to indent scope top                                                                     | `<Cmd>lua MiniIndentscope.operator('top', true)<CR>`    |
| `[l`         | :lprevious                                                                                 | `<Lua callback>`                                        |
| `[q`         | :cprevious                                                                                 | `<Lua callback>`                                        |
| `[t`         | :tprevious                                                                                 | `<Lua callback>`                                        |
| `] `         | Add empty line below cursor                                                                | `<Lua callback>`                                        |
| `]%`         | Next unmatched group (matchit)                                                             | `<Plug>(MatchitNormalMultiForward)`                     |
| `]<C-L>`     | :lnfile                                                                                    | `<Lua callback>`                                        |
| `]<C-Q>`     | :cnfile                                                                                    | `<Lua callback>`                                        |
| `]<C-T>`     | :ptnext                                                                                    | `<Lua callback>`                                        |
| `]A`         | :last                                                                                      | `<Lua callback>`                                        |
| `]B`         | :blast                                                                                     | `<Lua callback>`                                        |
| `]D`         | Jump to the last diagnostic in the current buffer                                          | `<Lua callback>`                                        |
| `]H`         | Last hunk                                                                                  | `<Cmd>lua MiniDiff.goto_hunk('last')<CR>`               |
| `]L`         | :llast                                                                                     | `<Lua callback>`                                        |
| `]Q`         | :clast                                                                                     | `<Lua callback>`                                        |
| `]T`         | :tlast                                                                                     | `<Lua callback>`                                        |
| `]a`         | :next                                                                                      | `<Lua callback>`                                        |
| `]b`         | :bnext                                                                                     | `<Lua callback>`                                        |
| `]d`         | Jump to the next diagnostic in the current buffer                                          | `<Lua callback>`                                        |
| `]h`         | Next hunk                                                                                  | `<Cmd>lua MiniDiff.goto_hunk('next')<CR>`               |
| `]i`         | Go to indent scope bottom                                                                  | `<Cmd>lua MiniIndentscope.operator('bottom', true)<CR>` |
| `]l`         | :lnext                                                                                     | `<Lua callback>`                                        |
| `]q`         | :cnext                                                                                     | `<Lua callback>`                                        |
| `]t`         | :tnext                                                                                     | `<Lua callback>`                                        |
| `g%`         | Reverse matching bracket (matchit)                                                         | `<Plug>(MatchitNormalBackward)`                         |
| `g=`         | Evaluate                                                                                   | `v:lua.MiniOperators.evaluate()`                        |
| `g=​=`       | Evaluate line                                                                              | `g=_`                                                   |
| `gH`         | Reset hunks                                                                                | `<Lua callback>`                                        |
| `gO`         | vim.lsp.buf.document_symbol()                                                              | `<Lua callback>`                                        |
| `gR`         | Replace                                                                                    | `v:lua.MiniOperators.replace()`                         |
| `gRR`        | Replace line                                                                               | `gR_`                                                   |
| `gS`         | Toggle arguments                                                                           | `v:lua.MiniSplitjoin.operator("toggle") . " "`          |
| `gX`         | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) | `<Lua callback>`                                        |
| `g[`         | Move to left "around"                                                                      | `<Lua callback>`                                        |
| `g]`         | Move to right "around"                                                                     | `<Lua callback>`                                        |
| `gc`         | Toggle comment                                                                             | `<Lua callback>`                                        |
| `gcc`        | Toggle comment line                                                                        | `<Lua callback>`                                        |
| `gh`         | Apply hunks                                                                                | `<Lua callback>`                                        |
| `gm`         | Multiply                                                                                   | `v:lua.MiniOperators.multiply()`                        |
| `gmm`        | Multiply line                                                                              | `gm_`                                                   |
| `gra`        | vim.lsp.buf.code_action()                                                                  | `<Lua callback>`                                        |
| `gri`        | vim.lsp.buf.implementation()                                                               | `<Lua callback>`                                        |
| `grn`        | vim.lsp.buf.rename()                                                                       | `<Lua callback>`                                        |
| `grr`        | vim.lsp.buf.references()                                                                   | `<Lua callback>`                                        |
| `grt`        | vim.lsp.buf.type_definition()                                                              | `<Lua callback>`                                        |
| `gs`         | Sort                                                                                       | `v:lua.MiniOperators.sort()`                            |
| `gss`        | Sort line                                                                                  | `^gsg_`                                                 |
| `gx`         | Exchange                                                                                   | `v:lua.MiniOperators.exchange()`                        |
| `gxx`        | Exchange line                                                                              | `gx_`                                                   |
| `j`          | Move down                                                                                  | `v:count =​= 0 ? 'gj' : 'j'`                            |
| `k`          | Move up                                                                                    | `v:count =​= 0 ? 'gk' : 'k'`                            |
| `s`          | Surround (mini.surround)                                                                   | `<Lua callback>`                                        |
| `sF`         | Find left surrounding                                                                      | `<Lua callback>`                                        |
| `sFl`        | Find previous left surrounding                                                             | `<Lua callback>`                                        |
| `sFn`        | Find next left surrounding                                                                 | `<Lua callback>`                                        |
| `sa`         | Add surrounding                                                                            | `<Lua callback>`                                        |
| `sd`         | Delete surrounding                                                                         | `<Lua callback>`                                        |
| `sdl`        | Delete previous surrounding                                                                | `<Lua callback>`                                        |
| `sdn`        | Delete next surrounding                                                                    | `<Lua callback>`                                        |
| `sf`         | Find right surrounding                                                                     | `<Lua callback>`                                        |
| `sfl`        | Find previous right surrounding                                                            | `<Lua callback>`                                        |
| `sfn`        | Find next right surrounding                                                                | `<Lua callback>`                                        |
| `sh`         | Highlight surrounding                                                                      | `<Lua callback>`                                        |
| `shl`        | Highlight previous surrounding                                                             | `<Lua callback>`                                        |
| `shn`        | Highlight next surrounding                                                                 | `<Lua callback>`                                        |
| `sr`         | Replace surrounding                                                                        | `<Lua callback>`                                        |
| `srl`        | Replace previous surrounding                                                               | `<Lua callback>`                                        |
| `srn`        | Replace next surrounding                                                                   | `<Lua callback>`                                        |

## Insert Mode

| Key       | Description                                         | Command          |
|-----------|-----------------------------------------------------|------------------|
| `<C-S>`   | vim.lsp.buf.signature_help()                        | `<Lua callback>` |
| `<C-U>`   | :help i_CTRL-U-default                              | `<C-G>u<C-U>`    |
| `<C-W>`   | :help i_CTRL-W-default                              | `<C-G>u<C-W>`    |
| `<S-Tab>` | vim.snippet.jump if active, otherwise &lt;S-Tab&gt; | `<Lua callback>` |
| `<Tab>`   | vim.snippet.jump if active, otherwise &lt;Tab&gt;   | `<Lua callback>` |

## Visual + Select Mode

| Key       | Description                                                                                | Command                                                                              |
|-----------|--------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| ` cf`     | Format                                                                                     | `:lua vim.lsp.buf.format()<CR>`                                                      |
| `#`       | :help v_#-default                                                                          | `<Lua callback>`                                                                     |
| `%`       | Go to matching bracket (matchit)                                                           | `<Plug>(MatchitVisualForward)`                                                       |
| `*`       | :help v_star-default                                                                       | `<Lua callback>`                                                                     |
| `<C-J>`   | Move Block Down                                                                            | `:m '>+1<CR>gv=gv`                                                                   |
| `<C-K>`   | Move Block Up                                                                              | `:m '<-2<CR>gv=gv`                                                                   |
| `<C-S>`   | vim.lsp.buf.signature_help()                                                               | `<Lua callback>`                                                                     |
| `<S-Tab>` | vim.snippet.jump if active, otherwise &lt;S-Tab&gt;                                        | `<Lua callback>`                                                                     |
| `<Tab>`   | vim.snippet.jump if active, otherwise &lt;Tab&gt;                                          | `<Lua callback>`                                                                     |
| `<`       | Indent Left                                                                                | `<gv`                                                                                |
| `>`       | Indent Right                                                                               | `>gv`                                                                                |
| `@`       | :help v_@-default                                                                          | `mode() =​=# 'V' ? ':normal! @'.getcharstr().'<CR>' : '@'`                           |
| `Q`       | :help v_Q-default                                                                          | `mode() =​=# 'V' ? ':normal! @<C-R>=reg_recorded()<CR><CR>' : 'Q'`                   |
| `[%`      | Previous unmatched group (matchit)                                                         | `<Plug>(MatchitVisualMultiBackward)`                                                 |
| `[H`      | First hunk                                                                                 | `<Cmd>lua MiniDiff.goto_hunk('first')<CR>`                                           |
| `[h`      | Previous hunk                                                                              | `<Cmd>lua MiniDiff.goto_hunk('prev')<CR>`                                            |
| `[i`      | Go to indent scope top                                                                     | `<Cmd>lua MiniIndentscope.operator('top')<CR>`                                       |
| `]%`      | Next unmatched group (matchit)                                                             | `<Plug>(MatchitVisualMultiForward)`                                                  |
| `]H`      | Last hunk                                                                                  | `<Cmd>lua MiniDiff.goto_hunk('last')<CR>`                                            |
| `]h`      | Next hunk                                                                                  | `<Cmd>lua MiniDiff.goto_hunk('next')<CR>`                                            |
| `]i`      | Go to indent scope bottom                                                                  | `<Cmd>lua MiniIndentscope.operator('bottom')<CR>`                                    |
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
| `gc`      | Toggle comment                                                                             | `<Lua callback>`                                                                     |
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

## Visual Mode

| Key     | Description                                                                                | Command                                                                              |
|---------|--------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| ` cf`   | Format                                                                                     | `:lua vim.lsp.buf.format()<CR>`                                                      |
| `#`     | :help v_#-default                                                                          | `<Lua callback>`                                                                     |
| `%`     | Go to matching bracket (matchit)                                                           | `<Plug>(MatchitVisualForward)`                                                       |
| `*`     | :help v_star-default                                                                       | `<Lua callback>`                                                                     |
| `<C-J>` | Move Block Down                                                                            | `:m '>+1<CR>gv=gv`                                                                   |
| `<C-K>` | Move Block Up                                                                              | `:m '<-2<CR>gv=gv`                                                                   |
| `<`     | Indent Left                                                                                | `<gv`                                                                                |
| `>`     | Indent Right                                                                               | `>gv`                                                                                |
| `@`     | :help v_@-default                                                                          | `mode() =​=# 'V' ? ':normal! @'.getcharstr().'<CR>' : '@'`                           |
| `Q`     | :help v_Q-default                                                                          | `mode() =​=# 'V' ? ':normal! @<C-R>=reg_recorded()<CR><CR>' : 'Q'`                   |
| `[%`    | Previous unmatched group (matchit)                                                         | `<Plug>(MatchitVisualMultiBackward)`                                                 |
| `[H`    | First hunk                                                                                 | `<Cmd>lua MiniDiff.goto_hunk('first')<CR>`                                           |
| `[h`    | Previous hunk                                                                              | `<Cmd>lua MiniDiff.goto_hunk('prev')<CR>`                                            |
| `[i`    | Go to indent scope top                                                                     | `<Cmd>lua MiniIndentscope.operator('top')<CR>`                                       |
| `]%`    | Next unmatched group (matchit)                                                             | `<Plug>(MatchitVisualMultiForward)`                                                  |
| `]H`    | Last hunk                                                                                  | `<Cmd>lua MiniDiff.goto_hunk('last')<CR>`                                            |
| `]h`    | Next hunk                                                                                  | `<Cmd>lua MiniDiff.goto_hunk('next')<CR>`                                            |
| `]i`    | Go to indent scope bottom                                                                  | `<Cmd>lua MiniIndentscope.operator('bottom')<CR>`                                    |
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
| `gc`    | Toggle comment                                                                             | `<Lua callback>`                                                                     |
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

## Select Mode

| Key       | Description                                         | Command            |
|-----------|-----------------------------------------------------|--------------------|
| `<C-J>`   | Move Block Down                                     | `:m '>+1<CR>gv=gv` |
| `<C-K>`   | Move Block Up                                       | `:m '<-2<CR>gv=gv` |
| `<C-S>`   | vim.lsp.buf.signature_help()                        | `<Lua callback>`   |
| `<S-Tab>` | vim.snippet.jump if active, otherwise &lt;S-Tab&gt; | `<Lua callback>`   |
| `<Tab>`   | vim.snippet.jump if active, otherwise &lt;Tab&gt;   | `<Lua callback>`   |
| `<`       | Indent Left                                         | `<gv`              |
| `>`       | Indent Right                                        | `>gv`              |

## Operator-pending Mode

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
| `gc`  | Comment textobject                 | `<Lua callback>`                                  |
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

- Generated on 2026-03-31
