---
description: "Machine-specific config must live under hosts/<hostname>/, never in the shared config/ tree."
paths:
  - "config/**"
  - "hosts/**"
  - "base/**"
  - "ssh/**"
---

# Host-specific configuration

Personal hostnames, SSH targets, paths under `~/Code/<your-org>/`,
private session lists, machine-only mise tools, and any other
machine-specific value must live under
`hosts/<hostname>/config/<app>/...`, never in the shared `config/`
tree.

The dotbot host overlay (`hosts/<hostname>/install.conf.yaml`) layers
these on top of the global config at install time, so the shared tree
stays portable across machines and forks.

Use the `host-override` skill to scaffold a new overlay when adding
machine-specific config.
