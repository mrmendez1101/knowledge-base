#!/usr/bin/env sh
# Installs the knowledge-base skill into a target repository.
#   <target>/.claude/skills/knowledge-base         read by Claude Code, GitHub Copilot and Kimi CLI
#   <target>/.github/prompts/knowledge-base.prompt.md   adds /knowledge-base to Copilot Chat in VS Code
#
# Usage: scripts/install.sh [--agents] [--no-copilot] [--force] <target>
#        scripts/install.sh --user [--agents] [--force]
#   --user        install into $HOME/.claude/skills instead of a repository (no Copilot prompt)
#   --agents      also copy to .agents/skills (generic Agent Skills folder)
#   --no-copilot  skip the .github/prompts wrapper
#   --force       replace an existing installation
set -eu

agents=0; copilot=1; force=0; user=0; target=""
for arg in "$@"; do
  case "$arg" in
    --user) user=1 ;;
    --agents) agents=1 ;;
    --no-copilot) copilot=0 ;;
    --force) force=1 ;;
    -*) echo "Unknown option: $arg" >&2; exit 2 ;;
    *) target="$arg" ;;
  esac
done
if [ "$user" -eq 1 ]; then
  [ -z "$target" ] || { echo "Use either <target> or --user, not both." >&2; exit 2; }
  target="$HOME"; copilot=0
fi
[ -n "$target" ] || { echo "Usage: $0 [--agents] [--no-copilot] [--force] <target> | --user" >&2; exit 2; }
[ -d "$target" ] || { echo "Target folder not found: $target" >&2; exit 1; }

repo_root=$(cd "$(dirname "$0")/.." && pwd)
skill_src="$repo_root/skill/knowledge-base"
prompt_src="$repo_root/adapters/copilot/knowledge-base.prompt.md"

copy_skill() {
  dest="$1/knowledge-base"
  if [ -e "$dest" ]; then
    [ "$force" -eq 1 ] || { echo "$dest already exists. Re-run with --force to replace it." >&2; exit 1; }
    rm -rf "$dest"
  fi
  mkdir -p "$1"
  cp -R "$skill_src" "$dest"
  echo "Installed skill  -> $dest"
}

copy_skill "$target/.claude/skills"
[ "$agents" -eq 0 ] || copy_skill "$target/.agents/skills"

if [ "$copilot" -eq 1 ]; then
  prompt_dest="$target/.github/prompts/knowledge-base.prompt.md"
  if [ -e "$prompt_dest" ] && [ "$force" -eq 0 ]; then
    echo "$prompt_dest already exists. Re-run with --force to replace it." >&2; exit 1
  fi
  mkdir -p "$target/.github/prompts"
  cp "$prompt_src" "$prompt_dest"
  echo "Installed prompt -> $prompt_dest"
fi

if [ -e "$target/.claude/commands/knowledge-base.md" ]; then
  echo "WARNING: $target/.claude/commands/knowledge-base.md also defines /knowledge-base in Claude Code. Remove it so the skill is used." >&2
fi

echo
echo "Done. Invoke with: Claude Code /knowledge-base | Copilot Chat (Agent mode) /knowledge-base | Kimi CLI /skill:knowledge-base"
