# Frontmatter, IDs, links, vault mode and graphify

These rules apply on **every** run. They keep the KB readable on GitHub and in Copilot, and they
turn it into a connected graph in Obsidian and graphify.

## 1. Frontmatter (every KB file)

```yaml
---
title: Environment                # human title of this file
kb_type: environment              # readme|onboarding|architecture|data-flows|environment|configuration|dependencies|security|testing|findings|inventory|entity
project: lambda-playground        # repo slug, lower-case kebab
kb_id_prefix: LAMBDA              # the upper-case ID prefix
tags: [knowledge-base, lambda-playground, environment]
generated: 2026-09-28             # ISO date of this run
commit: 1a2b3c4                   # HEAD short SHA, or "none"
source_root: .                    # target root, relative to the repo
status: generated                 # generated | reviewed (humans set reviewed)
---
```

- Tags are lower-case kebab with no spaces. They follow the pattern `knowledge-base`, `<project>`,
  `<kb_type>`.
- `README.md` is the source of truth for `commit` and `generated`, and update mode reads them from
  there.

## 2. IDs

| Entity | ID pattern | Lives in |
|---|---|---|
| Component | `<PREFIX>-C1` | `architecture.md` |
| Ingress | `<PREFIX>-I1` | `data-flows.md` |
| Egress | `<PREFIX>-E1` | `data-flows.md` |
| Flow | `<PREFIX>-F1` | `data-flows.md` |
| Finding | `<PREFIX>-KB-01` | `findings.md` |
| Open question | `<PREFIX>-Q1` | `findings.md` |
| Env var | the variable name itself | `environment.md` |

- IDs are **stable**. In update mode, keep existing IDs and append new ones. Never renumber.
- Every ID gets a detail heading whose text is **only the ID**, for example `### LAMBDA-F1`. The
  human title goes on the next line as `**Title:** …`. This gives each ID a predictable anchor
  (`#lambda-f1`, and `#aws_region` for env vars).
- Give each env var its own heading. Never group several in one heading such as `### A / B`,
  because the resulting anchors (`#a--b`) are unpredictable.

## 3. Links

- Use **relative Markdown links**, not `[[wikilinks]]`: `[LAMBDA-F1](data-flows.md#lambda-f1)`.
  - GitHub, VS Code, Copilot and Obsidian all render them.
  - graphify turns them into `references` edges.
- **Every mention of an ID in another file is a link**, and so is every mention in the same file
  outside its own heading. Links are what make the graph; plain-text IDs are orphans. Required
  cross-links:
  - Each finding links to the flows, ingress, egress, env vars or config it concerns.
  - Each flow links to its ingress and egress IDs, and to the components involved.
  - Each component links to its flows and to the dependencies it imports.
  - Each env var links to the components that read it.
  - Each test in `testing.md` links to the paths it covers.
  - `onboarding.md` links to every other KB file.
- Keep code citations as code spans: `` `src/app.js:12-30` ``. Do not turn them into links.
- Mermaid diagrams render in GitHub, VS Code and Obsidian. Follow the syntax rules in
  `verification.md`.

## 4. Vault mode (`vault` argument)

In addition to the normal files, write one short note per entity:

```
<output>/entities/components/LAMBDA-C1.md
<output>/entities/ingress/LAMBDA-I1.md
<output>/entities/egress/LAMBDA-E1.md
<output>/entities/flows/LAMBDA-F1.md
<output>/entities/env/AWS_REGION.md
<output>/entities/deps/<package-name>.md     (replace "/" and "@" with "-")
<output>/entities/findings/LAMBDA-KB-01.md
```

Each entity note contains:

- **Frontmatter:** `kb_type: entity`, `entity: component|ingress|egress|flow|env|dep|finding`,
  `id`, `aliases: [<ID>, <human title>]`, `evidence_status: Verified|Inferred|Unknown`. Findings
  also get `severity`, `severity_rank` (1 = High, 2 = Medium, 3 = Low, 4 = Info) and `category`.
- **Body:** a one-paragraph summary, the `path:line` evidence, and a **Related** list linking to
  other entity notes (`../flows/LAMBDA-F1.md`). The last line is
  `Defined in: [data-flows.md](../../data-flows.md#lambda-f1)`.

File-per-entity links resolve the same way in every tool, so vault mode gives the richest graph.
Tables stay the default because they are easier to read on GitHub and in Copilot.

## 5. Using the KB with Obsidian

- **Per repo:** open the repository, or `docs/knowledge-base/`, as a vault.
- **One team vault:** copy or symlink each project's `docs/knowledge-base/` to
  `<vault>/projects/<project>/`. The ID prefixes keep projects apart.
- **Example Dataview query** (vault mode):

  ````
  ```dataview
  TABLE severity, category, project FROM #knowledge-base
  WHERE entity = "finding" SORT severity_rank ASC
  ```
  ````

## 6. graphify

graphify builds a structural code graph locally from the AST. This KB adds the evidence layer that
graphify does not have: env vars, egress, security, findings and onboarding. Use them together.

- **Before generation (optional accelerator):** if `graphify-out/GRAPH_REPORT.md` exists, read it
  in Phase 1 to find candidate components and call paths. Never cite it as evidence; cite the
  source lines.
- **After generation**, suggest these commands to the user:
  - `/graphify . --update`, to fold the new KB docs into the project graph.
  - `/graphify . --obsidian`, to export an Obsidian vault with code and KB nodes linked.
  - `/graphify query "which findings touch <component>?"`
- **Privacy:** graphify's document pass sends Markdown to an LLM backend. That is why the secret
  scan in `verification.md` is mandatory. Recommend a `.graphifyignore` containing `.env*` and
  any credential files.
