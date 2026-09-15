#!/usr/bin/env bats

setup() {
  PROJECT_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  cd "$PROJECT_ROOT"
  unset usage_cmd usage_yes || true
}

@test "gh-identity USAGE declares check and switch" {
  run grep -E '^#USAGE cmd "' .mise/tasks/gh-identity
  [ "$status" -eq 0 ]
  [[ "$output" == *'cmd "check"'* ]]
  [[ "$output" == *'cmd "switch"'* ]]
}

@test "gh-identity without subcommand prints brief usage" {
  run env -u usage_cmd -u usage_yes ./.mise/tasks/gh-identity
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage: mise run gh-identity"* ]]
  [[ "$output" == *"check"* ]]
  [[ "$output" == *"switch"* ]]
}

@test "gh-identity switch requires --yes" {
  run env usage_cmd=switch usage_yes=false ./.mise/tasks/gh-identity
  [ "$status" -eq 1 ]
  [[ "$output" == *'Re-run with --yes'* ]]
}

@test "ensure-gh-identity.sh rejects unknown arguments" {
  run ./scripts/ensure-gh-identity.sh --bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *'unknown argument'* ]]
}
