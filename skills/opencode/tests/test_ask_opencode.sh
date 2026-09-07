#!/usr/bin/env bash
set -euo pipefail

if [[ "${OPENCODE_TEST_FAKE:-0}" == "1" ]]; then
  : "${OPENCODE_TEST_ARGS:?}"
  : "${OPENCODE_TEST_TASK:?}"

  : >"$OPENCODE_TEST_ARGS"
  : >"$OPENCODE_TEST_TASK"
  capture_task=0
  for arg in "$@"; do
    printf '%s\n' "$arg" >>"$OPENCODE_TEST_ARGS"
    if (( capture_task == 1 )); then
      printf '%s' "$arg" >"$OPENCODE_TEST_TASK"
      capture_task=2
    elif [[ "$arg" == "--" ]]; then
      capture_task=1
    fi
  done

  printf '%s\n' '{"type":"step_start","sessionID":"ses_test","part":{"type":"step-start","messageID":"msg_test"}}'
  printf '%s\n' '{"type":"text","sessionID":"ses_test","part":{"type":"text","messageID":"msg_test","text":"TEST_OK"}}'
  printf '%s\n' '{"type":"step_finish","sessionID":"ses_test","part":{"type":"step-finish","messageID":"msg_test","reason":"tool-calls","tokens":{"total":10}}}'
  printf '%s\n' '{"type":"step_finish","sessionID":"ses_test","part":{"type":"step-finish","messageID":"msg_test","reason":"stop","tokens":{"total":32}}}'
  exit 0
fi

fail() {
  echo "not ok - $*" >&2
  exit 1
}

pass() {
  echo "ok - $*"
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
test_script="$script_dir/$(basename "${BASH_SOURCE[0]}")"
skill_dir="$(cd "$script_dir/.." && pwd)"
wrapper="$skill_dir/scripts/ask_opencode.sh"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/opencode-wrapper-test.XXXXXX")"
trap 'rm -rf "$test_dir"' EXIT

fixture="$test_dir/fixture.txt"
printf 'fixture\n' >"$fixture"

args_one="$test_dir/args-one.txt"
task_one="$test_dir/task-one.txt"
stdout_one="$test_dir/stdout-one.txt"
result_one="$test_dir/result-one.md"
OPENCODE_TEST_FAKE=1 \
OPENCODE_TEST_ARGS="$args_one" \
OPENCODE_TEST_TASK="$task_one" \
OPENCODE_CLI="$test_script" \
  "$wrapper" "review attachment" \
    --workspace "$test_dir" \
    --file "$fixture" \
    --output "$result_one" >"$stdout_one"

[[ "$(cat "$task_one")" == "review attachment" ]] || fail "task remains separate from --file values"
tail -n 2 "$args_one" | diff -u - <(printf '%s\n' -- 'review attachment') >/dev/null \
  || fail "OpenCode receives -- before the task"
pass "attachments do not consume the task"

args_two="$test_dir/args-two.txt"
task_two="$test_dir/task-two.txt"
stdout_two="$test_dir/stdout-two.txt"
result_two="$test_dir/result-two.md"
expected_task="$test_dir/expected-task.txt"
printf 'first paragraph\n\nsecond paragraph' >"$expected_task"
printf '  first paragraph\n\nsecond paragraph  \n' \
  | OPENCODE_TEST_FAKE=1 \
    OPENCODE_TEST_ARGS="$args_two" \
    OPENCODE_TEST_TASK="$task_two" \
    OPENCODE_CLI="$test_script" \
      "$wrapper" --workspace "$test_dir" --output "$result_two" >"$stdout_two"
cmp -s "$expected_task" "$task_two" || fail "internal blank lines are preserved"
pass "multiline task preserves internal blank lines"

if grep -Fx -- '--model' "$args_one" >/dev/null; then
  fail "omitted model is not forwarded"
fi
grep -F 'requested_model=local-default' "$stdout_one" >/dev/null \
  || fail "default model is reported as local-default"
pass "omitted model keeps the OpenCode local default"

args_three="$test_dir/args-three.txt"
task_three="$test_dir/task-three.txt"
stdout_three="$test_dir/stdout-three.txt"
result_three="$test_dir/result-three.md"
OPENCODE_TEST_FAKE=1 \
OPENCODE_TEST_ARGS="$args_three" \
OPENCODE_TEST_TASK="$task_three" \
OPENCODE_CLI="$test_script" \
  "$wrapper" "explicit model" \
    --workspace "$test_dir" \
    --model "provider/model" \
    --variant "high" \
    --output "$result_three" >"$stdout_three"
grep -F 'requested_model=provider/model' "$stdout_three" >/dev/null \
  || fail "explicit model is reported"
grep -F 'requested_variant=high' "$stdout_three" >/dev/null \
  || fail "explicit variant is reported"
grep -F 'requested model: `provider/model` · variant: `high`' "$result_three" >/dev/null \
  || fail "Markdown records model and variant"
pass "result records requested model and variant"

grep -F '42 run tokens' "$result_three" >/dev/null \
  || fail "step token totals are summed"
pass "run tokens sum all step_finish events"
