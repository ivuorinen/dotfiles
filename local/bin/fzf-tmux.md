# fzf-tmux

Wrapper around [`fzf`](https://github.com/junegunn/fzf) that opens the
interface inside a tmux pane or popup.

## Usage

```bash
fzf-tmux [layout options] [--] [fzf options]
```

Layout flags like `-p` or `-d` control popup and split behaviour. Use
`--` to pass arguments directly to `fzf`.

### Example

```bash
fzf-tmux -p 80%,60% -- --reverse
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
