# x-when-up

Wait for a host to respond to ping before running a command.

## Usage

```bash
x-when-up <host> <command...>
```

If the command is `ssh`, the host argument may be omitted.

## Example

```bash
x-when-up 1.2.3.4 ssh 1.2.3.4
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
