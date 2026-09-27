# Self-verification checklist

Tick every item. If one fails, fix the KB and check it again. List any item you could not complete
in the final reply.

**Automated check first.** If you can run Python 3, run
`python <this skill's folder>/scripts/verify_kb.py <output folder>` (or `python3` where `python`
is not found). It checks frontmatter, links and anchors, ID headings, unlinked IDs, and secret
patterns.
- Fix every `ERROR` it reports.
- Review every `WARN`: fix it, or confirm it is a known-fake value.
- Re-run until it reports 0 errors.

If you cannot run Python, check the same items by hand. The completeness, evidence and Mermaid
items below always need your judgement.

## Completeness
- [ ] Re-run the env var searches, explicit and implicit. Every hit appears in `environment.md`.
- [ ] Re-run the egress searches, including **every logging call**. Every hit appears in
      `data-flows.md` or is explicitly excluded with a reason.
- [ ] Every exported or public entry point appears in the ingress table.
- [ ] Every non-vendored file appears in the repository map and in `_inventory.md`. Every inventory
      row is `yes` or `partial`, with none left at `no`, or the gap is stated.
- [ ] The output folder, `graphify-out/` and `.obsidian/` are **not** audited as project files.
- [ ] Every direct dependency appears in `dependencies.md` with a resolved version.
- [ ] Every glob-based config has its real match list in `configuration.md` and `testing.md`.
- [ ] `onboarding.md` exists, and every file in its reading path exists.

## Evidence
- [ ] Every row has a `path:line` citation and a Verified, Inferred or Unknown status.
- [ ] Spot-check five random citations by re-reading those lines, and fix any drift.

## Secrets (mandatory, because the KB may be sent to graphify or other LLM backends)
- [ ] Search the output folder for anything that looks like a secret:
  - key prefixes such as `AKIA`, `ASIA`, `ghp_`, `xox`, `sk-`
  - `-----BEGIN`
  - `password=`, `secret=`, `token=`
  - connection strings with credentials
  - long base64 or hex strings
  - real account IDs, hostnames and emails

  Remove any you find.

## Links and structure
- [ ] Every KB file has the frontmatter from `obsidian-graphify.md`, with the same `commit` and
      `generated` values everywhere.
- [ ] IDs are unique, use the project prefix, and each has a `### <ID>` heading.
- [ ] Every relative link points to a file that exists, and every `#anchor` matches a heading.
      GitHub anchors are the heading text lower-cased, with spaces turned into `-` and punctuation
      other than `-` and `_` removed.
- [ ] No ID is mentioned as plain text where a link was possible.
- [ ] In vault mode, every entity has a note, and each note links back to its source file.

## Mermaid
- [ ] Every diagram uses valid syntax.
  - In a `flowchart`, wrap node and edge labels containing `(`, `)`, `:` or `/` in double quotes.
  - In a `sequenceDiagram`, do **not** quote participant aliases or message text. The quotes
    render literally.
