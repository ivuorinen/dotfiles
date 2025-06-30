# t

Launch or switch to a tmux session based on a directory selected with
`fzf`. Inspired by scripts from ThePrimeagen and Jess Archer.

## Usage

```bash
t
```

Environment variables:

- `T_ROOT` – base directory to search (default: `~/Code`)
- `T_MAX_DEPTH` – recursion depth for directory search

### Example

```bash
T_ROOT=~/projects t
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
