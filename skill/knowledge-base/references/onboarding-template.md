# `onboarding.md` template

This is the newcomer's entry point. Write it for someone who joined the team today. Findings are
for maintainers; this file is for orientation.

- It still follows the evidence rules: cite `path:line` and label each statement Verified,
  Inferred or Unknown.
- Keep it under about 150 lines. Link out to the other KB files instead of repeating them.

## Sections (use these headings)

### What this project is
Three sentences: what it does, who calls or uses it, and where it runs. Link to
`architecture.md`.

### Start here: 30-minute reading path
A numbered list of 5–10 files, in the order to read them. For each file, give one line on what to
look for.

- Start at the main entry point, then follow the most important flow.
- Link each step to the flow or component it belongs to, for example
  `[LAMBDA-F1](data-flows.md#lambda-f1)`.

### Run it locally
The minimum steps to install, configure, test and run.

- Link to `environment.md#minimum-environment-to-run` and the How to run section of `README.md`.
- Say plainly if something cannot be run locally, for example because it needs real cloud
  credentials.

### Glossary
`Term | Meaning | Where it appears`. Include:
- domain terms and acronyms
- project-specific names, such as config keys, event names and queue names
- the KB's ID prefixes (`-C`, `-I`, `-E`, `-F`, `-KB`, `-Q`)

### Conventions
Patterns observed in the code, with evidence. Cover:
- naming
- folder layout
- error handling
- logging
- configuration access
- test style and mocking
- commit or branch conventions, if visible

If a convention is inconsistent, say so and link the finding.

### How do I…
Recipes for the 3–5 most likely changes. Examples:
- add a handler or endpoint
- add an env var
- add a dependency
- add a test
- change an external call

Each recipe is a list of numbered steps. Each step names:
- the file(s) to touch
- the existing example to copy (`path:line`)
- the config or test to update, such as test globs or IaC env blocks

### Gotchas
The top findings a newcomer would trip over, such as tests that don't run, hard-coded values or
misleading docs. Link each one to `findings.md`.

### Who and what to ask
Link to the open questions (`<PREFIX>-Q#`). List ownership files if they exist (`CODEOWNERS`,
maintainers in the manifest). Never invent people.
