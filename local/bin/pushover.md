# pushover

Send notifications via the Pushover API.

## Usage

```bash
pushover -T <token> -U <user> [-t title] [-p priority] message
```

Common options:

- `-c <callback>` – callback URL
- `-d <device>` – target device
- `-s <sound>` – notification sound name
- `-T <token>` – application token (or `PUSHOVER_TOKEN` env)
- `-U <user>` – user key (or `PUSHOVER_USER` env)

## Example

```bash
pushover -T $TOKEN -U $USER -t "Build" "Finished successfully"
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
