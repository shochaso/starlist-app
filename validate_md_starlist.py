#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import sys
import tempfile
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Iterable, List, Optional, Sequence, Tuple

REQUIRED_FRONTMATTER = [
    "source_of_truth",
    "version",
    "updated_date",
    "owner",
]

DEFAULT_FRONTMATTER_VALUES = {
    "source_of_truth": "true",
    "version": "0.1.0",
    "updated_date": lambda: datetime.utcnow().strftime("%Y-%m-%d"),
    "owner": "STARLIST Docs Automation Team",
}

FORBIDDEN_WORDS = [
    "tbd",
    "todo",
    "fixme",
    "wip",
    "temp fix",
    "placeholder",
    "asap",
    "urgent",
    "just in case",
    "patch please",
]

DISALLOWED_EXTERNAL_DOMAINS = [
    "example.com",
    "localhost",
    "127.0.0.1",
]

MERMAID_KEYWORDS = [
    "graph",
    "sequenceDiagram",
    "stateDiagram",
    "classDiagram",
    "journey",
]

ALLOWED_CODE_LANGUAGES = {
    "ts",
    "tsx",
    "typescript",
    "dart",
    "js",
    "json",
    "yaml",
    "bash",
    "sh",
    "html",
}

TS_LANGUAGE_SET = {"ts", "tsx", "typescript"}
DART_LANGUAGE_SET = {"dart"}

SKIP_DIRS = {
    "node_modules",
    ".git",
    ".next",
    "build",
    "dist",
    "out",
    "android",
    "ios",
    "macos",
    "linux",
    "windows",
    "artifacts",
    "artifact_4544009766_dir",
    "apps",
    "server",
}


def determine_governance(path: Path) -> bool:
    parts_lower = {part.lower() for part in path.parts}
    return "docs" in parts_lower and "ops" in parts_lower

IMAGE_PATTERN = re.compile(r"!\[([^\]]*)\]\(([^)]+)\)")
LINK_PATTERN = re.compile(r"\[([^\]]+)\]\(([^)]+)\)")
HEADING_PATTERN = re.compile(r"^(#{1,6})\s+(.+)")


@dataclass
class IssueEntry:
    path: Path
    line: int
    check: str
    message: str
    fixable: bool


class CheckLogger:
    def __init__(self) -> None:
        self.entries: List[IssueEntry] = []

    def log(
        self,
        severity: str,
        path: Path,
        line: int,
        check: str,
        message: str,
        fixable: bool = False,
        extra: Optional[dict] = None,
    ) -> None:
        payload = {
            "severity": severity,
            "file": str(path),
            "line": line,
            "check": check,
            "message": message,
            "fixable": fixable,
        }
        if extra:
            payload.update(extra)
        print(json.dumps(payload, ensure_ascii=False))
        if severity == "error":
            self.entries.append(IssueEntry(path, line, check, message, fixable))

    def error(
        self,
        path: Path,
        line: int,
        check: str,
        message: str,
        fixable: bool = False,
    ) -> None:
        self.log("error", path, line, check, message, fixable)

    def info(self, path: Path, message: str, extra: Optional[dict] = None) -> None:
        self.log("info", path, 0, "autofix", message, False, extra)


def atomic_write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        "w", encoding="utf-8", delete=False, dir=path.parent
    ) as tmp:
        tmp.write(content)
        tmp.flush()
        os.fsync(tmp.fileno())
    os.replace(tmp.name, path)


def slugify(text: str) -> str:
    normalized = re.sub(r"\s+", "-", text.strip().lower())
    normalized = re.sub(r"[^a-z0-9\-]", "", normalized)
    return normalized.strip("-")


def balanced_braces(text: str) -> bool:
    stack: List[str] = []
    pairs = {"(": ")", "{": "}", "[": "]"}
    inverse = {v: k for k, v in pairs.items()}
    for ch in text:
        if ch in pairs:
            stack.append(ch)
        elif ch in inverse:
            if not stack or stack[-1] != inverse[ch]:
                return False
            stack.pop()
    return not stack


def parse_frontmatter(lines: Sequence[str]) -> Tuple[Optional[dict], Optional[int], Optional[int]]:
    if not lines or lines[0].strip() != "---":
        return None, None, None
    for idx, line in enumerate(lines[1:], start=1):
        if line.strip() == "---":
            block = lines[1:idx]
            data = {}
            for raw in block:
                if ":" not in raw:
                    continue
                key, value = raw.split(":", 1)
                data[key.strip()] = value.strip()
            return data, 0, idx
    return {}, 0, None


def collect_targets(args: argparse.Namespace, root: Path) -> List[Path]:
    raw_paths: List[Path] = []
    if args.stdin_0:
        payload = sys.stdin.buffer.read()
        parts = payload.split(b"\x00")
        for chunk in parts:
            if chunk:
                raw_paths.append(Path(chunk.decode("utf-8", errors="ignore")))
    raw_paths.extend(Path(p) for p in args.paths or [])
    normalized = []
    for entry in raw_paths:
        candidate = entry
        if not candidate.is_absolute():
            candidate = (root / candidate).resolve()
        if any(part in SKIP_DIRS for part in candidate.parts):
            continue
        if candidate.is_file():
            normalized.append(candidate)
    normalized = sorted(set(normalized))
    if not normalized:
        raise SystemExit("No markdown targets were provided.")
    return normalized


def extract_headings(lines: Sequence[str]) -> List[Tuple[int, int, str]]:
    captured: List[Tuple[int, int, str]] = []
    for idx, raw in enumerate(lines):
        match = HEADING_PATTERN.match(raw)
        if not match:
            continue
        level = len(match.group(1))
        text = match.group(2).strip()
        if text:
            captured.append((idx + 1, level, text))
    return captured


def find_heading_line(lines: Sequence[str], pattern: str) -> Optional[int]:
    compiled = re.compile(pattern)
    for idx, line in enumerate(lines):
        if compiled.match(line):
            return idx + 1
    return None


def parse_toc(lines: Sequence[str]) -> Optional[List[str]]:
    start = None
    for idx, line in enumerate(lines):
        if re.match(r"^##\s+(目次|Table of Contents)", line):
            start = idx + 1
            break
    if start is None:
        return None
    entries: List[str] = []
    for line in lines[start:]:
        if re.match(r"^##\s+", line):
            break
        match = re.search(r"\[[^\]]+\]\(#([^)]+)\)", line)
        if match:
            entries.append(slugify(match.group(1)))
    return entries


def run_checks(
    targets: Iterable[Path], root: Path, logger: CheckLogger
) -> int:
    scanned = 0
    for path in targets:
        if not path.exists():
            continue
        content = path.read_text(encoding="utf-8", errors="replace")
        lines = content.splitlines()
        scanned += 1

        frontmatter, fm_start, fm_end = parse_frontmatter(lines)
        governed = determine_governance(path)
        if governed:
            if frontmatter is None:
                logger.error(
                    path,
                    1,
                    "frontmatter-missing",
                    "Frontmatter block missing or malformed (requires --- at start).",
                    fixable=True,
                )
            elif fm_end is None:
                logger.error(
                    path,
                    1,
                    "frontmatter-unclosed",
                    "Frontmatter block opened but never closed with ---.",
                    fixable=True,
                )
            else:
                for key in REQUIRED_FRONTMATTER:
                    if key not in frontmatter:
                        logger.error(
                            path,
                            1,
                            f"frontmatter-missing-{key}",
                            f"Frontmatter lacks `{key}`.",
                            fixable=True,
                        )
                source_val = frontmatter.get("source_of_truth", "").lower()
                if source_val not in {"true", "True", "TRUE"}:
                    logger.error(
                        path,
                        1,
                        "frontmatter-source",
                        "`source_of_truth` must be `true`.",
                        fixable=True,
                    )
                version_val = frontmatter.get("version", "")
                if version_val and not re.match(r"^\d+\.\d+\.\d+(-[\w\.]+)?$", version_val):
                    logger.error(
                        path,
                        1,
                        "frontmatter-version",
                        "`version` must follow `x.y.z` semantic versioning.",
                    )
                updated_val = frontmatter.get("updated_date", "")
                if updated_val:
                    try:
                        datetime.strptime(updated_val, "%Y-%m-%d")
                    except ValueError:
                        logger.error(
                            path,
                            1,
                            "frontmatter-updated-date",
                            "`updated_date` must use `YYYY-MM-DD` format.",
                        )
                owner_val = frontmatter.get("owner", "")
                if owner_val == "":
                    logger.error(
                        path,
                        1,
                        "frontmatter-owner",
                        "`owner` must reference a responsible owner team.",
                    )

        if governed:
            # section checks
            sections = [
                (r"^##\s+(背景|Background)", "section-background", "背景セクション"),
                (r"^##\s+(要件|Requirements)", "section-requirements", "要件セクション"),
                (r"^##\s+Runbook", "section-runbook", "Runbook セクション"),
                (r"^##\s+(更新|Updates)", "section-update", "更新セクション"),
                (
                    r"^##\s+DoD\s+\(Definition of Done\)",
                    "section-dod",
                    "DoD (Definition of Done) セクション",
                ),
            ]
            for pattern, code, label in sections:
                if not find_heading_line(lines, pattern):
                    logger.error(
                        path,
                        1,
                        code,
                        f"Missing required section: {label}.",
                        fixable=True if code == "section-dod" else False,
                    )

            headings = extract_headings(lines)
            if not headings:
                logger.error(
                    path,
                    1,
                    "heading-none",
                    "Document does not use Markdown headings.",
                )
            else:
                h1s = [entry for entry in headings if entry[1] == 1]
                if len(h1s) > 1:
                    logger.error(
                        path,
                        h1s[1][0],
                        "heading-h1-duplicate",
                        "Document must contain at most one H1.",
                    )
                last_level = 0
                for line_no, level, text in headings:
                    if last_level and level - last_level > 1:
                        logger.error(
                            path,
                            line_no,
                            "heading-order",
                            "Heading levels must increase by at most one.",
                        )
                    last_level = level

            toc_entries = parse_toc(lines)
            if toc_entries is None:
                logger.error(
                    path,
                    1,
                    "toc-missing",
                    "Table of Contents (目次) is required.",
                )
            else:
                toc_set = set(toc_entries)
                for line_no, level, text in headings:
                    if level in {2, 3}:
                        candidate = slugify(text)
                        if candidate and candidate not in toc_set:
                            logger.error(
                                path,
                                line_no,
                                "toc-missing-entry",
                                f"Heading `{text}` is missing from ToC.",
                            )

        # Mermaid validations
        in_mermaid = False
        block_start = 0
        block_lines: List[str] = []
        for idx, raw in enumerate(lines):
            stripped = raw.strip()
            if stripped.startswith("```mermaid"):
                in_mermaid = True
                block_start = idx + 1
                block_lines = []
                continue
            if in_mermaid:
                if stripped.startswith("```"):
                    if not block_lines:
                        logger.error(
                            path,
                            block_start,
                            "mermaid-empty",
                            "Mermaid block must include content.",
                        )
                    block_text = "\n".join(block_lines).lower()
                    if not any(keyword in block_text for keyword in MERMAID_KEYWORDS):
                        logger.error(
                            path,
                            block_start,
                            "mermaid-keyword",
                            "Mermaid block lacks a diagram keyword.",
                        )
                    in_mermaid = False
                else:
                    block_lines.append(raw)
        if in_mermaid:
            logger.error(
                path,
                block_start,
                "mermaid-unclosed",
                "Mermaid block requires closing ``` marker.",
            )

        # Link and image validation
        for idx, line in enumerate(lines):
            for match in IMAGE_PATTERN.finditer(line):
                alt_text, target = match.groups()
                if not alt_text.strip():
                    logger.error(
                        path,
                        idx + 1,
                        "image-alt-empty",
                        "Image alt text should be descriptive.",
                    )
                target = target.split("#", 1)[0].split("?", 1)[0]
                if not target:
                    logger.error(
                        path,
                        idx + 1,
                        "image-target-empty",
                        "Image link must include a target path.",
                    )
                    continue
                if target.startswith("http"):
                    continue
                candidate = (path.parent / target).resolve()
                if not candidate.exists():
                    logger.error(
                        path,
                        idx + 1,
                        "image-missing",
                        f"Referenced image `{target}` does not exist.",
                    )

            for match in LINK_PATTERN.finditer(line):
                target = match.group(2).strip()
                if target.startswith("http://"):
                    logger.error(
                        path,
                        idx + 1,
                        "link-insecure",
                        "External links must use https.",
                    )
                if any(domain in target.lower() for domain in DISALLOWED_EXTERNAL_DOMAINS):
                    logger.error(
                        path,
                        idx + 1,
                        "link-domain",
                        f"External link to prohibited domain found: {target}",
                    )
                if target.startswith(("http://", "https://", "mailto:", "#", "tel:")):
                    continue
                stripped = target.split("#", 1)[0]
                if not stripped:
                    logger.error(
                        path,
                        idx + 1,
                        "link-empty-target",
                        "Relative link target is empty.",
                    )
                    continue
                candidate = (path.parent / stripped).resolve()
                if not candidate.exists():
                    logger.error(
                        path,
                        idx + 1,
                        "link-missing",
                        f"Link target `{stripped}` not found.",
                    )

        # Forbidden words
        for idx, line in enumerate(lines):
            lowered = line.lower()
            for word in FORBIDDEN_WORDS:
                if re.search(rf"\b{re.escape(word)}\b", lowered):
                    logger.error(
                        path,
                        idx + 1,
                        "forbidden-word",
                        f"Forbidden wording detected: {word}",
                    )

        # Code fence checks
        open_block: Optional[dict] = None
        for idx, line in enumerate(lines):
            trimmed = line.strip()
            if trimmed.startswith("```"):
                if open_block is None:
                    language = trimmed[3:].strip()
                    open_block = {"start": idx + 1, "language": language, "body": []}
                else:
                    body_text = "\n".join(open_block["body"])
                    language = (open_block["language"] or "").lower()
                    if not language:
                        logger.error(
                            path,
                            open_block["start"],
                            "codefence-language",
                            "Code fence must declare a language.",
                        )
                    if language and language not in ALLOWED_CODE_LANGUAGES:
                        logger.error(
                            path,
                            open_block["start"],
                            "codefence-language-unsupported",
                            f"Unsupported language: {language}",
                        )
                    if language in TS_LANGUAGE_SET | DART_LANGUAGE_SET:
                        if not balanced_braces(body_text):
                            logger.error(
                                path,
                                open_block["start"],
                                "codefence-braces",
                                f"Braces are not balanced in {language} sample.",
                            )
                    open_block = None
            elif open_block:
                open_block["body"].append(line)
        if open_block:
            logger.error(
                path,
                open_block["start"],
                "codefence-unclosed",
                "Code fence opened but never closed.",
            )

        # Table checks
        for idx in range(len(lines) - 1):
            header = lines[idx]
            separator = lines[idx + 1]
            if "|" not in header or "-" not in separator:
                continue
            header_count = sum(1 for segment in header.split("|") if segment.strip())
            separator_count = sum(
                1 for segment in separator.split("|") if set(segment.strip()) <= {"-", ":"}
            )
            if header_count and separator_count and header_count != separator_count:
                logger.error(
                    path,
                    idx + 1,
                    "table-columns",
                    "Table columns do not align between header and separator.",
                )

    return scanned


def rebuild_frontmatter_block(lines: Sequence[str]) -> List[str]:
    existing = {}
    for raw in lines:
        if ":" not in raw:
            continue
        key, value = raw.split(":", 1)
        existing[key.strip()] = value.strip()
    rebuilt = ["---"]
    for key in REQUIRED_FRONTMATTER:
        value = existing.get(key)
        if not value:
            fallback = DEFAULT_FRONTMATTER_VALUES[key]
            if callable(fallback):
                value = fallback()
            else:
                value = fallback
        rebuilt.append(f"{key}: {value}")
    for raw in lines:
        if ":" in raw:
            key = raw.split(":", 1)[0].strip()
            if key in REQUIRED_FRONTMATTER:
                continue
        rebuilt.append(raw)
    rebuilt.append("---")
    rebuilt.append("")
    return rebuilt


def ensure_frontmatter(path: Path, logger: CheckLogger) -> bool:
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()
    frontmatter, fm_start, fm_end = parse_frontmatter(lines)
    governed = determine_governance(path)
    if not governed:
        return False
    needs_fix = False
    if frontmatter is None or fm_end is None:
        default = "\n".join(rebuild_frontmatter_block([])) + "\n"
        new_text = default + text.lstrip()
        if not new_text.endswith("\n"):
            new_text += "\n"
        atomic_write(path, new_text)
        logger.info(path, "Frontmatter block auto-fix applied.")
        needs_fix = True
    else:
        existing_lines = lines[1:fm_end]
        rebuilt = rebuild_frontmatter_block(existing_lines)
        new_text = "\n".join(rebuilt + lines[fm_end + 1 :])  # type: ignore[index]
        if new_text != text:
            if not new_text.endswith("\n"):
                new_text += "\n"
            atomic_write(path, new_text)
            logger.info(path, "Frontmatter schema auto-fix applied.")
            needs_fix = True
    return needs_fix


def ensure_dod_section(path: Path, logger: CheckLogger) -> bool:
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()
    governed = determine_governance(path)
    if not governed:
        return False
    if re.search(r"^##\s+DoD\s+\(Definition of Done\)", text, re.MULTILINE):
        return False
    addition = "\n\n## DoD (Definition of Done)\n- [ ] 文書の目的と完了基準を明記しました。\n"
    atomic_write(path, (text.rstrip() + addition + "\n"))
    logger.info(path, "DoD (Definition of Done) section appended.")
    return True


def run_autofix(paths: Sequence[Path], logger: CheckLogger) -> bool:
    fixed = False
    for path in paths:
        fixed |= ensure_frontmatter(path, logger)
        fixed |= ensure_dod_section(path, logger)
    return fixed


def build_report(
    report_path: Path,
    summary: dict,
    issues: List[IssueEntry],
    args: argparse.Namespace,
) -> None:
    timestamp = summary["timestamp"]
    lines = [
        "---",
        "source_of_truth: true",
        "version: 1.0.0",
        f"updated_date: {timestamp.split('T')[0]}",
        "owner: STARLIST Docs Automation Team",
        "---",
        "",
        "# Markdown CI Report",
        "",
        "## 最新の実行",
        f"- 実行日時: {timestamp}",
        f"- コマンド: `{summary['command']}`",
        f"- ファイル数: {summary['files_scanned']}",
        f"- エラー数: {summary['errors']}",
        f"- 自動修復: {'有効' if args.autofix else '無効'}",
        f"- ドライラン: {'有効' if args.dry_run else '無効'}",
        "",
        "## 指標",
        f"- `reports_generated`: {summary['reports_generated']}",
        f"- `fixes_applied`: {summary['fixes_applied']}",
        "",
        "## 失敗一覧",
    ]
    if not issues:
        lines.append("すべてのチェックを通過しました。")
    else:
        lines.extend(
            [
                "| ファイル | 行 | チェック | メッセージ | 修復可能 |",
                "| --- | --- | --- | --- | --- |",
            ]
        )
        max_entries = 200
        for entry in issues[:max_entries]:
            try:
                relative = entry.path.relative_to(Path.cwd())
            except ValueError:
                relative = entry.path
            lines.append(
                f"| {relative} | {entry.line} | {entry.check} | {entry.message} | {'はい' if entry.fixable else 'いいえ'} |"
            )
        remaining = len(issues) - max_entries
        if remaining > 0:
            lines.append(
                f"> 表は先頭 {max_entries} 件まで表示し、残り {remaining} 件はログファイルを参照してください。"
            )
    atomic_write(report_path, "\n".join(lines) + "\n")


def summarize(
    scanned: int,
    logger: CheckLogger,
    args: argparse.Namespace,
    fixes_applied: bool,
) -> dict:
    timestamp = datetime.utcnow().isoformat(timespec="seconds") + "Z"
    max_args = 6
    preview_args = sys.argv[:max_args]
    extra_args = max(0, len(sys.argv) - max_args)
    command_preview = " ".join(shlex.quote(arg) for arg in preview_args)
    if extra_args > 0:
        command_preview += f" ...(+{extra_args} more args)"
    entry = {
        "status": "pass" if not logger.entries else "fail",
        "files_scanned": scanned,
        "errors": len(logger.entries),
        "timestamp": timestamp,
        "command": command_preview,
        "dry_run": args.dry_run,
        "autofix": args.autofix,
        "fixes_applied": fixes_applied,
        "reports_generated": 1 if args.report else 0,
    }
    print(json.dumps({"type": "summary", **entry}, ensure_ascii=False))
    return entry


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="STARLIST Extended Markdown Governance Validator"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Run checks without modifying files (default behavior).",
    )
    parser.add_argument(
        "--autofix",
        action="store_true",
        help="Attempt to auto-correct missing frontmatter or DoD sections.",
    )
    parser.add_argument(
        "--report",
        type=Path,
        help="Write Markdown test report to the specified path.",
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=Path.cwd(),
        help="Root directory for resolving relative links.",
    )
    parser.add_argument(
        "--stdin-0",
        action="store_true",
        help="Read null-delimited paths from STDIN (for find . -print0).",
    )
    parser.add_argument("paths", nargs="*", help="Markdown files to validate.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    root = args.root.resolve()
    logger = CheckLogger()
    targets = collect_targets(args, root)
    scanned = run_checks(targets, root, logger)

    fixes_applied = False
    if args.autofix:
        fixes_applied = run_autofix(targets, logger)
        if fixes_applied:
            logger = CheckLogger()
            scanned = run_checks(targets, root, logger)

    summary = summarize(scanned, logger, args, fixes_applied)
    if args.report:
        build_report(args.report, summary, logger.entries, args)

    exit_code = 0 if not logger.entries else 1
    sys.exit(exit_code)


if __name__ == "__main__":
    main()

