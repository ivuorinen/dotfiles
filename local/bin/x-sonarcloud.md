# x-sonarcloud

---

## Usage

```bash
x-sonarcloud                                    # Auto-detect, all open issues
x-sonarcloud --pr <number>                      # PR-specific issues
x-sonarcloud --branch <name>                    # Branch-specific issues
x-sonarcloud --org <org> --project-key <key>    # Explicit project
x-sonarcloud --severities BLOCKER,CRITICAL      # Filter by severity
x-sonarcloud --types BUG,VULNERABILITY          # Filter by type
x-sonarcloud --statuses OPEN,CONFIRMED          # Filter by status
x-sonarcloud --resolved                         # Include resolved issues
x-sonarcloud -h|--help                          # Show help
```

Fetches SonarCloud code quality issues via REST API and formats them as
structured markdown with LLM processing instructions for automated analysis
and triage.

## Examples

```bash
x-sonarcloud                                    # All open issues in project
x-sonarcloud --pr 42                            # Issues on PR #42
x-sonarcloud --branch main                      # Issues on main branch
x-sonarcloud --severities BLOCKER --types BUG   # Only blocker bugs
```

## Requirements

- `curl` and `jq` installed
- `SONAR_TOKEN` environment variable set
  (generate at <https://sonarcloud.io/account/security>)
- Project auto-detection via `sonar-project.properties` or
  `.sonarlint/connectedMode.json`, or explicit `--org`/`--project-key` flags

## Environment Variables

- `SONAR_TOKEN` — Bearer token for SonarCloud API authentication (required)
- `INFO=1` — Enable informational log messages on stderr
- `DEBUG=1` — Enable debug log messages on stderr

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
