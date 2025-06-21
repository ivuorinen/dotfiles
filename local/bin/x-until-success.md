# x-until-success

Repeat a command until it succeeds (exit status 0). The command is
always executed at least once.

## Usage

```bash
x-until-success [--sleep SECONDS] command [args...]
```

Use `--sleep` to control the delay between attempts.

### Example

```bash
x-until-success --sleep 5 curl -I https://example.com
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
