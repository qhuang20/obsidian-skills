<p align="center">
  <img src="logo.svg" alt="obsidian-skills" width="128" height="128">
</p>

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
