# x-localip

Display local IPv4 and IPv6 addresses with optional interface filtering.

## Usage

```bash
x-localip [--ipv4] [--ipv6] [interface]
```

- `--ipv4` – show only IPv4 addresses
- `--ipv6` – show only IPv6 addresses
- `interface` – limit output to the named interface

## Example

```bash
# Show all addresses
x-localip

# IPv4 for wlan0
x-localip --ipv4 wlan0
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
