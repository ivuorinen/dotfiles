# msgr

Helper library for printing colorized log messages from shell scripts.

## Usage

```bash
msgr <type> "message" [extra]
```

Message types include `ok`, `warn`, `err`, `run` and many more. The
script is primarily sourced by other scripts.

### Example

```bash
msgr ok "Installation complete"
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
