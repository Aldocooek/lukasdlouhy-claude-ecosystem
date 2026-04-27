#!/usr/bin/env python3
# Adapted from adamkropacek/claude-ecosystem-adam
"""
cache-audit.py — Parse Claude Code session JSONL files for prompt cache hit rate.

Usage:
    python3 cache-audit.py [SESSION_JSONL ...]
    python3 cache-audit.py --obsidian-out /path/to/dashboard.md

Options:
    SESSION_JSONL          One or more .jsonl session files to parse.
                           Defaults to ~/.claude/sessions/*.jsonl (most recent 10).
    --obsidian-out PATH    Write a markdown summary to PATH (Obsidian dashboard format).
                           If omitted, prints to stdout only — no file is written.
    --limit N              Max number of session files to scan (default: 10).
    --verbose              Show per-session breakdown in addition to aggregate.

Exit codes:
    0 — success
    1 — no JSONL files found or parseable
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from datetime import datetime, timezone


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Audit Claude Code session JSONL for cache hit rate.")
    p.add_argument("files", nargs="*", help="JSONL session files to parse.")
    p.add_argument("--obsidian-out", metavar="PATH", help="Write markdown summary to this path.")
    p.add_argument("--limit", type=int, default=10, help="Max session files to scan (default 10).")
    p.add_argument("--verbose", action="store_true", help="Per-session breakdown.")
    return p.parse_args()


def resolve_files(args: argparse.Namespace) -> list[Path]:
    if args.files:
        return [Path(f) for f in args.files]
    sessions_dir = Path.home() / ".claude" / "sessions"
    files = sorted(sessions_dir.glob("*.jsonl"), key=lambda p: p.stat().st_mtime, reverse=True)
    return files[: args.limit]


def parse_session(path: Path) -> dict:
    """Return aggregate token counts for a single JSONL session file."""
    totals = {
        "input_tokens": 0,
        "output_tokens": 0,
        "cache_read_input_tokens": 0,
        "cache_creation_input_tokens": 0,
        "tool_calls": 0,
        "turns": 0,
    }
    try:
        with path.open("r", encoding="utf-8", errors="replace") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                except json.JSONDecodeError:
                    continue

                # Claude Code JSONL schema: look for usage objects
                usage = None
                if isinstance(obj.get("usage"), dict):
                    usage = obj["usage"]
                elif isinstance(obj.get("message", {}).get("usage"), dict):
                    usage = obj["message"]["usage"]

                if usage:
                    totals["input_tokens"] += usage.get("input_tokens", 0)
                    totals["output_tokens"] += usage.get("output_tokens", 0)
                    totals["cache_read_input_tokens"] += usage.get("cache_read_input_tokens", 0)
                    totals["cache_creation_input_tokens"] += usage.get("cache_creation_input_tokens", 0)
                    totals["turns"] += 1

                # Count tool uses
                if obj.get("type") == "tool_use" or obj.get("role") == "tool":
                    totals["tool_calls"] += 1

    except (OSError, PermissionError) as e:
        print(f"Warning: could not read {path}: {e}", file=sys.stderr)

    return totals


def hit_rate(totals: dict) -> float:
    """Cache hit rate = cache_read / (input + cache_read + cache_creation)."""
    denom = totals["input_tokens"] + totals["cache_read_input_tokens"] + totals["cache_creation_input_tokens"]
    if denom == 0:
        return 0.0
    return totals["cache_read_input_tokens"] / denom


def format_report(files: list[Path], per_session: list[dict], aggregate: dict, verbose: bool) -> str:
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    rate = hit_rate(aggregate)

    lines = [
        f"# Claude Code Cache Audit — {now}",
        "",
        "## Aggregate",
        f"- Sessions scanned: {len(files)}",
        f"- Total input tokens: {aggregate['input_tokens']:,}",
        f"- Cache read tokens: {aggregate['cache_read_input_tokens']:,}",
        f"- Cache creation tokens: {aggregate['cache_creation_input_tokens']:,}",
        f"- Output tokens: {aggregate['output_tokens']:,}",
        f"- **Cache hit rate: {rate:.1%}**",
        f"- Total tool calls: {aggregate['tool_calls']:,}",
        f"- Total turns: {aggregate['turns']:,}",
        "",
    ]

    if verbose and per_session:
        lines.append("## Per-Session Breakdown")
        lines.append("")
        lines.append("| File | Turns | Input | Cache Read | Cache Create | Hit Rate |")
        lines.append("|---|---|---|---|---|---|")
        for path, s in zip(files, per_session):
            r = hit_rate(s)
            lines.append(
                f"| {path.name} | {s['turns']} | {s['input_tokens']:,} | "
                f"{s['cache_read_input_tokens']:,} | {s['cache_creation_input_tokens']:,} | {r:.1%} |"
            )
        lines.append("")

    lines.append("## Interpretation")
    if rate >= 0.6:
        lines.append("Cache hit rate is healthy (≥60%). Prompt cache is working well.")
    elif rate >= 0.3:
        lines.append("Cache hit rate is moderate (30–60%). Consider stabilising CLAUDE.md position.")
    else:
        lines.append("Cache hit rate is low (<30%). Review context structure — CLAUDE.md changes mid-session invalidate the cache.")

    return "\n".join(lines)


def main() -> int:
    args = parse_args()
    files = resolve_files(args)

    if not files:
        print("No JSONL session files found. Pass file paths explicitly or check ~/.claude/sessions/", file=sys.stderr)
        return 1

    per_session: list[dict] = []
    aggregate: dict = {
        "input_tokens": 0,
        "output_tokens": 0,
        "cache_read_input_tokens": 0,
        "cache_creation_input_tokens": 0,
        "tool_calls": 0,
        "turns": 0,
    }

    for path in files:
        s = parse_session(path)
        per_session.append(s)
        for k in aggregate:
            aggregate[k] += s[k]

    report = format_report(files, per_session, aggregate, args.verbose)

    print(report)

    if args.obsidian_out:
        out = Path(args.obsidian_out)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(report, encoding="utf-8")
        print(f"\nWrote Obsidian dashboard to: {out}", file=sys.stderr)

    return 0


if __name__ == "__main__":
    sys.exit(main())
