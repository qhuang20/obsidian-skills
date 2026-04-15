# obsidian-skills `llm-wiki` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the `obsidian-skills` Claude Code plugin with its first skill `llm-wiki`, which auto-injects Karpathy's LLM Wiki pattern whenever a session starts inside an Obsidian vault.

**Architecture:** A plugin at `~/Developer/_my/obsidian-skills/` containing (1) a `plugin.json` manifest, (2) a single skill `skills/llm-wiki/SKILL.md` whose body is a near-verbatim transcription of Karpathy's gist, and (3) a `SessionStart(startup)` hook that checks if the session's project directory is inside an Obsidian vault and, if so, emits `hookSpecificOutput.additionalContext` instructing Claude to load the skill.

**Tech Stack:** Claude Code plugin manifest (JSON), Markdown with YAML frontmatter, POSIX shell (bash).

**Reference spec:** `docs/specs/2026-04-15-llm-wiki-design.md` — the Karpathy gist text lives in Appendix A and should be copied verbatim into SKILL.md.

---

## File Structure

All paths relative to `~/Developer/_my/obsidian-skills/`:

- `.claude-plugin/plugin.json` — manifest (name, version, description, author)
- `skills/llm-wiki/SKILL.md` — skill file; frontmatter + short preamble + verbatim gist body
- `hooks/hooks.json` — wires `SessionStart(startup)` to the injection script
- `hooks/inject-llm-wiki.sh` — POSIX shell script: walks up from `$CLAUDE_PROJECT_DIR` looking for `.obsidian/`; emits JSON with `additionalContext` on match, silent exit otherwise
- `README.md` — install instructions + one-paragraph description + link to Karpathy gist

The repo already exists with one commit (the design spec). Work directly on `main` — this is a fresh repo, no worktree needed.

---

## Task 1: Plugin manifest

**Files:**
- Create: `.claude-plugin/plugin.json`

- [ ] **Step 1: Write the manifest**

Create `.claude-plugin/plugin.json`:

```json
{
  "name": "obsidian-skills",
  "description": "Obsidian-focused skills for Claude Code. First skill loads Karpathy's LLM Wiki pattern when a session starts inside a vault.",
  "version": "0.1.0",
  "author": {
    "name": "qhuang20"
  },
  "homepage": "https://github.com/qhuang20/obsidian-skills"
}
```

- [ ] **Step 2: Validate JSON**

Run: `python3 -m json.tool .claude-plugin/plugin.json`
Expected: pretty-printed JSON, exit 0.

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "Add plugin manifest"
```

---

## Task 2: `llm-wiki` skill file

**Files:**
- Create: `skills/llm-wiki/SKILL.md`
- Reference: `docs/specs/2026-04-15-llm-wiki-design.md` (Appendix A has the verbatim gist)

- [ ] **Step 1: Create the skill file**

Create `skills/llm-wiki/SKILL.md`. The body has three parts: frontmatter, a short preamble addressed to Claude, then the verbatim gist from the spec's Appendix A.

Frontmatter:

```yaml
---
name: llm-wiki
description: Use when the user is working inside an Obsidian or markdown vault and wants to ingest sources, query accumulated knowledge, or maintain a Karpathy-style LLM wiki. Loads the wiki pattern as a shared mental model.
---
```

Preamble (place right after frontmatter, before the gist body):

```markdown
> **To Claude reading this:** when this skill is loaded, treat the pattern below as the active collaboration mode for the current session. Co-evolve the specifics (directory layout, page conventions, tooling) with the user. Do not impose structure the user has not asked for. The text below is Andrej Karpathy's original gist, included nearly verbatim.

---
```

Then copy the gist body verbatim from `docs/specs/2026-04-15-llm-wiki-design.md` Appendix A (everything from `# LLM Wiki` through the final `## Note` paragraph ending in "Your LLM can figure out the rest."). Do not paraphrase, do not trim. Markdown heading levels are fine as-is.

- [ ] **Step 2: Verify the skill file has frontmatter + preamble + full gist**

Run:
```bash
head -5 skills/llm-wiki/SKILL.md
grep -c "^## " skills/llm-wiki/SKILL.md
grep -q "Memex" skills/llm-wiki/SKILL.md && echo "has memex"
grep -q "Your LLM can figure out the rest" skills/llm-wiki/SKILL.md && echo "has closing"
```

Expected:
- First line is `---` (frontmatter start)
- At least 7 `## ` headings (The core idea, Architecture, Operations, Indexing and logging, Optional: CLI tools, Tips and tricks, Why this works, Note)
- `has memex` printed
- `has closing` printed

- [ ] **Step 3: Commit**

```bash
git add skills/llm-wiki/SKILL.md
git commit -m "Add llm-wiki skill with verbatim Karpathy gist body"
```

---

## Task 3: Injection script

**Files:**
- Create: `hooks/inject-llm-wiki.sh`

- [ ] **Step 1: Write the script**

Create `hooks/inject-llm-wiki.sh`:

```bash
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
```

- [ ] **Step 2: Make it executable**

Run: `chmod +x hooks/inject-llm-wiki.sh`

- [ ] **Step 3: Test — inside a vault**

Run:
```bash
CLAUDE_PROJECT_DIR="$HOME/Sync-DLX" ./hooks/inject-llm-wiki.sh
```

Expected: a single line of JSON on stdout starting with `{"hookSpecificOutput"` and containing `Sync-DLX` and `obsidian-skills:llm-wiki`. Exit code 0.

Validate the JSON:
```bash
CLAUDE_PROJECT_DIR="$HOME/Sync-DLX" ./hooks/inject-llm-wiki.sh | python3 -m json.tool
```
Expected: pretty-printed JSON, exit 0.

- [ ] **Step 4: Test — outside any vault**

Run:
```bash
CLAUDE_PROJECT_DIR="/tmp" ./hooks/inject-llm-wiki.sh; echo "exit=$?"
```

Expected: no stdout output, `exit=0`.

- [ ] **Step 5: Test — nested inside a vault**

Run:
```bash
mkdir -p /tmp/obsidian-hook-test/.obsidian /tmp/obsidian-hook-test/sub/deep
CLAUDE_PROJECT_DIR=/tmp/obsidian-hook-test/sub/deep ./hooks/inject-llm-wiki.sh
```

Expected: JSON output containing `/tmp/obsidian-hook-test` as the detected vault root.

Cleanup: `rm -rf /tmp/obsidian-hook-test`

- [ ] **Step 6: Commit**

```bash
git add hooks/inject-llm-wiki.sh
git commit -m "Add SessionStart injection script for Obsidian vault detection"
```

---

## Task 4: Hook wiring

**Files:**
- Create: `hooks/hooks.json`

- [ ] **Step 1: Write the hook config**

Create `hooks/hooks.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}\"/hooks/inject-llm-wiki.sh"
          }
        ]
      }
    ]
  }
}
```

Note: only `startup` is matched — not `resume`, `clear`, or `compact`. That keeps the injection to once per fresh session.

- [ ] **Step 2: Validate JSON**

Run: `python3 -m json.tool hooks/hooks.json`
Expected: pretty-printed JSON, exit 0.

- [ ] **Step 3: Commit**

```bash
git add hooks/hooks.json
git commit -m "Wire SessionStart(startup) hook"
```

---

## Task 5: README

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write the README**

Create `README.md`:

```markdown
# obsidian-skills

A Claude Code plugin with Obsidian-focused skills.

## Skills

### `llm-wiki`

Loads Andrej Karpathy's [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) as a shared mental model whenever a Claude Code session starts inside an Obsidian vault (any directory with a `.obsidian/` subdirectory, searched upward from the session's project directory).

The skill does not define subcommands or enforced layouts. It is a pure guide: when it is loaded, Claude treats the pattern — raw sources / wiki / schema, plus the `ingest` / `query` / `lint` operations — as the active collaboration mode, and co-evolves the specifics with you.

## Install (local development)

```bash
claude --plugin-dir ~/Developer/_my/obsidian-skills
```

After making edits, run `/reload-plugins` inside Claude Code to pick up changes.

## Roadmap

More Obsidian-related skills will be added alongside `llm-wiki` (daily notes, link management, publishing, etc.).
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "Add README"
```

---

## Task 6: End-to-end verification

No code changes in this task — just running the plugin against real sessions and checking behavior.

- [ ] **Step 1: Smoke test — launch plugin inside a vault**

Run in a new terminal (separate from the current Claude Code session):
```bash
cd ~/Sync-DLX
claude --plugin-dir ~/Developer/_my/obsidian-skills
```

Inside that session, ask Claude: `Are you currently loaded with the llm-wiki skill? What vault did you detect?`

Expected: Claude acknowledges it was told to load `obsidian-skills:llm-wiki`, identifies `~/Sync-DLX` as the vault, and can describe the Karpathy pattern (ingest / query / lint, index.md / log.md).

- [ ] **Step 2: Smoke test — launch plugin outside a vault**

Run in a new terminal:
```bash
cd /tmp
claude --plugin-dir ~/Developer/_my/obsidian-skills
```

Inside that session, ask: `Did the obsidian-skills plugin inject any context about an Obsidian vault?`

Expected: Claude reports no vault context was injected (the hook ran silently because `/tmp` has no `.obsidian/` ancestor).

- [ ] **Step 3: Verify skill is listed**

In either test session above, run `/help` and confirm `/obsidian-skills:llm-wiki` appears under the plugin namespace.

- [ ] **Step 4: If any smoke test fails**

Debug by running the hook directly (see Task 3 Steps 3–5) and by re-reading `docs/specs/2026-04-15-llm-wiki-design.md`. Common issues:
- Hook not executable → `chmod +x hooks/inject-llm-wiki.sh`
- Hook emits to stderr instead of stdout → SessionStart requires stdout JSON
- Matcher typo → must be exactly `startup`
- JSON payload malformed → validate with `python3 -m json.tool`

Once all three smoke tests pass, the plugin is working.

- [ ] **Step 5: Final commit (if any fixes landed)**

```bash
git status
# if fixes were made:
git add -A && git commit -m "Fix issues found in end-to-end verification"
```

- [ ] **Step 6: Tag the initial version**

```bash
git tag v0.1.0
git log --oneline
```

Expected: a clean linear history — spec commit, manifest, skill, script, hook config, README, (optional fixes), and `v0.1.0` tag on HEAD.

---

## Out of scope (deferred)

- Publishing to a GitHub remote under `qhuang20/obsidian-skills` and registering in a marketplace — do this after `v0.1.0` has been used for a few sessions and the wording has stabilized.
- Matching `SessionStart(resume)` in addition to `startup` — decide after real usage.
- Additional skills (`daily-notes`, `link-manager`, etc.) — each gets its own spec + plan.
