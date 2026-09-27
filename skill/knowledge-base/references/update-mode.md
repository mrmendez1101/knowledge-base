# Update mode

Use this mode to refresh an existing KB instead of regenerating it. It keeps IDs stable, so links
from Obsidian notes, issues and PRs keep working.

1. **Load the baseline.** Read `<output>/README.md` frontmatter for `commit` and `generated`.
   - If the folder or README is missing, or `commit` is `none`, tell the user and run a `full`
     generation instead.
2. **Find what changed.**
   - With git, run `git diff --name-only <commit>..HEAD` and `git status --porcelain`, which also
     covers uncommitted changes.
   - Without git, compare file modification times against `generated`, and say that this is
     approximate.
3. **Find the affected rows.** Search every KB file for citations of the changed paths. Also treat
   these as changed:
   - Any new file: classify it and inventory it.
   - Any deleted file: every row that cites it must be removed or re-verified.
   - Any change to a manifest, lockfile, env file, config or IaC: re-run that category of Phase 2
     in full, because these have wide effects.
4. **Re-verify, don't rewrite.**
   - Re-read the changed files in full and re-run the Phase 2 searches on them.
   - Update the affected rows, citations and diagrams.
   - Keep existing IDs. Give new entities the next free number.
   - Never delete or rename a removed entity's `### <ID>` heading, because that would break
     inbound links. Leave the heading as it is and put `**Status:** removed in <short sha>` on the
     next line. Findings are the exception: they move, heading and all, to a **Resolved** section
     at the end of `findings.md`.
5. **Re-check findings.** For each open finding whose evidence changed, confirm it still holds.
   Move fixed ones to **Resolved** with the commit that fixed them.
6. **Refresh the metadata.**
   - Update the frontmatter `commit` and `generated` in **every** KB file, including files with
     no changes. The values must match everywhere.
   - Add a **Change log** entry to `README.md` with the date, commit range, files re-verified,
     entities added, changed or removed, and findings opened or resolved.
7. **Run the verification checklist** in `verification.md`, limited to the touched files, plus the
   global secret scan and link check.
8. **Final reply:**
   - the commit range
   - the files re-verified
   - the IDs added, changed or removed
   - the findings opened or resolved
   - anything now Unknown
