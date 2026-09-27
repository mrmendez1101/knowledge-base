# AGENTS.md snippet

Paste the section below into the project's `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` or
`.github/copilot-instructions.md`. It helps agents that do not scan `.claude/skills/`, and it
tells every agent the KB exists. If you installed with `-Agents` / `--agents`, the skill is also at
`.agents/skills/knowledge-base/`; either path works.

---

## Project knowledge base

- An evidence-backed knowledge base lives in `docs/knowledge-base/`. **New to the codebase? Start
  with `docs/knowledge-base/onboarding.md`.**
- Before a large change, check `docs/knowledge-base/findings.md` and
  `docs/knowledge-base/data-flows.md` for known issues and flows.
- To generate or refresh it, follow `.claude/skills/knowledge-base/SKILL.md` (or
  `.agents/skills/knowledge-base/SKILL.md`). Read its
  `references/` files at the steps it names.
  - Use mode `update` after code changes.
  - Use mode `vault` for Obsidian and graphify.
- The knowledge base is generated. Do not hand-edit rows; re-run in `update` mode. Humans may
  change the frontmatter `status` to `reviewed`.
