#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# scripts/install-herdr-plugins.sh installs every plugin at its ref and skips
# an installed one only when its requested_ref or resolved_commit equals that
# ref; a check on the plugin id alone kept the old ref after a pin changed.
# herdr is a PATH stub serving a fixture `plugin list --json` in herdr's shape
# and logging installs; jq is the real one. DOTFILES points at a scratch tree
# whose shared.sh is empty.

setup()
{
  SCRIPT="$BATS_TEST_DIRNAME/../scripts/install-herdr-plugins.sh"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/dotfiles/config"
  : > "$TMP/dotfiles/config/shared.sh"
  CALLS="$TMP/calls"
  : > "$CALLS"

  # navigator at its tag, sessionizer installed without --ref at its pinned
  # commit, branch-cleanup at an older commit; herdr.auto-title is absent.
  cat > "$TMP/list.json" << 'JSON'
{"id": "1", "result": {"plugins": [
  {"plugin_id": "herdr-navigator",
    "source": {"requested_ref": "v0.3.6", "resolved_commit": "e12a97c5d9ddcd76ba18c985909ffeb4827afa6a"}},
  {"plugin_id": "sessionizer",
    "source": {"requested_ref": null, "resolved_commit": "9aba5d0e4e14eca1a6d5be0a69e828b8a72c0e5c"}},
  {"plugin_id": "branch-cleanup",
    "source": {"requested_ref": null, "resolved_commit": "0000000000000000000000000000000000000000"}}
]}}
JSON

  # FAIL_REPO makes the install of that one repository fail.
  cat > "$TMP/bin/herdr" << STUB
#!/usr/bin/env bash
if [ "\$1 \$2" = "plugin list" ]; then cat "$TMP/list.json"; exit 0; fi
printf 'herdr %s\n' "\$*" >> "$CALLS"
[ -n "\${FAIL_REPO:-}" ] && [ "\$3" = "\$FAIL_REPO" ] && exit 1
exit 0
STUB
  printf '#!/bin/sh\nprintf "%%s\\n" "$*"\n' > "$TMP/bin/msgr"
  chmod +x "$TMP/bin/"*
}

teardown()
{
  rm -rf "$TMP"
}

# Run the script against the stubs.
run_install()
{
  run env PATH="$TMP/bin:$PATH" DOTFILES="$TMP/dotfiles" FAIL_REPO="${FAIL_REPO:-}" bash "$SCRIPT"
}

@test "install-herdr-plugins: plugins already at their ref are left alone" {
  run_install
  [ "$status" -eq 0 ]
  run ! grep -q 'herdr-navigator' "$CALLS"
  run ! grep -q 'herdr-sessionizer' "$CALLS"
}

@test "install-herdr-plugins: a plugin at another commit is reinstalled at its ref" {
  run_install
  [ "$status" -eq 0 ]
  grep -qx 'herdr plugin install dutifuldev/herdr-branch-cleanup --ref 8b6774e60008f971f16894e95d074caf9342d96b --yes' "$CALLS"
  [[ "$output" == *"Reinstalling branch-cleanup"* ]]
}

@test "install-herdr-plugins: a missing plugin is installed at its ref" {
  run_install
  [ "$status" -eq 0 ]
  grep -qx 'herdr plugin install kryptamine/herdr-auto-title --ref 636286baf931fa71966083d1e8294fc4a38f11fb --yes' "$CALLS"
  [ "$(wc -l < "$CALLS")" -eq 2 ]
}

@test "install-herdr-plugins: a failed install fails the run after the rest are tried" {
  FAIL_REPO=dutifuldev/herdr-branch-cleanup
  run_install
  [ "$status" -ne 0 ]
  [[ "$output" == *"Failed to install dutifuldev/herdr-branch-cleanup"* ]]
  [[ "$output" != *"Done"* ]]
  grep -q 'kryptamine/herdr-auto-title' "$CALLS"
}
