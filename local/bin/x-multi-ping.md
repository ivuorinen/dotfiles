# x-multi-ping

Multi-protocol ping helper supporting IPv4 and IPv6.

## Usage

```bash
x-multi-ping [--loop] [--sleep=N] host1 host2...
```

- `--loop` – ping continuously
- `--sleep` – seconds to wait between iterations

## Example

```bash
x-multi-ping --loop --sleep=5 example.com
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
