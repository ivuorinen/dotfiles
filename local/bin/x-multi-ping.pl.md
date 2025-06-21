# x-multi-ping.pl

Ping multiple hosts with IPv4/IPv6 support.

## Usage

```bash
x-multi-ping.pl [--loop|--forever] [--sleep N] host1 host2 ...
```

`--loop` keeps pinging each host until interrupted. `--sleep` controls
the delay between attempts.

### Example

```bash
x-multi-ping.pl --loop --sleep 2 example.com 1.1.1.1
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
