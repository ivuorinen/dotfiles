# x-env-list

Lists environment variables grouped by their prefix. Sensitive values
are hidden by default.

## Usage

```bash
x-env-list [options]
```

Use `--json` for machine readable output or specify
`X_ENV_GROUPING` with a YAML file to override the default groups.

### Example

```bash
X_ENV_GROUPING=~/env-groups.yaml x-env-list --json
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
