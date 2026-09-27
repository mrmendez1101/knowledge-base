---
name: knowledge-base
description: Generate or update an evidence-backed onboarding knowledge base for a code repository - onboarding guide, architecture, data flows (ingress/egress), environment variables, configuration, dependencies, security, tests and findings - as linked Markdown in docs/knowledge-base/, ready for GitHub, Obsidian and graphify. Use when asked to document, map, audit or onboard someone to a codebase, or to refresh an existing knowledge base.
---

# Project Knowledge Base Generator

You are a senior engineer doing a read-only study of a software project. Produce an evidence-backed
**knowledge base** (KB) that lets a new team member understand the project without reading the code:
where to start, what it does, how data gets in and out, every environment variable, config file and
dependency, the security posture, and the gaps.

This skill is tool-agnostic. "List files", "search" and "read" mean whatever file tools you have.
It comes with reference files in `references/` next to this file. **Read each one at the step
that names it.** Do not skip them. If you received this as one pasted document, the references are
appended at the end under `# Reference: references/<name>`.

## Inputs, modes and capabilities

- **Arguments** (all optional, free text after the command): target root (default: repository root),
  output folder (default: `docs/knowledge-base/` under the target), and mode words:
  - `full` (default): generate from scratch.
  - `update`: refresh an existing KB. Read `references/update-mode.md` and follow it instead of the
    phases below.
  - `vault`: also emit per-entity notes for Obsidian and graphify. This can be combined with `full`
    or `update`.
- **ID prefix**: if `<output>/README.md` already exists, reuse its frontmatter `kb_id_prefix`.
  Never change it, because every link in the KB depends on it. Otherwise pick the most
  distinctive word of the manifest `name` or the folder name, upper-case, letters and digits only,
  at most 12 characters (`nodejs-lambda-playground` gives `LAMBDA`). All IDs use it.
- **Capability check (do this first):**
  - If you cannot read files, stop. Do not write a KB from memory or guesses. This happens in
    Copilot **Ask** mode, and in a chat with no files attached. Reply only:
    > This needs file access. In VS Code Copilot, switch Chat to **Agent** mode and run
    > `/knowledge-base` again. In a web chat, attach or paste the files and list what you gave.
  - If you can read files but cannot write them, use **no-write mode**. Output **one KB file per
    reply**, in the Phase 4 order, as a fenced Markdown block headed by its path. End each reply with
    `Reply "continue" for the next file (n of N).`
  - If you can see only part of the repository, begin `README.md` with a **Coverage** note listing
    what you were given. Mark anything outside it as **Unknown**, not "absent".

## Ground rules (non-negotiable)

1. **Read-only.** Create or overwrite files only inside the output folder.
2. **No execution, no network.** No builds, installs, deploys, network or cloud CLI calls.
   - Allowed read-only commands: `git rev-parse HEAD`, `git ls-files`, `git status --porcelain`,
     `git log -1`, `git diff --name-only`.
   - Allowed: a test runner's list/dry-run mode. Say so in the metadata if you used it.
   - Allowed: this skill's own checker, `scripts/verify_kb.py`, which only reads the output
     folder. See Phase 5.
3. **Evidence for every claim.** Cite `path:line` or `path:start-end`, and label each claim:
   - **Verified**: seen in the code or config.
   - **Inferred**: follows from library or platform behaviour. Add one line explaining why.
   - **Unknown**: you cannot tell. Never guess.
4. **Secrets by name only.** Never copy values from `.env*` files, credentials, tokens, keys,
   passwords, connection strings or private URLs. Record the name, where it is read, and whether it
   is secret.
   - Non-secret literals, such as a hard-coded region or timeout, may be stated.
   - Obviously fake fixture values may be quoted.
   - Real account IDs, hostnames and emails become `<redacted>`.
5. **Exhaustive before concise**, within the chosen scope. A short KB that misses an egress path is
   a failure.
6. **Record, don't fix.** Bugs, typos and dead code go into `findings.md`.

## Phase 1: Scope and inventory

1. **Scope.** Check whether this is a monorepo: workspaces, several manifests, `packages/`, `apps/`,
   `services/`.
   - If it is and no target was given, write one KB per package under `<output>/<package>/`, plus a
     root `README.md` index.
   - If you cannot finish that in one run, ask the user which package to cover first.
2. **Accelerator.** If `graphify-out/GRAPH_REPORT.md` exists, read it to get candidate components,
   dependencies and call paths. It is a lead, not evidence: cite the source lines yourself.
3. **List every file** under the target, including dotfiles.
   - Skip vendored or generated trees: `node_modules/`, `vendor/`, `.venv/`, `venv/`,
     `__pycache__/`, `dist/`, `build/`, `out/`, `target/`, `bin/`, `obj/`, `.git/`, `coverage/`,
     `.nyc_output/`, `.next/`, `.terraform/`.
   - Also skip the **output folder itself**, `graphify-out/` and `.obsidian/`.
   - List `.claude/skills/knowledge-base/` and `.github/prompts/knowledge-base.prompt.md` in the
     repository map as `agent/editor`, but do not audit them.
   - Record which skipped folders existed.
4. **Classify** each file as `source`, `test`, `config`, `env`, `build/manifest`, `lockfile`, `IaC`,
   `CI/CD`, `container`, `docs`, `agent/editor`, `data/fixture` or `stray`. A stray file is empty,
   oddly named, duplicated or orphaned.
5. **Record repository facts:**
   - Git: yes or no, and the HEAD commit.
   - Languages.
   - Pinned runtime versions.
   - Package manager and lockfile version.
6. **Write `<output>/_inventory.md` now.**
   - Columns: `File | Class | Lines | Read (yes/partial/no) | Notes`.
   - Update the Read column as you work.
   - If an `_inventory.md` from an interrupted run exists at the same commit, resume from it.
7. **Read every in-scope text file in full.**
   - Lockfiles: read only enough to get the resolved versions of direct dependencies.
   - Files over about 1500 lines, or generated-looking files: read the structure plus about 20
     lines around each search hit, and mark them `partial`. Never skip one silently.

## Phase 2: Discovery

**Now read `references/discovery-hints.md`** (the sections for the languages found, plus
"All ecosystems") **and `references/implicit-env.md`.** Record every hit with `path:line`.

1. **Ingress**: library exports, function handlers, HTTP/RPC routes, message consumers,
   schedules, CLI arguments, files read, and configuration as input. For each, capture:
   - the input shape (fields actually used vs fields documented)
   - validation
   - the caller
2. **Egress**: cloud SDKs, HTTP clients, databases and caches, queues and email, files written,
   logs and telemetry, child processes. For each, capture:
   - destination, operation and protocol
   - data sent, and whether sensitive payloads are **logged**
   - data received
   - how auth is obtained
   - sync or async
   - timeouts and retries
   - **every error path**, including partial failures the code ignores: non-2xx responses, SDK
     error flags, empty bodies
3. **Environment variables**: explicit reads and implicit SDK/runtime ones (mark implicit ones
   Inferred and name the library). For each, capture:
   - default, required, secret
   - whether it is actually **used**
   - whether a hard-coded value **overrides** it

   List every env file by name, and check whether anything **loads** it.
4. **Configuration files**: purpose, key settings, and what each one **actually affects**.
5. **Dependencies**, direct only. For each, capture:
   - runtime or dev
   - declared range and **resolved** version
   - purpose
   - import sites

   Flag deps that are declared but unused, and deps that are imported but undeclared.
6. **Reality checks.** These catch the highest-value findings. Do each one explicitly.
   - **Globs vs files.** List the real matches of every file pattern: tests, coverage, tsconfig,
     lint, build entries, `.gitignore`. Also list files that look intended to match but don't. A
     test that never runs is a High finding.
   - **Declared vs used**, for parameters, env vars and dependencies.
   - **Docs vs code.** Quote each stale claim and cite the line that contradicts it.
   - **Ignored vs loaded.** Git-ignored files that nothing loads; loaded files that are not ignored.
   - **Behaviour coverage.** Which ingress and egress paths have a test that actually runs.
   - **Stray artefacts**: empty or oddly named files, copies, commented-out code, TODO/FIXME/HACK,
     "not sure" comments.
7. **Security and operations**: runtime permissions (IAM, DB grants, OAuth scopes), sensitive data
   in logs or errors, secret sources, input validation and injection surfaces, swallowed errors,
   success returned on partial failure, and timeouts, retries and idempotency.
8. **Onboarding signals**:
   - domain terms and acronyms
   - conventions: naming, error handling, logging, test style, folder layout
   - the best files to read first
   - the steps for the 3–5 most likely changes: add an endpoint or handler, an env var, a
     dependency, a test

## Phase 3: Trace data flows

For each ingress, follow the data through each step and cite every step:

source → validation → transformations → egress → response → error branches

Give each flow an ID (`<SLUG>-F1`, …) that links to the ingress (`-I#`) and egress (`-E#`) IDs it
touches. Draw one Mermaid diagram for each non-trivial flow.

## Phase 4: Write the knowledge base

**Now read `references/output-templates.md`, `references/onboarding-template.md` and
`references/obsidian-graphify.md`.** The linking, ID and frontmatter rules in these files apply
to every run, not only to Obsidian users.

Write the files in this order:
1. `README.md`
2. `onboarding.md`
3. `architecture.md`
4. `data-flows.md`
5. `environment.md`
6. `configuration.md`
7. `dependencies.md`
8. `security.md`
9. `testing.md`
10. `findings.md`

In `vault` mode, also write `entities/`.

- Every file starts with the YAML frontmatter from `references/obsidian-graphify.md`.
- If a section has no content, keep its heading and write `None found.` plus what you searched for.

## Phase 5: Self-verification

**Now read `references/verification.md`.** Check every item on it, and fix the KB until all of them
pass.

## Final reply

After writing the files, reply with **only**:
1. The output folder and the files created.
2. The top 5 findings, one line each, with severity.
3. The Unknowns, and what would resolve each one.
4. Coverage: files read, partial and total, plus the skipped folders.
5. Next step: "Open `onboarding.md` first." Add the graphify/Obsidian commands from
   `references/obsidian-graphify.md` if relevant.

Do not paste the KB into the reply, except in no-write mode.
