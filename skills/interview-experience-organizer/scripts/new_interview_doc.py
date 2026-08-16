#!/usr/bin/env python3
"""Create a blank interview experience document from the bundled template."""

from __future__ import annotations

import argparse
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create a blank structured 面经 Markdown document."
    )
    parser.add_argument("--company", required=True, help="Company name.")
    parser.add_argument("--role", required=True, help="Interview role.")
    parser.add_argument("--round", default="一面", help="Interview round.")
    parser.add_argument("--date", default="需补充", help="Interview date.")
    parser.add_argument("--candidate", required=True, help="Candidate name or alias.")
    parser.add_argument("--background", default="需补充", help="Candidate background.")
    parser.add_argument("--interviewer", default="需补充", help="Interviewer info.")
    parser.add_argument("--output", required=True, help="Output Markdown path.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    skill_dir = Path(__file__).resolve().parents[1]
    template_path = skill_dir / "assets" / "interview-experience-template.md"
    text = template_path.read_text(encoding="utf-8")

    values = {
        "{{company}}": args.company,
        "{{role}}": args.role,
        "{{round}}": args.round,
        "{{date}}": args.date,
        "{{candidate}}": args.candidate,
        "{{background}}": args.background,
        "{{interviewer}}": args.interviewer,
    }
    for key, value in values.items():
        text = text.replace(key, value)

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(text, encoding="utf-8")
    print(f"Created {output_path}")


if __name__ == "__main__":
    main()
