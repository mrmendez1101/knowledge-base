# Golden fixture: nodejs-lambda-playground

Regression check for the skill on every tool. The v1 prompt found all of the items below, and the
new version must still find them. Run the skill on the fixture repository, nodejs-lambda-playground,
expected as a sibling checkout at `../nodejs-lambda-playground` (a copy works too). Then tick this
list against the generated `docs/knowledge-base/`.

**A run fails if any Must item is missing.**

Use the same list for each tool: Copilot (VS Code agent mode), Copilot CLI, Claude Code, Kimi CLI,
and a web-chat LLM given `dist/knowledge-base.single.md` plus the files.

## Must: findings

- [ ] **High, test gap:** `test/lambda-invoker.spec copy.js` does not match the `.mocharc.json` spec
      glob, so only 2 of 7 tests run.
- [ ] **High, bug:** `response.FunctionError` is ignored. A function error payload is returned as
      success (`src/lambda-invoker.js`).
- [ ] **Medium, security:** the full invoke response is logged at info level.
- [ ] **Medium, bug:** `JSON.stringify(error)` logs `{}` and loses the message and stack.
- [ ] **Medium, config drift:** region is hard-coded to `us-east-1`, so `AWS_REGION` and
      `config` have no effect.
- [ ] Stale `SETUP.md` claims are flagged, with citations.
- [ ] The stray 0-byte `{})` file is flagged.
- [ ] `.env` is git-ignored, but no loader exists.

## Must: coverage

- [ ] `environment.md` lists `ENV` as explicit, read but unused, plus the AWS SDK implicit
      credential and region chain, marked Inferred.
- [ ] Egress covers the Lambda `Invoke` call **and** every `console.*` call.
- [ ] `dependencies.md` gives resolved versions from `package-lock.json` for every direct
      dependency.
- [ ] `testing.md` shows the real Mocha glob match list.

## Must: structure (this version)

- [ ] `onboarding.md` exists and has a reading path that starts at `src/lambda-invoker.js`.
- [ ] Every file has frontmatter. `project` and `kb_id_prefix` are consistent (for example
      `LAMBDA`).
- [ ] IDs are prefixed, and findings link to `data-flows.md` / `environment.md` anchors.
- [ ] `_inventory.md` exists. `docs/knowledge-base/` is **not** audited as a project file.
- [ ] The secret scan is clean: no real account IDs, keys or emails.

## Must: guard rails

- [ ] Copilot **Ask** mode, and a web chat with no files attached: the model stops with the
      "needs file access" message instead of inventing a KB.
- [ ] No-write mode (web chat): one file per reply, each ending with "Reply "continue"...".

## Should

- [ ] `update` mode, after a one-line edit to `src/lambda-invoker.js`, changes only the rows that
      cite that file, bumps `commit`, and adds a change log entry.
- [ ] `vault` mode writes `entities/**` notes that link back to their source tables.
- [ ] Obsidian graph view shows the KB files connected, with the README as the hub.
- [ ] `/graphify docs/knowledge-base` reports `references` edges between KB files.

## Results log

| Date | Tool / model | Mode | Must passed | Notes |
|---|---|---|---|---|
| 2026-09-28 | Claude Code / Opus 5.5 (skill followed by hand in a scratch copy) | full | Findings 8/8, Coverage 4/4, Structure 5/5. Guard rails not tested | `verify_kb.py`: 0 errors after 1 fix (an unlinked ID in a table cell). Exposed 3 skill fixes, all applied: ID prefix derivation, grouped env headings, verifier added. Not a blind run: the author knew the v1 findings |
