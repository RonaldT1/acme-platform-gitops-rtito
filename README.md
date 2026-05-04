# bootcamp-2026-4

Working repository for the **Aquaware DevOps Bootcamp 2026 — Cohort 4**.

## What this repo is for

Aquaware uses this repository as the shared workspace for cohort 4 of the bootcamp. Every participant tracks their daily progress here: exercises, notes, deliverables, and anything produced during the bootcamp lives in this repo, organized **day by day**.

The goal is to keep a clear trail of:

- what was covered each day,
- what each participant produced,
- what blockers came up and how they were resolved.

## Repository structure

```
bootcamp-2026-4/
├── README.md              # This file (general guide for everyone)
├── .gitignore
└── day-01/                # One folder per bootcamp day
    ├── README.md          # Daily summary (objective, progress, blockers)
    ├── notes/             # Notes, commands, screenshots
    ├── exercises/         # Code, pipelines, scripts done that day
    └── deliverables/      # Final deliverables for the day
```

When a new day starts, copy the `day-01/` layout and rename it (`day-02/`, `day-03/`, ...).

## Branching model

- `main` — stable branch. Daily work lands here via pull request once a day is closed.
- `<github-username>` — each participant works in a personal branch named after their GitHub username (for example: `amartinez-aquaware`).

```bash
# First time (once per machine)
git checkout -b <your-github-username>
git push -u origin <your-github-username>
```

## Daily workflow

1. `git checkout <your-github-username> && git pull`
2. Create or open the folder for the current day: `day-NN/`
3. Work inside that folder (`notes/`, `exercises/`, `deliverables/`)
4. Update `day-NN/README.md` with the day's objective, progress and blockers
5. Commit and push at the end of the day
6. When the day is closed: open a pull request from your branch to `main`

## Conventions

- **Language**: everything in English — README files, notes, code, commands, and filenames.
- **Commits**: short imperative messages prefixed with the day. Example: `day-03: add build pipeline`.
- **Branches**: personal work stays in `<your-github-username>`; PRs target `main` at the end of each day.
- **No co-authors** in commits.
- **Secrets never committed**: use `.env` (already gitignored) and share credentials out-of-band.

## Getting help

- Cohort: 2026-4
- Org: Aquaware
- Ask in the bootcamp channel before pushing changes that affect `main` or other people's folders.
