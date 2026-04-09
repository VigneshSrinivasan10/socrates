# AI Tutor

An AI tutor for subjects where you actually need to *think* — not just read. Math, physics, systems design, formal logic, proof-based courses, or anything where passive consumption doesn't work.

Chatbots give you answers. This doesn't. It asks questions, waits for you to struggle, tracks what you've mastered and what's still shaky, and won't let you move on until you've demonstrated understanding. It maintains a structured knowledge wiki from your source material and a persistent model of you as a learner — your mastery levels, recurring mistakes, and learning patterns — so it picks up exactly where you left off across sessions.

Built on the [LLM-wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) with configurable tutor personas (Socratic, Feynman-style, coaching, rigorous, collaborative).

### When to use this

- You're learning something where understanding builds on itself (prerequisites matter)
- You need to develop intuition, not just memorize facts
- You've tried reading tutorials and watching videos but it doesn't stick
- You want a tutor that adapts to *your* gaps, not a fixed curriculum

### When NOT to use this

- You need a quick answer to a specific question (just ask Claude directly)
- The topic is purely factual with no conceptual depth (use a wiki or chatbot)
- You want passive content consumption (use a course platform)

 
## Getting started

### Prerequisites

- [Claude Code](https://claude.ai/claude-code) CLI

### 1. Clone and start

```bash
git clone <repo-url>
cd ai-tutor
```

The `/tutor` command is available automatically via `.claude/commands/tutor.md` — no manual setup needed.

### 2. Choose a persona (optional)

The default persona is Socratic. To switch:

```bash
cd tutor
ln -sf personas/coach.md persona.md   # or feynman, strict, study-buddy
```

### 3. Start learning

> `/tutor`

The tutor asks what you want to learn. Then it:

1. **Assesses your level** — a short conversation (3-5 questions) to gauge where you are
2. **Asks for sources** — you can paste URLs to learn from, or let the tutor find material for you (or both)
3. **Searches for material** (if needed) — spawns parallel agents to find tutorials, papers, and courses matched to your level
4. **Ingests into the knowledge wiki** — parallel agents process each source into `tutor/knowledge/` (concepts, lessons, mistakes, cross-references)
5. **Builds a curriculum** — orders lessons by difficulty, starting at your level
6. **Starts teaching** — begins the first lesson using the active persona's style

If you're returning, the tutor reads your history and asks if you want to continue or learn something new.

### Adding your own sources (optional)

You can also manually add material to `tutor/sources/` and ask the tutor to ingest it:
- `tutor/sources/urls.md` — links to online tutorials, courses, documentation
- `tutor/sources/notebooks/` — Jupyter notebooks
- `tutor/sources/textbooks/` — textbook excerpts, chapter notes
- `tutor/sources/papers/` — relevant papers

## Sessions

A session is a single conversation with the tutor agent. The tutor uses `student/` to maintain continuity across sessions.

### Starting a session

Run `/tutor`. The tutor will:

1. Read `tutor/persona.md` for its teaching style
2. Read `student/index.md` for your current status
3. Read your most recent session log in `student/sessions/`
4. Read relevant mastery and pattern pages
5. Ask: *"Want to pick up where we left off, or learn something new?"*

If you're brand new, it asks what you want to learn and runs the full assess → search → ingest → teach flow.

### During a session

The tutor follows a loop: **engage → wait → evaluate → respond**, shaped by the active persona. It tracks your phase within each lesson and only advances when you demonstrate understanding — not when you ask to skip ahead.

You can:
- Answer with text explanations, math, pseudocode, or code
- Say "I'm stuck" to get a hint
- Say "let's experiment" to jump to trying things once your understanding is solid
- Ask "why?" about anything

### Ending a session

Say goodbye, or just stop. The tutor will:

1. Write a session page to `student/sessions/YYYY-MM-DD.md`
2. Update `student/index.md` with where you are and what to do next
3. Update mastery pages for any concepts whose status changed
4. Log any new learning patterns it noticed

If you close Claude without saying goodbye, a **Stop hook** captures your last teaching state to `.tutor-state`. Next time you run `/tutor`, the tutor detects the stale session, recovers the state, writes a session entry, and picks up where you left off — so your progress is never lost.

### Continuing next time

Start a new conversation. The tutor reads the wiki and picks up exactly where you left off. You don't need to re-explain anything. You can also switch personas between sessions — the student state carries over regardless of teaching style.

## How it works

### The LLM-wiki pattern

AI Tutor uses **LLM-wiki** — a pattern where an LLM maintains structured markdown wikis as its persistent memory. Instead of relying on conversation context (which resets each session), the agent reads and writes markdown files with defined schemas. This gives it durable, queryable knowledge that survives across conversations.

The project is organized around two actors:

- **`tutor/`** — the teaching side. Contains `knowledge/` (an LLM-wiki of concepts, lessons, mistakes, and cross-references), `sources/` (immutable reference material), and `personas/` (teaching style definitions). The knowledge wiki is domain-agnostic — it structures any subject into teachable units. Each page follows a strict schema (defined in `tutor/SCHEMA.md`) so the agent can reliably find and update information.

- **`student/`** — the learner side. A state machine that tracks where you are: current lesson and phase, mastery level per concept, session logs, learning style observations, and recurring patterns. This is what lets the tutor pick up exactly where you left off, adapt its pacing, and avoid re-explaining things you've already mastered. See `student/SCHEMA.md` for page formats.

### Tutor personas

The tutor's teaching style is defined by a **persona** — a markdown file that specifies identity, tone, method rules, and example exchanges. The active persona is `tutor/persona.md` (a symlink to one of the files in `tutor/personas/`).

To switch personas:

```bash
cd tutor
ln -sf personas/feynman.md persona.md
```

#### Built-in personas

| Persona | Style | Good for |
|---------|-------|----------|
| **`socratic`** (default) | Question-driven. Asks, doesn't tell. Lets you struggle productively. | Deep understanding, building reasoning skills |
| **`feynman`** | Analogy-driven. Strips jargon, builds intuition from everyday experience. Enthusiastic and informal. | Making complex topics feel simple, building intuition |
| **`coach`** | Project-driven. Gets you building immediately, fills in theory as gaps appear. Direct and practical. | Learning by doing, practical skills, fast momentum |
| **`strict`** | Rigorous and formal. Demands precision, no partial credit, requires you to show your work. | Mathematical rigor, exam prep, developing precision |
| **`study-buddy`** | Collaborative. Thinks out loud, explores together, no hierarchy. Casual and equal. | Low-pressure learning, exploring new topics, building confidence |

#### Custom personas

Create your own persona in `tutor/personas/`:

```markdown
---
persona: my-style
name: My Custom Tutor
style: <brief description>
tone: <adjectives>
---

## Identity
<Who you are and how you teach>

## Method Rules
1. <Rule 1>
2. <Rule 2>
...

## Example exchanges
- <Scenario → how you'd respond>
```

Then symlink it: `ln -sf personas/my-style.md tutor/persona.md`

### From sources to lessons

When you provide learning material (URLs, papers, notebooks) or let the tutor search for it, an **ingest workflow** transforms raw content into structured knowledge:

1. **Read** the source completely
2. **Extract** concepts, techniques, common mistakes, and cross-references
3. **Create wiki pages** — one page per concept (`tutor/knowledge/concepts/`), one per lesson (`tutor/knowledge/lessons/`), one per mistake pattern (`tutor/knowledge/mistakes/`), and synthesis pages for non-obvious connections (`tutor/knowledge/connections/`)
4. **Map the curriculum** — a `tutor/knowledge/curricula/` page orders the lessons by difficulty, maps prerequisites, and records what the source covers and where it has gaps
5. **Index** everything in `tutor/knowledge/index.md`

Each page type has a specific schema. For example, a lesson page includes a teaching strategy, phase transition criteria (what the student must demonstrate to advance), tricky spots, and verification criteria. A concept page includes prerequisite links, common misunderstandings, and questions for each learning phase. This structure means the tutor doesn't improvise — it has a deliberate

## Project structure

```
.claude/
  commands/tutor.md        # /tutor slash command
  hooks/                      # Stop hook for session checkpoints
  settings.json               # Hook configuration

tutor/                      # Teaching side
  SCHEMA.md                   # Knowledge wiki page formats and workflows
  persona.md                  # Active persona (symlink)
  personas/                   # Teaching style definitions
    socratic.md               # Question-driven (default)
    feynman.md                # Analogy-driven, informal
    coach.md                  # Project-driven, hands-on
    strict.md                 # Rigorous, formal
    study-buddy.md            # Collaborative, equal
  knowledge/                  # LLM-wiki — agent maintained (gitignored)
    index.md                  # Master catalog
    log.md                    # Ingest/lint history
    curricula/                # One page per tutorial curriculum
    concepts/                 # One page per teachable concept
    lessons/                  # One page per lesson — teaching strategy
    mistakes/                 # Common mistake patterns
    connections/              # Cross-cutting synthesis
  sources/                    # Immutable — human curated (gitignored)
    notebooks/                # Tutorial notebooks
    textbooks/                # Excerpts, chapter notes
    papers/                   # Relevant papers
    urls.md                   # Index of online sources

student/                      # Learner side — state machine (gitignored)
  SCHEMA.md                   # Student page formats and workflows
  index.md                    # Current status snapshot (template committed)
  log.md                      # Session history
  profile.md                  # Learning style and strengths
  mastery/                    # One page per encountered concept
  sessions/                   # One page per session
  patterns/                   # Recurring observations

AGENTS.md                     # Universal tutor rules and persona loading
```
