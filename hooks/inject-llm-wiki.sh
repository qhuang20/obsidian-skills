#!/usr/bin/env bash
# SessionStart(startup) hook for obsidian-skills plugin.
# If the session's project directory is inside an Obsidian vault
# (any ancestor contains a .obsidian/ directory), emit a JSON
# additionalContext payload telling Claude to load the llm-wiki skill.
# Otherwise exit silently.

set -eu

start_dir="${CLAUDE_PROJECT_DIR:-$PWD}"

# Walk upward looking for .obsidian/
dir="$start_dir"
vault_root=""
while [ "$dir" != "/" ] && [ -n "$dir" ]; do
  if [ -d "$dir/.obsidian" ]; then
    vault_root="$dir"
    break
  fi
  dir="$(dirname "$dir")"
done

if [ -z "$vault_root" ]; then
  exit 0
fi

# Escape the vault root for JSON embedding (handle backslashes and quotes).
escaped_vault=$(printf '%s' "$vault_root" | sed 's/\\/\\\\/g; s/"/\\"/g')

cat <<JSON
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"You are starting a session inside an Obsidian vault (${escaped_vault}). Load the obsidian-skills:llm-wiki skill now and use its pattern as the collaboration mode for this session. Co-evolve the specifics with the user; do not impose structure they have not asked for."}}
JSON

exit 0
