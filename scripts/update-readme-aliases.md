# update-readme-aliases

Regenerates the grouped alias documentation at `docs/aliases.md`. Usually
invoked as `dfm helpers docs-aliases`.

## Usage

```bash
scripts/update-readme-aliases.sh
```

Parses `config/alias` (bash and zsh) and `config/fish/alias.fish` (fish),
then writes `docs/aliases.md`: shared aliases first, then the aliases unique
to a shell group under their own heading.
