# Spec-Kit MCA (Distribution - PowerShell)

This package provides everything needed to use the Spec-Kit MCA flow inside your project with PowerShell. It is designed for agent-driven use: you trigger `/mc00` through `/mc09` commands in your agent, and the agent performs the work. You should not run internal helper scripts manually.

What's included
- `.codex/prompts/*` - the mc00-mc09 prompts (including `org/` variants)
- `.specify/templates/*` - authoring templates used by the flow
- `.specify/memory/*` - base memory (e.g., constitution seeds)
- `pwsh-LOCAL.bat` - local launcher for Codex CLI integration
- `user_prompts/` (if present) - editable inputs for commands

Getting started
1) Unzip the package into the root of your project (new or existing).
2) If you use Codex, open a shell in the project root and run `pwsh-LOCAL.bat`. This sets `CODEX_HOME` to the project so Codex can discover the `/mc` commands.
3) In your agent, start with `/mc00-init`. The agent handles initialization and will ask you to choose a mode.
4) Flows after `/mc00-init`:
   - MCA mode: `/mc01-constitute` -> `/mc02-prep-next-spec` -> `/mc03-specify` -> `/mc04-clarify` -> `/mc05-plan` -> `/mc06-tasks` -> `/mc07-analyze` -> `/mc08-implement` -> `/mc09-reflect`.
   - ORG mode (original kit): `/constitution` -> `/specify` -> `/clarify` -> `/plan` -> `/tasks` -> `/analyze` -> `/implement`.
5) Optional safety guidance: for scope or technology pivots, route back to `/mc02-prep-next-spec` -> `/mc03-specify` to consolidate changes before proceeding.

Command index (MCA)
- `/mc00-init` - initialize the kit for this project (mode/base selection)
- `/mc01-constitute` - tailor the constitution; set non-negotiables
- `/mc02-prep-next-spec` - prepare/refine inputs before specifying
- `/mc03-specify` - create or update the feature specification
- `/mc04-clarify` - resolve ambiguities with concise Q&A
- `/mc05-plan` - produce plan, research, data model, quickstart
- `/mc06-tasks` - generate dependency-ordered tasks (TDD-first)
- `/mc07-analyze` - run consistency/provenance checks (read-only)
- `/mc08-implement` - implement changes guided by tasks
- `/mc09-reflect` - capture lessons back into specs/constitution

Modes (MCA vs ORG)
- `MCA` - opinionated defaults and stricter gates aligned with the MCA approach.
- `ORG` - the original Spec-Kit baseline. You can start with either and refine via `/mc01-constitute` to produce your project's own constitution.

Choosing ORG mode at `/mc00`
- If you select `ORG` at `/mc00`, the workflow maps to the original Spec-Kit commands (`/constitution`, `/specify`, `/clarify`, `/plan`, `/tasks`, `/analyze`, `/implement`).
- MCA includes an additional `/mc09-reflect` step inspired by "reflect" practices; in ORG mode you can still perform reflection, but the canonical command names follow the original set.

Using with Codex
- Run `pwsh-LOCAL.bat` before starting work in a new shell or after reopening your editor. This ensures Codex sees the `/mc` commands under this project.
- On first run, Codex will prompt for authorization and create a `.codex/` folder with runtime files. Do not commit these files.
- If you close the CLI/IDE and return later, run `pwsh-LOCAL.bat` again before continuing.

Editing inputs (`user_prompts`)
- Before `/mc01-constitute` and `/mc02-prep-next-spec`, edit the corresponding `.md` files under `user_prompts/` to reflect your goals and requirements. The agent reads these as inputs to the flow.

Important notes
- Do not manually run internal helper scripts; the agent manages the flow.
- Runtime files under `.codex/` are environment-local and should not be versioned.

This distribution intentionally excludes developer-only helper scripts. If you are looking to package or customize the kit itself, see the project's `DEVELOPERS.md` in the source repository.

Tribute
- Spec-Kit is an outstanding, brilliantly engineered methodology. It elevates spec-driven development far beyond what most teams could assemble on their own. The clarity, composability, and rigor are truly exceptional.
- For deeper background and learning, visit the original repository: https://github.com/github/spec-kit - highly recommended to understand the philosophy behind the flow.


