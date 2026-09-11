#!/usr/bin/env bats
#
# graphify-tests.py writes into graphify-out/graph.json, which every graphify
# query then reads. Two things must hold or the graph silently rots: the node
# id convention must match what graphify's AST extractor produces (diverge and
# every edge orphans), and the script must be idempotent (it runs after every
# rebuild, so a duplicating bug compounds).
#
# The id-convention cases call the script's own node_id(), so a change to that
# function is caught here rather than discovered as a graph full of orphans.

setup()
{
  SCRIPT="$BATS_TEST_DIRNAME/../scripts/graphify-tests.py"
  GRAPH="$BATS_TEST_DIRNAME/../graphify-out/graph.json"
}

node_id()
{
  python3 -c "
import importlib.util, sys
spec = importlib.util.spec_from_file_location('gt', '$SCRIPT')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
print(m.node_id(sys.argv[1]))
" "$1"
}

@test "graphify-tests: node_id matches the AST convention for local/bin" {
  # graphify's AST names local/bin/msgr -> local_bin_msgr. Anything else
  # orphans every tests edge.
  run node_id "local/bin/msgr"
  [ "$status" -eq 0 ]
  [ "$output" = "local_bin_msgr" ]
}

@test "graphify-tests: node_id drops the extension" {
  run node_id ".claude/hooks/pre-bash-route.sh"
  [ "$output" = "claude_hooks_pre_bash_route" ]
}

@test "graphify-tests: node_id collapses hyphens to underscores" {
  run node_id "local/bin/theme-mode"
  [ "$output" = "local_bin_theme_mode" ]
}

@test "graphify-tests: node_id keeps every directory level" {
  # Using only the basename would collide same-named files in different dirs.
  run node_id "config/theme/handlers.d/bat"
  [ "$output" = "config_theme_handlers_d_bat" ]
}

@test "graphify-tests: --check writes nothing" {
  [ -f "$GRAPH" ] || skip "no graph built"
  before=$(md5 -q "$GRAPH" 2> /dev/null || md5sum "$GRAPH" | cut -d' ' -f1)
  run "$SCRIPT" --check
  [ "$status" -eq 0 ]
  after=$(md5 -q "$GRAPH" 2> /dev/null || md5sum "$GRAPH" | cut -d' ' -f1)
  [ "$before" = "$after" ]
}

@test "graphify-tests: --check reports files, cases and edges" {
  [ -f "$GRAPH" ] || skip "no graph built"
  run "$SCRIPT" --check
  [ "$status" -eq 0 ]
  [[ "$output" == *"test files:"* ]]
  [[ "$output" == *"test cases:"* ]]
  [[ "$output" == *"tests edges:"* ]]
}

@test "graphify-tests: applying twice is idempotent" {
  [ -f "$GRAPH" ] || skip "no graph built"
  "$SCRIPT" > /dev/null
  first=$(python3 -c "
import json
g = json.load(open('$GRAPH'))
print(len(g['nodes']), len(g['links']))
")
  "$SCRIPT" > /dev/null
  second=$(python3 -c "
import json
g = json.load(open('$GRAPH'))
print(len(g['nodes']), len(g['links']))
")
  [ "$first" = "$second" ]
}

@test "graphify-tests: every emitted edge points at a node that exists" {
  # The invariant that keeps the graph free of dangling endpoints.
  [ -f "$GRAPH" ] || skip "no graph built"
  run python3 -c "
import json
g = json.load(open('$GRAPH'))
ids = {n['id'] for n in g['nodes']}
bad = [e for e in g['links'] if e['source'] not in ids or e['target'] not in ids]
print(len(bad))
"
  [ "$output" = "0" ]
}

@test "graphify-tests: the suite is reachable from the code it covers" {
  [ -f "$GRAPH" ] || skip "no graph built"
  run python3 -c "
import json
g = json.load(open('$GRAPH'))
edges = [e for e in g['links'] if e.get('relation') == 'tests']
assert edges, 'no tests edges in graph'
ids = {n['id'] for n in g['nodes']}
assert 'tests_msgr' in ids, 'tests/msgr.bats missing from graph'
assert any(e['source'] == 'tests_msgr' and e['target'] == 'local_bin_msgr' for e in edges), \
    'msgr.bats is not linked to local/bin/msgr'
print('ok')
"
  [ "$status" -eq 0 ]
  [ "$output" = "ok" ]
}
