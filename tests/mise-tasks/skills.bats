#!/usr/bin/env bats

setup() {
  PROJECT_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  cd "$PROJECT_ROOT"
  unset usage_cmd usage_yes usage_user usage_extra || true
}

@test "skills USAGE declares all subcommands" {
  run grep -E '^#USAGE cmd "' .mise/tasks/skills
  [ "$status" -eq 0 ]
  [[ "$output" == *'cmd "auth"'* ]]
  [[ "$output" == *'cmd "install"'* ]]
  [[ "$output" == *'cmd "uninstall"'* ]]
  [[ "$output" == *'cmd "deploy"'* ]]
  [[ "$output" == *'cmd "audit"'* ]]
}

@test "skills without subcommand fails" {
  run env -u usage_cmd -u usage_yes ./.mise/tasks/skills
  [ "$status" -ne 0 ]
  [[ "$output" == *"missing subcommand"* ]]
}

@test "skills uninstall without --yes fails" {
  run env usage_cmd=uninstall usage_yes=false ./.mise/tasks/skills
  [ "$status" -ne 0 ]
  [[ "$output" == *"--yes"* ]]
}

@test "skills deploy without --yes fails" {
  run env usage_cmd=deploy usage_yes=false ./.mise/tasks/skills
  [ "$status" -ne 0 ]
  [[ "$output" == *"--yes"* ]]
}
