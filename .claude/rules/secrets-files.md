# Fish secrets

Never commit anything under `config/fish/secrets.d/` except `*.example`
files and `README.md`. The `.gitignore` enforces this with
`config/fish/secrets.d/*` plus allowlist entries for the two
exceptions.

To add a new secret: copy the matching `<name>.example` file to
`<name>` (without the `.example` suffix) and edit the copy locally.
The non-example files are auto-sourced by `config/fish/exports.fish`
at shell startup.

The `.claude/settings.json` PreToolUse hook blocks edits to the real
secrets files; bypassing the hook is forbidden
(`.claude/rules/no-hook-bypass.md`). If you need to inspect a secret,
ask the user — do not read or echo its contents into the
conversation.
