<p align="center">
  <img src="logo.svg" alt="obsidian-skills" width="128" height="128">
</p>

# obsidian-skills

A [Claude Code](https://claude.com/claude-code) plugin that turns Claude into a better collaborator inside your Obsidian vault.

## What it does

Whenever you start Claude Code in a directory that is inside an Obsidian vault (any folder with a `.obsidian/` subdirectory, searched upward from your working directory), this plugin automatically loads a shared working style so Claude acts like a disciplined note-taking partner instead of a generic assistant. Outside a vault, it does nothing — your other projects are unaffected.

No commands to remember, no configuration, no folder layout imposed on you.

## Skills

### `llm-wiki`

Loads Andrej Karpathy's [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) as a mental model for the session. The idea: instead of retrieving from raw documents every time you ask a question, Claude helps you build a **persistent, interlinked wiki** of markdown pages that compounds over time — summaries, entity pages, concept pages, an index, and a log of what's been added.

Three lightweight operations anchor the workflow:

- **Ingest** — drop a source (article, paper, podcast notes) into your vault and ask Claude to process it. It reads the source, writes a summary, updates related pages, flags contradictions, and keeps cross-references consistent.
- **Query** — ask questions against the accumulated wiki. Answers come with citations and can be filed back as new pages so your explorations compound.
- **Lint** — periodically ask Claude to health-check the wiki: contradictions, orphan pages, stale claims, missing connections.

The skill is a pure guide — it does **not** define slash commands, enforce a directory layout, or write to your vault on its own. Claude co-evolves the specifics (page formats, folders, tooling) with you based on your domain.

## Install

Inside a running Claude Code session:

```
/plugin marketplace add qhuang20/obsidian-skills
/plugin install obsidian-skills@obsidian-skills
```

That's it. Next time you start a session from inside any Obsidian vault, the `llm-wiki` working style loads automatically.

To verify it's working, start Claude Code from a vault folder and ask: *"Did the obsidian-skills plugin inject any context at session start?"*

## Uninstall

```
/plugin uninstall obsidian-skills@obsidian-skills
```

## Requirements

- [Claude Code](https://claude.com/claude-code)
- An Obsidian vault (or any folder with a `.obsidian/` subdirectory). Obsidian itself is optional — the plugin only looks for the marker directory.

## Roadmap

More Obsidian-related skills are planned (daily notes, link management, publishing workflows). Each will auto-activate in the same unobtrusive way: helpful in a vault, silent everywhere else.

## License

MIT
