# Socrates

An AI agent that teaches through the Socratic method — asking questions, not giving answers. Built on the [llm-wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f), it can ingest any source material and turn it into a structured teaching curriculum.

## How it works

The tutor maintains two wikis:

- **`knowledge/`** — the teaching brain. Concepts, lessons, common mistakes, and cross-references compiled from source material.
- **`student/`** — your learning history. Mastery levels, session logs, observed patterns. Persists across sessions so the tutor remembers where you left off.

Source material lives in `sources/` and is never modified by the agent.

## Getting started

### 0. Set up the `/socrates` command

Copy `socrates.md` into your Claude Code commands directory so you can launch the tutor with `/socrates`:

```bash
mkdir -p ~/.claude/commands
cp socrates.md ~/.claude/commands/socrates.md
```

### 1. Add source material

Drop your learning material into the appropriate folder:
- `sources/urls.md` — links to online tutorials, courses, documentation
- `sources/notebooks/` — Jupyter notebooks
- `sources/textbooks/` — textbook excerpts, chapter notes
- `sources/papers/` — relevant papers

### 2. Ingest into the knowledge wiki

Ask the tutor to ingest a source:

> "Ingest the Python tutorial into the knowledge wiki."

This populates `knowledge/` with lesson pages, concept pages, mistake patterns, and cross-references.

### 3. Start learning

> "I want to start learning."

The tutor checks `student/index.md`, sees you're new, and walks you through picking a curriculum and beginning the first lesson.

## Sessions

A session is a single conversation with the tutor agent. The tutor uses the `student/` wiki to maintain continuity across sessions.

### Starting a session

Just start talking to the agent. It will:

1. Read `student/index.md` for your current status
2. Read your most recent session log in `student/sessions/`
3. Read relevant mastery and pattern pages
4. Greet you with a recap: *"Last time we were working on X. You had just Y. Ready to pick up?"*

If you're brand new, it skips the recap and starts from the beginning.

### During a session

The tutor follows a loop: **ask → wait → evaluate → respond**. It tracks your phase within each lesson and only advances when you demonstrate understanding — not when you ask to skip ahead.

You can:
- Answer with text explanations, math, pseudocode, or code
- Say "I'm stuck" to get a hint (max 2 hints before it explains)
- Say "let's experiment" to jump to trying things once your understanding is solid
- Ask "why?" about anything — the tutor loves that

### Ending a session

Say goodbye, or just stop. The tutor will:

1. Write a session page to `student/sessions/YYYY-MM-DD.md`
2. Update `student/index.md` with where you are and what to do next
3. Update mastery pages for any concepts whose status changed
4. Log any new learning patterns it noticed

### Continuing next time

Start a new conversation. The tutor reads the wiki and picks up exactly where you left off. You don't need to re-explain anything.

## Project structure

```
sources/                  # Immutable — human curated
  notebooks/              # Tutorial notebooks
  textbooks/              # Excerpts, chapter notes
  papers/                 # Relevant papers
  urls.md                 # Index of online sources

knowledge/                # Teaching brain — agent maintained
  index.md                # Master catalog
  log.md                  # Ingest/lint history
  curricula/              # One page per tutorial curriculum
  concepts/               # One page per teachable concept
  lessons/                # One page per lesson — teaching strategy
  mistakes/               # Common mistake patterns
  connections/            # Cross-cutting synthesis

student/                  # Student memory — agent maintained
  index.md                # Current status snapshot
  log.md                  # Session history
  profile.md              # Learning style and strengths
  mastery/                # One page per encountered concept
  sessions/               # One page per session
  patterns/               # Recurring observations

AGENTS.md                 # Wiki schema — governs agent behavior
plan.md                   # Project plan and roadmap
```
