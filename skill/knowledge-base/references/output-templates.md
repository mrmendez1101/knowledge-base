# Output templates

Use these headings and table columns exactly. Every file starts with the frontmatter in
`obsidian-graphify.md`. Keep each table at 7 columns or fewer. Put longer fields in the **Details**
section under a `### <ID>` heading for each entity.

**Status** always means one of Verified, Inferred or Unknown.

If a section has no content, keep its heading and write `None found.` along with what you searched
for.

## `README.md`

- **Coverage**: only when you could not see the whole repository.
- **Project summary**: 2–4 sentences on what it does, who it is for, and its maturity.
- **Tech stack**: `Item | Value | Evidence | Status`.
- **Repository map**: a tree of the non-vendored files, each with its class and a one-line purpose.
- **How to run**: every script or task, with `Command | What it does | Prerequisites`.
- **Knowledge base index**: a link to every KB file with one line each. `onboarding.md` goes first.
- **Generation metadata**:
  - date and commit, which must match the frontmatter
  - files read, partial and total, with a link to `_inventory.md`
  - skipped folders
  - scope, and whether the whole repository was visible
  - mode
  - the tool or model used, if known
  - assumptions

## `onboarding.md`

Follow `onboarding-template.md`.

## `architecture.md`

- **Components**: `ID | Component | Path | Responsibility | Depends on | Used by`.
- **Architecture diagram**: a Mermaid `flowchart` from callers, to the project's components, to
  external systems.
- **Key design decisions** seen in the code, with evidence. Examples: creating a client per call,
  hard-coded configuration, sync vs async.
- **Details**: one `### <PREFIX>-C#` per component, with links to its flows and dependencies.

## `data-flows.md`

- **Ingress**: `ID | Entry point | Type | Caller / source | Validation | Location | Status`.
- **Egress**: `ID | Destination | Operation / protocol | Auth | Error handling | Location | Status`.
- **Flows**: `ID | Name | Ingress | Egress | Steps`, where Steps is the count.
- **Details**: one `### <ID>` for each ingress, egress and flow. It gives:
  - **Ingress:** the input shape (fields used vs documented) and the caller.
  - **Egress:** the data sent (flag any sensitive data that is *logged*), the data received,
    sync/async, timeouts and retries, and every error path, including ignored partial failures.
  - **Flow:** a numbered step list with `path:line` on each step, plus a Mermaid diagram.
- **Data classification**: `Field | Could be sensitive? | Where it ends up (including logs) | Evidence`.

## `environment.md`

- **Environment variables**: `Name | Kind (explicit/implicit) | Read at | Default | Required | Secret | Status`.
- **Details**: one `### <VAR_NAME>` per variable, giving read by (component link), used after being
  read?, overridden by, and purpose.
- **Env files**: `File | Present | Git-ignored | Loaded by | Notes`. Names only, never values.
- **External runtime inputs**: credential files, metadata endpoints, mounted secrets.
- **Minimum environment to run**, as bullets for local, test and production.

## `configuration.md`

- For each config file, a `### <path>` heading with:
  - **Purpose**
  - **Key settings**: `Setting | Value | Effect`
  - **What it actually matches or affects** (for globs, the real list of files)
  - **Issues**, linking to findings
- **Hard-coded configuration in code**: `Value | Location | Effect | Should it be configurable?`.
  Non-secret values only.

## `dependencies.md`

- **Runtime** and **Development** tables: `Package | Declared | Resolved | Purpose | Imported at | Notes`.
- **Runtime and toolchain requirements**: language version, package manager, lockfile version.
- **Unused or undeclared dependencies.**

## `security.md`

- **Required permissions**: `Principal | Permission / action | Resource | Why | Evidence`.
- **Secrets and credentials**: sources, storage and exposure risks. Names only.
- **Sensitive data exposure**: logs, errors and telemetry, with `path:line`.
- **Input validation**: `Ingress | Validation | Injection surface | Evidence`.
- **Error handling and resilience gaps**, each linked to a finding.

## `testing.md`

- **Test setup**: the runner, assertion libraries, mocking approach and config file.
- **Test inventory**: `File | Matched by runner? | Suites | Tests | What it covers`.
- **Behaviour coverage**: `Path (I/E/F link) | Tested? | By which test | Gap`.
- **How to run**, and what it needs. For example: "no cloud credentials, because the client is
  mocked".

## `findings.md`

- **Findings**, sorted by severity (High, Medium, Low, Info):
  `ID | Severity | Category | Finding | Evidence | Suggested action`.
  - Categories: `Bug`, `Test gap`, `Config drift`, `Stale docs`, `Security`, `Dead code`,
    `Hygiene`, `Resilience`.
  - The Finding cell links to the related IDs, for example
    `... ignored in [LAMBDA-E1](data-flows.md#lambda-e1)`.
- **Open questions**, `### <PREFIX>-Q#` each: ambiguous intent, "whichever it is" comments, missing
  context.
- **Suggested next steps**, ordered and short, linking to the findings.

## `_inventory.md`

- `File | Class | Lines | Read (yes/partial/no) | Notes`, plus the totals.
- Frontmatter `kb_type: inventory`.
