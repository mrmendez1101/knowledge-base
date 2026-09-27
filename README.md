# knowledge-base-prompt

A portable prompt that generates an **evidence-backed onboarding knowledge base** for any code
repository. The output is linked Markdown in `docs/knowledge-base/` with these files:

- onboarding guide
- architecture
- data flows (ingress and egress)
- environment variables
- configuration
- dependencies
- security
- tests
- findings

Every claim cites `path:line` and is labelled Verified, Inferred or Unknown. Secrets are recorded by
name only. The output has frontmatter and is cross-linked, so it drops straight into **Obsidian**
and **graphify**.

One source works in Claude Code, GitHub Copilot, Kimi, and any other LLM.

## Layout

```
skill/knowledge-base/          canonical source; installed as <repo>/.claude/skills/knowledge-base/
  SKILL.md                     rules and phases (short; loads references at the right step)
  references/                  search hints, implicit env vars, output templates, onboarding,
                               Obsidian/graphify rules, update mode, verification checklist
adapters/copilot/              .github/prompts wrapper -> /knowledge-base in Copilot Chat
adapters/agents-md-snippet.md  pointer text for AGENTS.md / CLAUDE.md / copilot-instructions.md
scripts/install.(ps1|sh)       install into a target repository
scripts/build-single.(ps1|sh)  bundle everything into dist/knowledge-base.single.md for web chats
tests/golden/                  regression checklist (nodejs-lambda-playground)
legacy/                        the original single-file v1 prompt, kept for reference
```

## Install into a project

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install.ps1 -Target "C:\path\to\your-repo"
```

The `-ExecutionPolicy Bypass` part is needed because Windows blocks unsigned scripts by default.

```bash
scripts/install.sh /path/to/your-repo
```

This creates:

- `.claude/skills/knowledge-base/`, which Claude Code, GitHub Copilot and Kimi CLI all read.
- `.github/prompts/knowledge-base.prompt.md`, which gives Copilot Chat in VS Code a
  `/knowledge-base` command.

Optional flags:

- `-Agents` / `--agents` also copies the skill to `.agents/skills/`, the generic Agent Skills
  folder. Copilot and Kimi CLI are confirmed to read it; check your tool's docs for others.
- `-Force` / `--force` updates an existing install.
- `-User` / `--user` installs once for your user account instead of into a repository:
  `%USERPROFILE%\.claude\skills\knowledge-base` on Windows, `~/.claude/skills/knowledge-base` on
  macOS and Linux. Omit the target. The Copilot prompt file is skipped because it only works
  inside a repository.

Commit both folders so the whole team gets the command.

## Use it

| Tool | How | Notes |
|---|---|---|
| **GitHub Copilot, VS Code** | Chat in **Agent** mode, then `/knowledge-base` (add `update`, `vault`, or a folder) | Ask mode has no file tools. The skill detects that and asks you to switch |
| GitHub Copilot CLI | `/skills` to confirm it loaded, then ask "generate the knowledge base" | |
| Copilot cloud agent | Assign an issue: "Run the knowledge-base skill in update mode" | The KB refresh arrives as a PR |
| Claude Code | `/knowledge-base [folder] [update] [vault]` | |
| Kimi CLI | `/skill:knowledge-base [args]` | |
| Kimi / ChatGPT / Gemini web chat | Run `scripts/build-single.ps1`, then attach `dist/knowledge-base.single.md` plus the project files | Produces one KB file per reply; say "continue" |
| Cursor / Codex / Gemini CLI | Paste the snippet from `adapters/agents-md-snippet.md` into `AGENTS.md`, or install with `-Agents` if your tool reads `.agents/skills` | Not yet verified; log results in `tests/golden/` |

**Modes:**

- `full` (default).
- `update`: re-verifies only the rows that cite files changed since the recorded commit. IDs stay
  stable.
- `vault`: adds one note per entity for Obsidian's graph and graphify.

## Obsidian and graphify workflow

1. Optional: run `/graphify .` first. The skill reads `graphify-out/GRAPH_REPORT.md` for leads.
   graphify is set up with `uv tool install graphifyy` and then `graphify install`.
2. Run `/knowledge-base vault`.
3. Run `/graphify . --update` to fold the KB into the code graph. Add `--obsidian` to export a
   vault.
4. Open the repo, or `docs/knowledge-base/`, in Obsidian. To keep one team vault, symlink each
   project's KB to `<vault>/projects/<project>/`. The ID prefixes keep projects apart.

Add a `.graphifyignore` containing `.env*` and any credential files. graphify sends document text
to an LLM backend.

## Developing the prompt

- Edit only `skill/knowledge-base/`. Keep `SKILL.md` short and put lookup-style content in
  `references/`. It is about 11 KB now; the goal is under 8 KB. `SKILL.md` must name the step at which each reference is
  read.
- Keep `SKILL.md` free of tool-specific syntax: no `$ARGUMENTS`, `${input:…}` or tool names.
  Adapters map their own argument syntax onto the plain-language inputs in the
  "Inputs, modes and capabilities" section.
- Check any generated KB with `python skill/knowledge-base/scripts/verify_kb.py <repo>/docs/knowledge-base`
  (use `python3` on macOS and Linux if `python` is not found).
  It checks frontmatter, links and anchors, IDs and secret patterns, and is safe to run in CI.
- After changes, run `scripts/build-single.ps1`, re-install into the fixture repository
  (nodejs-lambda-playground, kept as a sibling checkout at `../nodejs-lambda-playground`), and work through
  `tests/golden/lambda-playground.md` on at least Copilot and one other tool. Log the result in the
  file's results table.
