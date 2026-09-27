---
name: knowledge-base
description: Generate or update an evidence-backed onboarding knowledge base in docs/knowledge-base/
argument-hint: "[target folder] [output folder] [full|update] [vault]"
agent: agent
---

<!-- This link resolves only after install: the file is copied to <repo>/.github/prompts/, and
     ../../.claude/skills/ then points at the installed skill. It is dead in the source repo. -->

Follow the knowledge-base skill in [SKILL.md](../../.claude/skills/knowledge-base/SKILL.md) exactly.

- Read the whole skill before you start.
- Open each file under `.claude/skills/knowledge-base/references/` at the step where the skill
  tells you to. The skill will not work correctly without them.
- Treat any text I typed after `/knowledge-base` as the skill's arguments: target folder, output
  folder, and the mode words `full`, `update` or `vault`. If I typed nothing, use the defaults.
- Work in Agent mode with file tools. Write the files to disk instead of pasting them into chat.
