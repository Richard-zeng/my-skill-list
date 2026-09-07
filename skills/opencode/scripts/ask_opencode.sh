#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  ask_opencode.sh <task> [options]
  ask_opencode.sh -t <task> [options]

Task input:
  <task>                       First positional argument is the task text
  -t, --task <text>            Alias for positional task
  (stdin)                      Pipe task text via stdin if no arg/flag is given

Context (optional, repeatable):
  -w, --workspace <path>       Working directory (default: current directory)
  -f, --file <path>            File or directory to attach; repeatable

Model and Agent:
  -m, --model <provider/model> Exact model explicitly requested by the user
      --agent <name>           Primary OpenCode Agent
      --variant <name>         Provider-specific model variant

Multi-turn:
  -s, --session <id>           Resume a session by ID
  -c, --continue               Resume the latest top-level workspace session
      --fork                   Fork when resuming; requires --session/--continue

Execution:
      --title <text>           Set the session title
      --pure                   Disable external OpenCode plugins
      --auto                   Auto-approve requested permissions (dangerous)
  -o, --output <path>          Markdown output path
  -h, --help                   Show this help

Output (on success):
  session_id=<id>              Use with --session for a follow-up
  output_path=<file>           Absolute path to the Markdown result
  elapsed=<seconds>s

Notes:
  OpenCode may edit files or run commands according to its local Agent config.
  Omit --model to use the local OpenCode default model.
  --auto expands authority and is appropriate only in a trusted workspace.
  Attached files are sent to the selected model provider.
  Set OPENCODE_CLI to an explicit executable path when opencode is not on PATH.
USAGE
}

fail() {
  echo "[ERROR] $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

require_value() {
  local option="$1" value="${2:-}"
  [[ -n "$value" ]] || fail "Missing value for $option"
}

trim_whitespace() {
  local text="$1"
  text="${text#"${text%%[![:space:]]*}"}"
  text="${text%"${text##*[![:space:]]}"}"
  printf '%s' "$text"
}

to_absolute() {
  local base="$1" target="$2" parent
  if [[ "$target" != /* ]]; then
    target="$base/$target"
  fi
  if [[ -e "$target" ]]; then
    parent="$(cd "$(dirname "$target")" && pwd)"
    printf '%s/%s\n' "$parent" "$(basename "$target")"
  else
    printf '%s\n' "$target"
  fi
}

redact_stderr() {
  sed -E \
    -e 's/(Bearer )[A-Za-z0-9._~+\/=:-]+/\1[REDACTED]/g' \
    -e 's/((sk|key|token)-[A-Za-z0-9_-]{6})[A-Za-z0-9_-]+/\1...[REDACTED]/g' \
    -e 's/((api_key|api-key|access_token|refresh_token|authorization|secret)[[:space:]]*[:=][[:space:]]*)[^[:space:]]+/\1[REDACTED]/Ig'
}

print_progress() {
  local line="$1" event_type tool_name tool_status
  event_type="$(printf '%s' "$line" | jq -r '.type // empty' 2>/dev/null || true)"
  case "$event_type" in
    tool_use)
      tool_name="$(printf '%s' "$line" | jq -r '.part.tool // "tool"' 2>/dev/null || true)"
      tool_status="$(printf '%s' "$line" | jq -r '.part.state.status // empty' 2>/dev/null || true)"
      if [[ -n "$tool_status" ]]; then
        echo "[opencode] tool: $tool_name ($tool_status)" >&2
      else
        echo "[opencode] tool: $tool_name" >&2
      fi
      ;;
    step_start)
      echo "[opencode] step started" >&2
      ;;
    error)
      echo "[opencode] error event received" >&2
      ;;
  esac
}

workspace="$PWD"
task_text=""
model=""
agent=""
variant=""
session_id=""
output_path=""
title=""
continue_session=0
fork_session=0
pure_mode=0
auto_mode=0
file_hints=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -w|--workspace)
      require_value "$1" "${2:-}"; workspace="$2"; shift 2 ;;
    -t|--task)
      require_value "$1" "${2:-}"; task_text="$2"; shift 2 ;;
    -f|--file)
      require_value "$1" "${2:-}"; file_hints+=("$2"); shift 2 ;;
    -m|--model)
      require_value "$1" "${2:-}"; model="$2"; shift 2 ;;
    --agent)
      require_value "$1" "${2:-}"; agent="$2"; shift 2 ;;
    --variant)
      require_value "$1" "${2:-}"; variant="$2"; shift 2 ;;
    -s|--session)
      require_value "$1" "${2:-}"; session_id="$2"; shift 2 ;;
    -c|--continue)
      continue_session=1; shift ;;
    --fork)
      fork_session=1; shift ;;
    --title)
      require_value "$1" "${2:-}"; title="$2"; shift 2 ;;
    --pure)
      pure_mode=1; shift ;;
    --auto)
      auto_mode=1; shift ;;
    -o|--output)
      require_value "$1" "${2:-}"; output_path="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    -*)
      echo "[ERROR] Unknown option: $1" >&2; usage >&2; exit 1 ;;
    *)
      if [[ -z "$task_text" ]]; then
        task_text="$1"; shift
      else
        echo "[ERROR] Unexpected argument: $1" >&2; usage >&2; exit 1
      fi ;;
  esac
done

require_cmd jq

opencode_cli="${OPENCODE_CLI:-opencode}"
if [[ "$opencode_cli" == */* ]]; then
  [[ -x "$opencode_cli" ]] || fail "OpenCode executable is unavailable: $opencode_cli"
else
  require_cmd "$opencode_cli"
fi

[[ -d "$workspace" ]] || fail "Workspace does not exist: $workspace"
workspace="$(cd "$workspace" && pwd)"

if [[ -z "$task_text" && ! -t 0 ]]; then
  task_text="$(cat)"
fi
task_text="$(trim_whitespace "$task_text")"
[[ -n "$task_text" ]] || fail "Request text is empty. Pass a positional task, --task, or stdin."

if [[ -n "$session_id" && "$continue_session" -eq 1 ]]; then
  fail "Use either --session or --continue, not both."
fi
if [[ "$fork_session" -eq 1 && -z "$session_id" && "$continue_session" -eq 0 ]]; then
  fail "--fork requires --session or --continue."
fi
if [[ -n "$model" && "$model" != */* ]]; then
  fail "--model must use the provider/model form shown by 'opencode models'."
fi

resolved_files=()
if (( ${#file_hints[@]} > 0 )); then
  for raw_file in "${file_hints[@]}"; do
    resolved_file="$(to_absolute "$workspace" "$raw_file")"
    [[ -e "$resolved_file" ]] || fail "Attached file or directory does not exist: $resolved_file"
    resolved_files+=("$resolved_file")
  done
fi

if [[ -z "$output_path" ]]; then
  timestamp="$(date -u +"%Y%m%d-%H%M%S")"
  output_path="${TMPDIR:-/tmp}/opencode-result-${timestamp}-$$.md"
elif [[ "$output_path" != /* ]]; then
  output_path="$workspace/$output_path"
fi
mkdir -p "$(dirname "$output_path")"
output_parent="$(cd "$(dirname "$output_path")" && pwd)"
output_path="$output_parent/$(basename "$output_path")"

cmd=("$opencode_cli" run --format json --dir "$workspace")
[[ -n "$model" ]] && cmd+=(--model "$model")
[[ -n "$agent" ]] && cmd+=(--agent "$agent")
[[ -n "$variant" ]] && cmd+=(--variant "$variant")
[[ -n "$session_id" ]] && cmd+=(--session "$session_id")
[[ "$continue_session" -eq 1 ]] && cmd+=(--continue)
[[ "$fork_session" -eq 1 ]] && cmd+=(--fork)
[[ -n "$title" ]] && cmd+=(--title "$title")
[[ "$pure_mode" -eq 1 ]] && cmd+=(--pure)
[[ "$auto_mode" -eq 1 ]] && cmd+=(--auto)
if (( ${#resolved_files[@]} > 0 )); then
  for resolved_file in "${resolved_files[@]}"; do
    cmd+=(--file "$resolved_file")
  done
fi
cmd+=(-- "$task_text")

json_file="$(mktemp)"
stderr_file="$(mktemp)"
cleanup() {
  rm -f "$json_file" "$stderr_file"
}
trap cleanup EXIT

start_seconds=$SECONDS
opencode_status=0
set +e
"${cmd[@]}" 2>"$stderr_file" | while IFS= read -r line; do
  line="${line//$'\r'/}"
  [[ -n "$line" ]] || continue
  if printf '%s' "$line" | jq -e . >/dev/null 2>&1; then
    printf '%s\n' "$line" >>"$json_file"
    print_progress "$line"
  else
    echo "[opencode] Ignored non-JSON output from JSON mode" >&2
  fi
done
opencode_status=${PIPESTATUS[0]}
set -e
elapsed=$((SECONDS - start_seconds))

if (( opencode_status != 0 )); then
  echo "[ERROR] OpenCode command failed (exit $opencode_status)" >&2
  if [[ -s "$json_file" ]]; then
    jq -r 'select(.type == "error") | (.error.data.message // .error.message // .error.name // "Unknown OpenCode error")' "$json_file" \
      | tail -n 20 \
      | redact_stderr >&2
  fi
  if [[ -s "$stderr_file" ]]; then
    tail -n 60 "$stderr_file" | redact_stderr >&2
  fi
  exit "$opencode_status"
fi

[[ -s "$json_file" ]] || fail "OpenCode returned no JSON events. Check 'opencode run --help', authentication, and local configuration."

if jq -e 'select(.type == "error")' "$json_file" >/dev/null 2>&1; then
  echo "[ERROR] OpenCode emitted an error event" >&2
  jq -r 'select(.type == "error") | (.error.data.message // .error.message // .error.name // "Unknown OpenCode error")' "$json_file" \
    | tail -n 20 \
    | redact_stderr >&2
  exit 1
fi

captured_session_id="$(jq -rs '[.[] | .sessionID // empty] | last // ""' <"$json_file" 2>/dev/null)"
[[ -n "$captured_session_id" ]] || captured_session_id="$session_id"

summary_text="$(jq -rs '
  [.[] | select(.type == "text" and (.part.text // "") != "")] as $texts
  | if ($texts | length) == 0 then ""
    else ($texts[-1].part.messageID // "") as $last_message
    | [$texts[] | select((.part.messageID // "") == $last_message) | .part.text]
    | join("\n")
    end
' <"$json_file" 2>/dev/null)"
[[ -n "$summary_text" ]] || summary_text="(OpenCode completed without a final text event.)"

tool_summary="$(jq -rs '
  [.[] | select(.type == "tool_use") | (.part.tool // "tool")]
  | group_by(.)
  | map("- `" + .[0] + "` ×" + (length | tostring))
  | .[]
' <"$json_file" 2>/dev/null)"
tool_count="$(jq -rs '[.[] | select(.type == "tool_use")] | length' <"$json_file" 2>/dev/null)"
finish_reason="$(jq -rs '[.[] | select(.type == "step_finish") | .part.reason // empty] | last // ""' <"$json_file" 2>/dev/null)"
token_total="$(jq -rs '
  [.[] | select(.type == "step_finish") | (.part.tokens.total // 0)]
  | if length == 0 then "" else add end
' <"$json_file" 2>/dev/null)"
requested_model="${model:-local-default}"
requested_variant="${variant:-default}"

{
  printf '## Summary\n\n%s\n\n' "$summary_text"
  [[ -n "$tool_summary" ]] && printf '## Tools used\n\n%s\n\n' "$tool_summary"
  printf -- '---\nrequested model: `%s` · variant: `%s`\n' "$requested_model" "$requested_variant"
  printf 'elapsed %ss · %s tools' "$elapsed" "${tool_count:-0}"
  [[ -n "$finish_reason" ]] && printf ' · %s' "$finish_reason"
  [[ -n "$token_total" ]] && printf ' · %s run tokens' "$token_total"
  printf '\n'
} >"$output_path"

[[ -n "$captured_session_id" ]] && echo "session_id=$captured_session_id"
echo "requested_model=$requested_model"
echo "requested_variant=$requested_variant"
echo "output_path=$output_path"
echo "elapsed=${elapsed}s"
