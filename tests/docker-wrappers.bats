#!/usr/bin/env bats

# x-trivy-scan and x-code-scanner exec docker with a fixed argument set. The
# mounts and the image are the contract — a wrong cache mount silently
# re-downloads the vulnerability database on every run, and a wrong socket
# mount breaks scanning entirely. docker is stubbed to capture argv.

setup()
{
  TRIVY="$BATS_TEST_DIRNAME/../local/bin/x-trivy-scan"
  SCANNER="$BATS_TEST_DIRNAME/../local/bin/x-code-scanner"
  MIRROR="$BATS_TEST_DIRNAME/../local/bin/x-mirror-site"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin"
  cat > "$TMP/bin/docker" << 'STUB'
#!/usr/bin/env bash
printf 'DOCKER:%s\n' "$*"
STUB
  cat > "$TMP/bin/wget" << 'STUB'
#!/usr/bin/env bash
printf 'WGET:%s\n' "$*"
STUB
  chmod +x "$TMP/bin/docker" "$TMP/bin/wget"
}

teardown()
{
  rm -rf "$TMP"
}

@test "x-trivy-scan: runs the aquasec image" {
  run env PATH="$TMP/bin:$PATH" "$TRIVY" image alpine
  [ "$status" -eq 0 ]
  [[ "$output" == *"aquasec/trivy"* ]]
  [[ "$output" == *"image alpine"* ]]
}

@test "x-trivy-scan: mounts the docker socket" {
  run env PATH="$TMP/bin:$PATH" "$TRIVY" image alpine
  [[ "$output" == *"/var/run/docker.sock:/var/run/docker.sock"* ]]
}

@test "x-trivy-scan: honours XDG_CACHE_HOME for the trivy cache" {
  run env PATH="$TMP/bin:$PATH" XDG_CACHE_HOME="$TMP/cache" "$TRIVY" image alpine
  [[ "$output" == *"$TMP/cache/trivy:/root/.cache/trivy"* ]]
}

@test "x-trivy-scan: falls back to ~/.cache when XDG_CACHE_HOME is unset" {
  # -u must precede the assignments; env stops parsing options at the first one.
  run env -u XDG_CACHE_HOME PATH="$TMP/bin:$PATH" HOME="$TMP/home" "$TRIVY" image alpine
  [[ "$output" == *"$TMP/home/.cache/trivy"* ]]
}

@test "x-code-scanner: mounts the working directory as /code" {
  run env PATH="$TMP/bin:$PATH" bash -c "cd '$TMP' && '$SCANNER'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$TMP:/code"* ]]
}

@test "x-code-scanner: defaults the image tag to latest" {
  run env PATH="$TMP/bin:$PATH" bash -c "cd '$TMP' && '$SCANNER'"
  [[ "$output" == *"codequality:latest"* ]]
}

@test "x-code-scanner: honours CODEQUALITY_VERSION" {
  run env PATH="$TMP/bin:$PATH" CODEQUALITY_VERSION="0.96" bash -c "cd '$TMP' && '$SCANNER'"
  [[ "$output" == *"codequality:0.96"* ]]
}

@test "x-mirror-site: requires a url" {
  run env PATH="$TMP/bin:$PATH" "$MIRROR"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "x-mirror-site: passes mirroring flags and the url to wget" {
  run env PATH="$TMP/bin:$PATH" "$MIRROR" https://example.com
  [ "$status" -eq 0 ]
  [[ "$output" == *"-m"* ]]
  [[ "$output" == *"robots=off"* ]]
  [[ "$output" == *"https://example.com"* ]]
}
