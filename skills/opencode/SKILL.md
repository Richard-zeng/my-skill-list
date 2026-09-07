---
name: opencode
description: Delegate coding, repository exploration, review, and implementation work to the local OpenCode CLI through a bundled non-interactive wrapper. Use when the user explicitly asks to use OpenCode or wants a configured OpenCode model or Agent to handle a task. Uses the local OpenCode default model unless the user explicitly names an exact provider/model; supports file attachments, model variants, session continuation, and optional plugin isolation.
---

# OpenCode

## Core rules

- Use `scripts/ask_opencode.sh` instead of invoking `opencode run` directly. The wrapper captures raw JSON events, streams compact progress, records the session ID, and writes a concise Markdown result.
- Run the wrapper once per task. After success, read the reported `output_path` and inspect the workspace before deciding whether a follow-up is needed.
- Give OpenCode the goal, completion criteria, constraints, and non-obvious context. Keep the delegated prompt focused, normally under 500 words.
- Pass only useful entry points with `--file`. File attachments are sent to the selected model provider; attach them only when that transmission is within the user's request.
- Use the local OpenCode default model by omitting `--model`. Pass `--model` only when the user explicitly names an exact `provider/model` in the current request; never choose or upgrade the model based on the task.
- Quote paths containing spaces, brackets, or shell metacharacters.
- Do not mention this Skill or its wrapper implementation in the delegated prompt.

## Host compatibility

Use this Skill from any Agent that can load `SKILL.md` instructions and execute a local shell command. The wrapper communicates with OpenCode through its CLI and does not call a host-specific API. `agents/openai.yaml` is optional metadata for OpenAI hosts; other Agents may ignore it.

## Safety boundary

OpenCode uses the permissions of the selected local Agent and configuration. It may read or modify files, execute commands, access configured tools, and contact the selected model provider.

In non-interactive mode, OpenCode rejects permission requests that are not already allowed unless `--auto` is passed. This does not make the default mode read-only: operations already allowed by the local Agent can still run. Use only a trusted workspace and only when the user's request authorizes the expected changes.

`--auto` approves otherwise-requested permissions for that run. Pass it only when the user has authorized autonomous execution in the selected workspace. Do not describe omission of `--auto`, `--pure`, or a prompt instruction as an enforced sandbox.

OpenCode writes session and log data under its local application directories. In a restricted filesystem sandbox, run the wrapper with host permissions that allow OpenCode's local state to be written.

## Wrapper path

```text
<skill-directory>/scripts/ask_opencode.sh
```

## Usage

Run a task with the locally configured default model:

```bash
./scripts/ask_opencode.sh "Inspect the repository and implement the requested change"
```

Use an exact configured model only when the user explicitly requests it:

```bash
./scripts/ask_opencode.sh "Review the active request path" \
  --model "provider/model" \
  --variant "high"
```

Add priority files and an explicit workspace:

```bash
./scripts/ask_opencode.sh "Refactor these components to use the new API" \
  --workspace "/path/to/repo" \
  --file "src/components/UserList.tsx" \
  --file "src/components/UserDetail.tsx"
```

Resume a previous session:

```bash
./scripts/ask_opencode.sh "Also add the missing regression test" \
  --session <session_id>
```

Fork a previous session instead of extending it in place:

```bash
./scripts/ask_opencode.sh "Try the alternative implementation" \
  --session <session_id> \
  --fork
```

Disable external plugins for a more isolated diagnostic run:

```bash
./scripts/ask_opencode.sh "Diagnose the failing request" --pure
```

Allow OpenCode to approve otherwise-requested permissions in a trusted workspace:

```bash
./scripts/ask_opencode.sh "Implement and verify the requested change" --auto
```

## Workflow

1. Read enough local context to state the actual goal and important constraints.
2. Choose the workspace, Agent, variant, and priority files. Omit `--model` unless the user explicitly provided an exact `provider/model`.
3. Run the wrapper with one focused prompt. Use `--auto` only when its expanded authority is authorized.
4. Read the Markdown file printed as `output_path`.
5. Inspect workspace changes and run verification proportional to risk.
6. Use `--session` only for a true follow-up that benefits from OpenCode's prior context; add `--fork` when the alternative should not mutate the original session.

## Output

Successful runs print:

```text
session_id=<opencode_session_id>
requested_model=<provider/model-or-local-default>
requested_variant=<variant-or-default>
output_path=<absolute_markdown_path>
elapsed=<seconds>s
```

The Markdown file contains OpenCode's final response, a compact tool summary, the requested model and variant, and execution metadata. `local-default` means the wrapper omitted `--model`; it does not claim to have resolved the effective model. Run tokens are summed across all completed `step_finish` events. Raw event payloads and arguments are intentionally omitted from the Markdown handoff.

## Options

- `--workspace <path>`: working directory; defaults to the current directory.
- `--file <path>`: attach a priority file or directory; repeatable.
- `--model <provider/model>`: exact model explicitly requested by the user; otherwise omit it and use the local OpenCode default.
- `--agent <name>`: primary OpenCode Agent to use.
- `--variant <name>`: provider-specific model variant such as `high` or `max`.
- `--session <id>`: resume a previous session.
- `--continue`: resume the most recent top-level session for the workspace.
- `--fork`: fork the resumed session; requires `--session` or `--continue`.
- `--title <text>`: set the session title.
- `--pure`: disable external OpenCode plugins for this run.
- `--auto`: auto-approve permissions not explicitly denied; use only with explicit authority in a trusted workspace.
- `--output <path>`: choose the Markdown result path.

Set `OPENCODE_CLI` to an explicit executable path only when `opencode` is not available on `PATH`.

Task text may be passed as the first positional argument, with `--task`, or through stdin.

## Model and authentication checks

- Run `opencode models` only when the user asks to select a model or when diagnosing a model-selection failure.
- Run `opencode auth list` to list configured providers without exposing credential values.
- Use `opencode auth login` when the desired provider is not configured. Authentication is interactive and may require the user to supply or approve credentials.

## Failure handling

- If `opencode` is unavailable, run `opencode --version` and check the local installation.
- If authentication or model selection fails, run `opencode auth list` and `opencode models`; do not silently switch to another provider or model.
- If local session or log storage is unwritable, rerun with host permissions that allow OpenCode to write its own application directories.
- If a task requests unavailable permissions, OpenCode may reject the operation and still return a textual explanation. Inspect the result and workspace rather than treating any text response as successful implementation.
- If a flag stops working after an upgrade, inspect `opencode run --help` and update the wrapper instead of assuming compatibility with another Agent CLI.
- Treat a non-zero OpenCode exit or an emitted `error` event as failure. Failure output is truncated and common credential patterns are redacted.
