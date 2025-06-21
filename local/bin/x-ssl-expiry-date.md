# x-ssl-expiry-date

Check the expiry date of an SSL certificate for one or more hosts.

## Usage

```bash
x-ssl-expiry-date [-d] [-p PORT] host1 host2 ...
```

Options:

- `-d` – show days left instead of the full date
- `-p <port>` – use custom port (default: 443)

### Example

```bash
x-ssl-expiry-date -d github.com
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
