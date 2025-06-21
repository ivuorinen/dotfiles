# x-until-error

Repeatedly execute a command until it returns a non-zero exit status.

## Usage

```bash
x-until-error [--sleep SECONDS] command [args...]
```

Use `--sleep` to wait between runs. The command is executed at least
once.

### Example

```bash
x-until-error --sleep 2 ping -c1 example.com
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
