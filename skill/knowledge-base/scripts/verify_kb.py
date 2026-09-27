"""Deterministic checks for a generated knowledge base: frontmatter, links/anchors, IDs, secrets.

Usage: python verify_kb.py <kb-folder>
Exit code 1 if any ERROR is found.
"""
import re
import sys
from pathlib import Path

REQUIRED_KEYS = ["title", "kb_type", "project", "kb_id_prefix", "tags", "generated", "commit", "source_root", "status"]
SECRET_PATTERNS = {
    "aws-key-id": r"\b(AKIA|ASIA)[A-Z0-9]{16}\b",
    "private-key": r"-----BEGIN [A-Z ]*PRIVATE KEY-----",
    "github-token": r"\bghp_[A-Za-z0-9]{20,}",
    "slack-token": r"\bxox[abpr]-[A-Za-z0-9-]{10,}",
    "api-key": r"\bsk-[A-Za-z0-9]{20,}",
    "assignment": r"(?i)\b(password|secret|token)\s*=\s*[^\s`'\"<]{4,}",
    "conn-string": r"\b\w+://[^\s:/@]+:[^\s@]+@",
    "email": r"\b[\w.+-]+@[\w-]+\.[\w.-]+\b",
    "long-b64-hex": r"\b[A-Za-z0-9+/]{40,}={0,2}\b",
}
FAKE_OK = {"123456789012"}

errors, warnings = [], []


def slug(text):
    # GitHub-style: strip markdown code/emphasis, lower-case, drop punctuation except - and _, spaces -> -.
    text = re.sub(r"[`*]", "", text).strip().lower()
    text = re.sub(r"[^\w\- ]", "", text)
    return text.replace(" ", "-")


def strip_fences(lines):
    out, fenced = [], False
    for line in lines:
        if line.lstrip().startswith("```"):
            fenced = not fenced
            out.append("")
            continue
        out.append("" if fenced else line)
    return out


def main(root):
    root = Path(root)
    files = sorted(root.rglob("*.md"))
    if not files:
        errors.append(f"no .md files under {root}")
        return
    anchors, frontmatters, bodies = {}, {}, {}
    for f in files:
        text = f.read_text(encoding="utf-8")
        m = re.match(r"\A---\r?\n(.*?)\r?\n---\r?\n", text, re.S)
        if not m:
            errors.append(f"{f.name}: missing YAML frontmatter")
            fm = {}
        else:
            fm = dict(re.findall(r"^(\w+):\s*(.*?)\s*(?:#.*)?$", m.group(1), re.M))
            for k in REQUIRED_KEYS:
                if k not in fm:
                    errors.append(f"{f.name}: frontmatter missing '{k}'")
        frontmatters[f] = fm
        body = strip_fences(text.splitlines())
        bodies[f] = body
        seen = {}
        for line in body:
            h = re.match(r"^#{1,6}\s+(.*)$", line)
            if h:
                s = slug(h.group(1))
                n = seen.get(s, 0)
                seen[s] = n + 1
                anchors.setdefault(f.resolve(), set()).add(s if n == 0 else f"{s}-{n}")

    for key in ("commit", "generated", "kb_id_prefix", "project"):
        vals = {fm.get(key) for fm in frontmatters.values() if fm}
        if len(vals) > 1:
            errors.append(f"frontmatter '{key}' differs across files: {sorted(v or '' for v in vals)}")

    prefix = next((fm.get("kb_id_prefix") for fm in frontmatters.values() if fm.get("kb_id_prefix")), None)
    id_re = re.compile(rf"\b{re.escape(prefix)}-(?:KB-\d+|[CIEFQ]\d+)\b") if prefix else None
    defined_ids, link_count = set(), 0

    for f, body in bodies.items():
        for i, line in enumerate(body, 1):
            h = re.match(r"^###\s+(\S+)\s*$", line)
            if h and id_re and id_re.fullmatch(h.group(1)):
                defined_ids.add(h.group(1))
            for target in re.findall(r"\]\(([^)\s]+)\)", line):
                if re.match(r"^[a-z]+:", target):
                    continue
                link_count += 1
                path_part, _, frag = target.partition("#")
                dest = (f.parent / path_part).resolve() if path_part else f.resolve()
                if not dest.exists():
                    errors.append(f"{f.name}:{i}: broken link target '{target}'")
                elif frag and dest.suffix == ".md" and frag not in anchors.get(dest, set()):
                    errors.append(f"{f.name}:{i}: missing anchor '#{frag}' in {dest.name}")

    if id_re:
        for f, body in bodies.items():
            for i, line in enumerate(body, 1):
                if re.match(r"^###\s+\S+\s*$", line):
                    continue
                unlinked = re.sub(r"\[[^\]]*\]\([^)]*\)", "", line)
                for m in id_re.finditer(unlinked):
                    warnings.append(f"{f.name}:{i}: ID {m.group(0)} mentioned without a link")
            for m in id_re.finditer("\n".join(body)):
                if m.group(0) not in defined_ids:
                    errors.append(f"{f.name}: ID {m.group(0)} has no '### {m.group(0)}' heading anywhere")

    for f in files:
        raw = f.read_text(encoding="utf-8")
        for name, pat in SECRET_PATTERNS.items():
            for m in re.finditer(pat, raw):
                if m.group(0) in FAKE_OK:
                    continue
                warnings.append(f"{f.name}: possible secret ({name}): {m.group(0)[:40]}")
        for m in re.finditer(r"\b\d{12}\b", raw):
            if m.group(0) not in FAKE_OK:
                warnings.append(f"{f.name}: 12-digit number (AWS account ID?): {m.group(0)}")

    print(f"files={len(files)} links={link_count} ids_defined={len(defined_ids)} prefix={prefix}")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "docs/knowledge-base")
    for w in sorted(set(warnings)):
        print("WARN ", w)
    for e in sorted(set(errors)):
        print("ERROR", e)
    print(f"{len(set(errors))} error(s), {len(set(warnings))} warning(s)")
    sys.exit(1 if errors else 0)
