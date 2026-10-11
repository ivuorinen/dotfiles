#!/usr/bin/env bats
#
# Coverage for .claude/hooks/pre-edit-block.sh — the PreToolUse guard that
# blocks edits to vendored, lock, and submodule files, and blocks both reads
# and edits of real secrets.d fish files.
#
# The guard's patterns are all anchored with a leading `*/`, so every path
# here is absolute. A bare "yarn.lock" would not match, and a test using one
# would pass while proving nothing.

bats_require_minimum_version 1.5.0

setup()
{
  HOOK="${BATS_TEST_DIRNAME}/../.claude/hooks/pre-edit-block.sh"
  REPO=/home/someone/.dotfiles
  export HOOK REPO
}

# Feed the hook a PreToolUse payload for one file path and tool.
# Tool defaults to Edit — the guard treats Read differently, and every
# Read-specific case names the tool explicitly.
decide()
{
  jq -cn --arg fp "$1" --arg tool "${2:-Edit}" \
    '{tool_name: $tool, tool_input: {file_path: $fp}}' \
    | bash "$HOOK"
}

@test "pre-edit-block: blocks lock and yarn-internal files" {
  run -2 decide "$REPO/yarn.lock"
  [[ "$output" == *"do not edit it in place"* ]]
  run -2 decide "$REPO/.yarn/releases/yarn-4.17.1.cjs"
}

# fzf is no longer vendored: its shell integration comes from the mise binary,
# so the former vendored paths and the fzf loaders must be editable.
@test "pre-edit-block: the fzf loaders are project code" {
  run -0 decide "$REPO/config/fzf/fzf.bash"
  run -0 decide "$REPO/config/fzf/fzf.zsh"
}

@test "pre-edit-block: a generated man page is still writable" {
  run -0 decide "$REPO/local/man/man1/dfm.1"
}

@test "pre-edit-block: blocks the vendored graphify skill" {
  run -2 decide "$REPO/.claude/skills/graphify/SKILL.md"
  [[ "$output" == *"vendored-files.md"* ]]
}

# A vendored group added after an audit found these five editable
# despite sitting beside 60+ hand-written functions with no naming signal.
@test "pre-edit-block: blocks the vendored fish plugin functions" {
  run -2 decide "$REPO/config/fish/functions/fisher.fish"
  run -2 decide "$REPO/config/fish/functions/bass.fish"
  run -2 decide "$REPO/config/fish/functions/__bass.py"
  run -2 decide "$REPO/config/fish/functions/__z_add.fish"
  run -2 decide "$REPO/config/fish/functions/__z_clean.fish"
  [[ "$output" == *"vendored-files.md"* ]]
}

@test "pre-edit-block: blocks files inside git submodules" {
  run -2 decide "$REPO/tools/dotbot/src/dotbot/cli.py"
  run -2 decide "$REPO/tools/antidote/functions/antidote"
  [[ "$output" == *"submodule"* ]]
  run -2 decide "$REPO/config/cheat/cheatsheets/tldr/tldr/umask"
  run -2 decide "$REPO/config/cheat/cheatsheets/community/foo"
}

@test "pre-edit-block: blocks edits to real secrets.d fish files" {
  run -2 decide "$REPO/config/fish/secrets.d/github.fish"
  [[ "$output" == *"gitignored"* ]]
}

# The .example files are the committed templates — they are the one thing in
# secrets.d that is meant to be edited.
@test "pre-edit-block: allows the secrets.d example templates" {
  run -0 decide "$REPO/config/fish/secrets.d/github.fish.example"
}

@test "pre-edit-block: allows ordinary repo files" {
  run -0 decide "$REPO/local/bin/dfm"
  run -0 decide "$REPO/config/fish/functions/mkcd.fish"
  run -0 decide "$REPO/README.md"
}

# Reads are governed by a separate branch: secrets are credentials, so reading
# one is as forbidden as writing it.
@test "pre-edit-block: blocks reading a real secrets.d fish file" {
  run -2 decide "$REPO/config/fish/secrets.d/github.fish" Read
  [[ "$output" == *"contains secrets"* ]]
}

@test "pre-edit-block: allows reading the secrets.d example" {
  run -0 decide "$REPO/config/fish/secrets.d/github.fish.example" Read
}

# The bash/zsh tree holds .sh credentials and was matched by neither branch,
# which only knew `*.fish` (agent-loopholes-da375736).
@test "pre-edit-block: guards the bash/zsh secrets tree for reads and edits" {
  run -2 decide "$REPO/config/secrets.d/tfs.sh" Read
  run -2 decide "$REPO/config/secrets.d/tfs.sh"
  run -0 decide "$REPO/config/secrets.d/github.sh.example" Read
  run -0 decide "$REPO/config/secrets.d/README.md"
}

# Deliberate asymmetry: vendored files are read-only, not read-blocked. A Read
# of yarn.lock is legitimate; only Edit/Write is refused.
@test "pre-edit-block: reading a vendored file is allowed" {
  run -0 decide "$REPO/yarn.lock" Read
  run -0 decide "$REPO/config/fish/functions/fisher.fish" Read
}

# The raw path was matched unnormalised, so case (APFS is case-insensitive),
# `./`, `//` and `..` spellings reached protected files (agent-loopholes-88c3bb49).
@test "pre-edit-block: normalises case, dot and doubled-slash spellings" {
  run -2 decide "./YARN.LOCK" Write
  run -2 decide "$REPO/tools/./dotbot/x" Write
  run -2 decide "$REPO/tools//dotbot/x" Write
  run -2 decide "$REPO/tools/x/../dotbot/x" Write
  run -2 decide "$REPO/CONFIG/FISH/SECRETS.D/github.fish" Read
  run -0 decide "$REPO/./local/bin/dfm" Write
}

# Grep and Glob read file content and names, NotebookEdit writes; all three
# were outside the matcher (agent-loopholes-9168e487).
search()
{
  jq -cn --arg tool "$1" --arg path "$2" --arg extra "${3:-}" '
    {tool_name: $tool, tool_input: ({path: $path} | if $extra == "" then . elif $tool == "Grep" then .glob = $extra else .pattern = $extra end)}
  ' | bash "$HOOK"
}

# A Grep glob overrides ripgrep's ignore rules, so `**/github.fish` under
# config/fish read the gitignored credentials (agent-loopholes-85be385e).
@test "pre-edit-block: a Grep glob over a directory holding a secrets tree is refused" {
  export CLAUDE_PROJECT_DIR="$REPO"
  run -2 search Grep "config/fish" "**/github.fish"
  [[ "$output" == *"overrides ripgrep's ignore rules"* ]]
  run -2 search Grep "$REPO/config" "*.sh"
  run -2 search Grep "$REPO" "*.fish"
  run -2 search Grep "" "*.fish"
  run -2 search Grep "$REPO/config/fish/../fish" "*.fish"
  run -0 search Grep "$REPO/local/bin" "*.sh"
  run -0 search Grep "config/nvim" "*.lua"
  run -0 search Grep "config/fish" "*.example"
  run -0 search Grep "$REPO/config"
}

@test "pre-edit-block: guards Grep, Glob and NotebookEdit paths" {
  run -2 search Grep "$REPO/config/fish/secrets.d"
  run -2 search Grep "$REPO/config" "secrets.d/*.fish"
  run -2 search Glob "$REPO/config/secrets.d"
  run -2 search Glob "$REPO" "config/fish/secret?.d/*"
  run -0 search Grep "$REPO/local/bin"
  run -0 search Glob "$REPO" "**/*.md"
  run -0 search Grep "$REPO/yarn.lock"
  run -0 bash -c 'jq -cn "{tool_name: \"Grep\", tool_input: {pattern: \"secrets.d\"}}" | bash "$1"' _ "$HOOK"
  run -2 bash -c 'jq -cn --arg p "$2" "{tool_name: \"NotebookEdit\", tool_input: {notebook_path: \$p}}" | bash "$1"' _ "$HOOK" "$REPO/.claude/skills/graphify/x.ipynb"
  run -0 bash -c 'jq -cn --arg p "$2" "{tool_name: \"NotebookEdit\", tool_input: {notebook_path: \$p}}" | bash "$1"' _ "$HOOK" "$REPO/notes/x.ipynb"
}

# Fails closed: a payload the guard cannot understand is refused rather than
# waved through, so a schema change surfaces as a block instead of silence.
@test "pre-edit-block: refuses a payload with no file_path" {
  run -2 bash -c 'printf "{\"tool_name\":\"Edit\"}" | bash "$1"' _ "$HOOK"
  [[ "$output" == *"invalid hook payload"* ]]
  run -2 bash -c 'printf "not json at all" | bash "$1"' _ "$HOOK"
}
