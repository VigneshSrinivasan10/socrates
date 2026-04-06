# Socratic CFD Tutor — Project Plan

## One-liner

An AI agent that teaches CFD fundamentals through Barba's "12 Steps to Navier-Stokes" using the Socratic method — asking questions, not giving answers.

---

## Motivation

Most CFD tutorials are cookbooks: copy this code, get this plot, move on. Learners finish with working code but no intuition. The Socratic method flips this — the agent guides the student to *discover* discretization, stability, and flow physics themselves. The 12 Steps curriculum is ideal because it's pure Python, incremental, and each step introduces exactly one concept.

Secondary motivation: demonstrate that AI agents can *teach*, not just *answer*. Strong blog series potential.

---

## Scope

### In scope
- All 12 steps of Barba's curriculum as Socratic lessons
- Agent that reads/runs student code and responds with questions, hints, or follow-ups
- Student state tracking (concepts mastered, current phase, mistakes)
- Built-in reference solutions and analytical solutions for validation
- Automated plotting to compare student results vs. analytical/reference
- CFL/stability diagnostics computed from student code
- Blog-ready structure: one post per step

### Out of scope (for now)
- OpenFOAM integration (future Phase 2)
- 3D simulations
- Turbulence modeling
- Multi-user / classroom mode
- Grading or certification

---

## The 12 Steps — Concept Map

| Step | PDE | New Concept Introduced |
|------|-----|----------------------|
| 1 | 1D linear convection | Discretization, forward difference, CFL |
| 2 | 1D nonlinear convection | Nonlinearity, wave steepening, shock formation |
| 3 | 1D diffusion | Second derivatives, central difference, smoothing |
| 4 | 1D Burgers' equation | Convection-diffusion competition, viscosity |
| 5 | 2D linear convection | Extending to 2D, array indexing, nested loops |
| 6 | 2D nonlinear convection | 2D nonlinearity |
| 7 | 2D diffusion | 2D Laplacian, explicit time stepping |
| 8 | 2D Burgers' equation | Full 2D convection-diffusion |
| 9 | 2D Laplace equation | Elliptic PDE, iterative solving, convergence |
| 10 | 2D Poisson equation | Source terms, pressure-like equation |
| 11 | Cavity flow (Navier-Stokes) | Pressure-velocity coupling, projection method |
| 12 | Channel flow | Boundary conditions, pressure gradient driving |

---

## Agent Architecture

### Core Loop

```
┌─────────────────────────────────────┐
│           SOCRATIC LOOP             │
│                                     │
│  ASK → WAIT → EVALUATE → RESPOND   │
│   │                         │       │
│   │    ┌──────────────┐     │       │
│   └────│ Student State │─────┘       │
│        └──────────────┘             │
└─────────────────────────────────────┘
```

1. **ASK** — Pose a question calibrated to current phase and mastery level
2. **WAIT** — Student responds (text explanation, code, or "I'm stuck")
3. **EVALUATE** — Agent reads response, optionally runs code, checks correctness
4. **RESPOND** — One of:
   - Correct → affirm + ask "why does this work?" or advance to next concept
   - Partially correct → acknowledge what's right, nudge toward the gap
   - Wrong → give a hint (max 2 hints, then a targeted explanation)
   - Stuck → reduce scope ("let's just think about the spatial term first")

### Student State Object

```yaml
student:
  current_step: 1
  current_phase: "discretization"  # physics | discretization | implementation | experimentation
  concepts_mastered:
    - "wave_equation_physical_meaning"
  concepts_introduced:
    - "forward_difference"
    - "cfl_condition"
  mistakes_log:
    - { step: 1, phase: "implementation", issue: "off-by-one in loop bounds", resolved: true }
  hint_count_current_question: 0
  code_submitted: null  # latest code string
  last_result: null     # stdout/plot from last run
```

### Phase Transitions

Phases advance based on demonstrated understanding, NOT student request:

- **physics → discretization**: Student can explain what the PDE means physically in their own words
- **discretization → implementation**: Student can write the finite difference formula (doesn't need to be code yet — math or pseudocode counts)
- **implementation → experimentation**: Code runs and produces qualitatively correct results
- **experimentation → next step**: Student can explain *why* a parameter change causes the observed behavior (not just *what* happened)

---

## Tech Stack Options

### Option A: CLI agent (Claude Code style)
- Python scripts per step
- Agent runs in terminal alongside student's editor
- Agent executes student code via subprocess, captures stdout + matplotlib saves
- Minimal dependencies, maximum portability
- Best for: blog audience, developer-oriented learners

### Option B: Notebook agent (Jupyter)
- Each step is a notebook
- Agent lives in special cells or a sidebar widget
- Can inspect and run cells programmatically
- More visual, easier to share plots inline
- Best for: academic audience, workshop format

### Option C: Web app (React + API)
- Monaco editor in browser for code
- Claude API backend for Socratic dialogue
- Matplotlib rendered server-side, returned as images
- Built-in plotting panel
- Best for: widest reach, polished demo, blog showcase

### Recommendation: Start with Option A for speed, build Option C for the blog series.

---

## Step 1 Deep Dive — 1D Linear Convection

### Learning Objectives
1. Understand what ∂u/∂t + c·∂u/∂x = 0 means physically
2. Derive forward difference in space and time from first principles
3. Implement the time-stepping loop in Python
4. Discover CFL condition experimentally
5. Understand numerical diffusion qualitatively

### Agent Question Bank (Step 1)

**Phase: Physics**
- "Imagine a wave moving to the right at speed c. If I give you its shape at t=0, how would you find its shape at t=1?"
- "The equation has two terms: ∂u/∂t and c·∂u/∂x. What does each represent physically?"
- "If c is negative, which direction does the wave move? Why?"

**Phase: Discretization**
- "You have u at discrete points x_0, x_1, ..., x_n. How would you estimate the slope ∂u/∂x at point i using only neighboring values?"
- "You proposed (u[i+1] - u[i]) / dx. Could you use (u[i] - u[i-1]) / dx instead? Would it matter?"
- "Now do the same for ∂u/∂t — how do you step from time n to time n+1?"

**Phase: Implementation**
- "Set up a grid: 41 points, domain [0, 2], hat function as initial condition. What's your dx?"
- "Write the time loop. What do you need to be careful about when updating u?"
- (If off-by-one): "What happens at i=0? Should your loop start there?"
- (If modifying array in-place): "You're updating u[i] using u[i-1], but you already changed u[i-1] this timestep. What's the consequence?"

**Phase: Experimentation**
- "Run with dt=0.025 and nt=20. Plot it. Does the wave keep its shape?"
- "Now try dt=0.05. What happened? Compute c·dt/dx for both cases."
- "There's a magic ratio here. What is it, and what happens when you cross it?"
- "Your wave is smearing out even when stable. That's not in the PDE. Where is this 'numerical diffusion' coming from?"

### Reference Solution (held by agent, never shown unprompted)
```python
import numpy as np
import matplotlib.pyplot as plt

nx = 41
dx = 2 / (nx - 1)
nt = 20
dt = 0.025
c = 1

u = np.ones(nx)
u[int(0.5/dx):int(1/dx+1)] = 2  # hat function

for n in range(nt):
    un = u.copy()
    for i in range(1, nx):
        u[i] = un[i] - c * dt / dx * (un[i] - un[i-1])
```

### Analytical Solution
```python
# Exact: shift initial condition by c*t
def analytical(x, t, c):
    x_shifted = x - c * t
    u = np.ones_like(x)
    u[(x_shifted >= 0.5) & (x_shifted <= 1.0)] = 2
    return u
```

### Common Mistakes to Detect
| Mistake | Detection | Hint |
|---------|-----------|------|
| No `u.copy()` before loop | Agent reads code for `.copy()` or equivalent | "What value does u[i-1] have when you compute u[i]?" |
| Loop starts at i=0 | Index check | "What's u[-1] in your grid? Does that make physical sense?" |
| Wrong sign in update | Result diverges or moves left | "Which direction should the wave move? Which direction is yours going?" |
| dt too large (CFL > 1) | Compute CFL from their dt, dx, c | "Compute c·dt/dx. What value do you get? Try a few different dt values." |
| Using forward difference in space | Works but unconditionally unstable with forward Euler | "This scheme has a name — FTFS. Look at your wave after many steps. Stable?" |

---

## Blog Series Structure

### Series Title: "12 Steps with a Mentor: Teaching CFD with AI Agents"

| Post # | Title | Hook |
|--------|-------|------|
| 0 | Why AI tutors should ask, not answer | Socratic method + agent design philosophy |
| 1 | A wave, a grid, and a stability crisis | Step 1 — discovering CFL the hard way |
| 2 | When waves eat themselves | Step 2 — nonlinearity and shock formation |
| 3 | The smoothing machine | Step 3 — diffusion as nature's low-pass filter |
| 4 | Burgers and the battle of convection vs. diffusion | Step 4 |
| 5 | Entering the second dimension | Steps 5-8 bundled as a transition post |
| 6 | The equation that never ends | Steps 9-10 — iterative solvers |
| 7 | Building Navier-Stokes from scratch | Steps 11-12 — the payoff |
| 8 | From 12 Steps to OpenFOAM | Bridge post — what changes at industrial scale |

Each post includes: the agent prompt, a sample dialogue transcript, the student's code evolution, and key plots.

---

## Milestones

### M1: Step 1 prototype (1-2 days)
- [ ] Agent prompt for Step 1 with all four phases
- [ ] Student state tracking (in-memory dict)
- [ ] Code execution sandbox (subprocess + capture)
- [ ] Matplotlib plot capture and display
- [ ] Reference + analytical solution for validation
- [ ] One full walkthrough recorded as sample dialogue

### M2: Steps 2-4 (3-4 days)
- [ ] Agent prompts for Steps 2-4
- [ ] Question banks with mistake detection
- [ ] Cross-step concept continuity ("remember CFL from Step 1...")
- [ ] Blog post drafts for Steps 1-4

### M3: Steps 5-8 — the 2D transition (3-4 days)
- [ ] 2D array handling and plotting
- [ ] Performance considerations (vectorization hints)
- [ ] Agent adapts if student already grasps 1D well

### M4: Steps 9-12 — Navier-Stokes (5-7 days)
- [ ] Iterative solver convergence monitoring
- [ ] Pressure-velocity coupling explanation strategy
- [ ] Cavity flow validation against Ghia et al.
- [ ] Final "graduation" dialogue

### M5: Blog series + open source release (3-4 days)
- [ ] Clean repo with README
- [ ] All 12 agent prompts as standalone files
- [ ] Sample dialogues as markdown
- [ ] Blog posts finalized
- [ ] Social media content (LinkedIn, Twitter threads)

---

## Open Questions

1. **Notebook vs. CLI vs. web** — Which to build first for maximum blog impact?
2. **How strict is the Socratic mode?** — Pure Socratic (never tell) is frustrating for some learners. Need an escape hatch? ("just tell me" mode with a guilt trip?)
3. **State persistence** — Should the agent remember across sessions? (Matters for multi-day learning.)
4. **Evaluation** — How do we know the tutor actually works better than reading the notebook? Pre/post quiz? Time to correct solution?
5. **Vectorization** — Barba's steps use explicit loops for clarity. When should the agent introduce NumPy vectorization? After loop version works? Or let the student discover it?

---

## Repo Structure (proposed)

```
socratic-cfd-tutor/
├── plan.md                  # this file
├── README.md
├── agent/
│   ├── tutor.py             # main agent loop
│   ├── state.py             # student state management
│   ├── executor.py          # safe code execution sandbox
│   ├── prompts/
│   │   ├── step01.md        # Socratic prompt for Step 1
│   │   ├── step02.md
│   │   └── ...
│   └── solutions/
│       ├── step01_ref.py    # reference solution (agent-only)
│       ├── step01_analytical.py
│       └── ...
├── blog/
│   ├── post00_intro.md
│   ├── post01_convection.md
│   └── ...
├── transcripts/             # sample tutor-student dialogues
│   ├── step01_session.md
│   └── ...
└── tests/
    ├── test_executor.py
    └── test_state.py
```
