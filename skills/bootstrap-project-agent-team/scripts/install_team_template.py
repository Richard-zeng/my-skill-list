#!/usr/bin/env python3
"""Plan or install the static project-team template without overwriting files."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import shutil
import sys


SKILL_ROOT = Path(__file__).resolve().parent.parent
TEMPLATE_ROOT = SKILL_ROOT / "assets" / "project-template"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def fail(message: str, code: int = 1) -> int:
    print(json.dumps({"ok": False, "error": message}, ensure_ascii=False, indent=2))
    return code


def resolve_project(raw: str) -> Path:
    project = Path(raw).expanduser().resolve()
    if not project.exists() or not project.is_dir():
        raise ValueError(f"Project directory does not exist: {project}")
    if project == Path(project.anchor) or project == Path.home().resolve():
        raise ValueError(f"Refusing broad project target: {project}")
    return project


def template_files() -> list[Path]:
    if not TEMPLATE_ROOT.is_dir():
        raise ValueError(f"Template directory is missing: {TEMPLATE_ROOT}")
    files = sorted(path for path in TEMPLATE_ROOT.rglob("*") if path.is_file())
    if not files:
        raise ValueError("Template contains no files")
    return files


def inspect(project: Path) -> list[dict[str, object]]:
    actions: list[dict[str, object]] = []
    for source in template_files():
        relative = source.relative_to(TEMPLATE_ROOT)
        destination = project / relative
        resolved_destination = destination.resolve(strict=False)
        try:
            resolved_destination.relative_to(project)
        except ValueError as error:
            raise ValueError(f"Destination escapes project: {relative}") from error

        item: dict[str, object] = {
            "path": relative.as_posix(),
            "source_sha256": sha256(source),
            "size": source.stat().st_size,
        }
        if destination.is_symlink():
            item["action"] = "conflict"
            item["reason"] = "destination is a symlink"
        elif not destination.exists():
            item["action"] = "create"
        elif not destination.is_file():
            item["action"] = "conflict"
            item["reason"] = "destination exists and is not a file"
        elif sha256(destination) == item["source_sha256"]:
            item["action"] = "identical"
        else:
            item["action"] = "conflict"
            item["reason"] = "destination content differs"
            item["destination_sha256"] = sha256(destination)
        actions.append(item)
    return actions


def render(project: Path, actions: list[dict[str, object]], applied: bool) -> dict[str, object]:
    counts = {name: sum(item["action"] == name for item in actions) for name in ("create", "identical", "conflict")}
    return {
        "ok": counts["conflict"] == 0,
        "schema_version": 1,
        "project": str(project),
        "template": str(TEMPLATE_ROOT),
        "applied": applied,
        "summary": counts,
        "actions": actions,
        "manual_steps": [
            "Merge assets/project-agents-section.md into the project AGENTS.md with user approval.",
            "Add .codex/team/registry.local.json to the project .gitignore.",
            "Create long-lived tasks, then write the registry with their real IDs.",
        ],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project", required=True, help="Existing target project directory")
    parser.add_argument("--apply", action="store_true", help="Create missing files after a conflict-free plan")
    args = parser.parse_args()

    try:
        project = resolve_project(args.project)
        actions = inspect(project)
    except (OSError, ValueError) as error:
        return fail(str(error))

    conflicts = [item for item in actions if item["action"] == "conflict"]
    if args.apply and conflicts:
        print(json.dumps(render(project, actions, applied=False), ensure_ascii=False, indent=2))
        return 2

    if args.apply:
        for item in actions:
            if item["action"] != "create":
                continue
            relative = Path(str(item["path"]))
            source = TEMPLATE_ROOT / relative
            destination = project / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, destination)

        actions = inspect(project)
        if any(item["action"] != "identical" for item in actions):
            print(json.dumps(render(project, actions, applied=True), ensure_ascii=False, indent=2))
            return 3

    print(json.dumps(render(project, actions, applied=args.apply), ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
