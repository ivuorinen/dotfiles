# Shell Keybindings

Shell stack: **fish** (interactive primary), bash, zsh (sourced via antidote).
All shells share `config/exports` and `config/alias` via `config/shared.sh`.

## Readline / Emacs Defaults (bash, zsh)

Fish uses emacs mode by default. These bindings apply in all three shells.

### Cursor Movement

| Key          | Action                      |
|--------------|-----------------------------|
| `Ctrl-a`     | Move to beginning of line   |
| `Ctrl-e`     | Move to end of line         |
| `Ctrl-f`     | Move forward one character  |
| `Ctrl-b`     | Move backward one character |
| `Alt-f`      | Move forward one word       |
| `Alt-b`      | Move backward one word      |
| `Ctrl-Left`  | Move backward one word      |
| `Ctrl-Right` | Move forward one word       |

### Editing

| Key         | Action                                  |
|-------------|-----------------------------------------|
| `Ctrl-d`    | Delete character under cursor (or EOF)  |
| `Ctrl-h`    | Delete character before cursor          |
| `Backspace` | Delete character before cursor          |
| `Ctrl-w`    | Delete word before cursor               |
| `Alt-d`     | Delete word after cursor                |
| `Ctrl-k`    | Kill (cut) from cursor to end of line   |
| `Ctrl-u`    | Kill from cursor to beginning of line   |
| `Ctrl-y`    | Yank (paste) last killed text           |
| `Ctrl-t`    | Transpose characters (bash/zsh default) |
| `Alt-t`     | Transpose words                         |
| `Alt-u`     | Uppercase word                          |
| `Alt-l`     | Lowercase word                          |
| `Alt-c`     | Capitalise word                         |

### History

| Key            | Action                                                     |
|----------------|------------------------------------------------------------|
| `Ctrl-r`       | **→ tv** `fish-history` channel (overrides reverse search) |
| `Ctrl-p` / `↑` | Previous history entry                                     |
| `Ctrl-n` / `↓` | Next history entry                                         |
| `Alt-<`        | First history entry                                        |
| `Alt->`        | Last history entry                                         |

### Screen

| Key      | Action       |
|----------|--------------|
| `Ctrl-l` | Clear screen |

### Signals

| Key      | Action                             |
|----------|------------------------------------|
| `Ctrl-c` | Interrupt (SIGINT) current process |
| `Ctrl-z` | Suspend (SIGTSTP) current process  |
| `Ctrl-\` | Quit (SIGQUIT) current process     |

## Fish Shell Defaults

Fish inherits the emacs bindings above and adds:

### Completion

| Key         | Action                                       |
|-------------|----------------------------------------------|
| `Tab`       | Complete / show completions                  |
| `Shift-Tab` | Previous completion suggestion               |
| `Alt-e`     | Edit command in `$EDITOR`                    |
| `Alt-l`     | List contents of directory at cursor         |
| `Alt-p`     | Page output of command at cursor             |
| `Alt-w`     | Print short description of command at cursor |

### History Search

| Key      | Action                              |
|----------|-------------------------------------|
| `Alt-↑`  | Search history for previous token   |
| `Alt-↓`  | Search history for next token       |
| `Ctrl-r` | **→ tv** `fish-history` (see below) |

### Process

| Key      | Action                            |
|----------|-----------------------------------|
| `Ctrl-d` | Delete character or exit if empty |
| `Ctrl-c` | Cancel current command line       |

## Television Integration (fish)

Set up by `tv init fish | source` in `config/fish/config.fish`.

| Key      | Action                                                                 |
|----------|------------------------------------------------------------------------|
| `Ctrl-r` | Open `fish-history` channel (command history picker)                   |
| `Ctrl-t` | Smart autocomplete — opens a channel based on the command typed so far |

`Ctrl-t` is context-sensitive via channel triggers. See [tv.md](tv.md#channel-triggers) for the full trigger table.

## Tmux

tmux prefix: `Ctrl-Space` (replaces default `Ctrl-b`)

See [tmux-keybindings.md](tmux-keybindings.md) for the full reference.

Key bindings relevant to shell workflow:

| Key                       | Action                                |
|---------------------------|---------------------------------------|
| `Ctrl-Left/Right/Up/Down` | Switch panes (no prefix required)     |
| `prefix + t`              | Session picker (`tv sesh` in a popup) |
| `prefix + L`              | Jump to last session (`sesh last`)    |
| `prefix + N`              | Open `sesh ui`                        |
| `prefix + C-p`            | Previous window                       |
| `prefix + C-n`            | Next window                           |
| `prefix + r`              | Reload tmux config                    |
| `prefix + Escape`         | Enter copy mode (vi bindings)         |
| `prefix + p`              | Paste buffer                          |

### Copy Mode (vi)

| Key | Action                             |
|-----|------------------------------------|
| `y` | Copy selection to system clipboard |
| `Y` | Copy selection and paste           |
