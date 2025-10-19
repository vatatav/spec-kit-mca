# mc00-init (MCA)

Goal
- Initialize Spec-Kit for this repo with MCA or Original mode and a chosen constitution base.
- If the repo already contains a recent feature under `specs/*`, detect progress and suggest the next command.

Steps
- Choose Mode: MCA (default) or ORG.
- Choose Base: mca (default) or org.
- Run: `pwsh .specify/scripts/init_spec_kit.ps1 -Mode MCA -Base mca -AgentShell codex-ps`
- Result: `.specify/memory/constitution.md` populated; `.specify/.init-mode` recorded; templates aligned if ORG.
- Resume detection: Inspect latest `specs/<feature>/` for `spec.md`, `plan.md`, and `tasks.md` to infer the next step.
  - If only `spec.md` exists → suggest `/mc03-clarify`.
  - If `spec.md` and `plan.md` exist (no `tasks.md`) → suggest `/mc05-tasks`.
  - If all three exist → suggest `/mc06-analyze`.
  - If none exist → suggest starting `/mc02-specify`.

Notes
- Future: auto `git init -b main`, initial commit, and install pre-commit hook if not a repo.
- Keep outputs English-only (see `AGENTS.md` where applicable); use relative paths.

Provenance
- Ensure generated docs start with a provenance header (generator + UTC timestamp).
## Handoff
- Stop after completing this step; do not auto-start the next.
- Suggest the next command and wait for the user to run it.
- Proceed only when the user runs the explicit slash command.

## Network Policy
- "Local-only" applies to mode switching (MCA<->ORG); no external access is required for switching.

### Initialization Flow (merged from init-spec-kit)

This section consolidates the prior `/init-spec-kit` prompt into `mc00-init` so there is a single canonical entry point.

#### Input Acquisition Protocol (IAP)
This command can read default parameters from a file and run non-interactively if desired.

Step 1: File-Based Input
- Attempt to read `user_prompts/init-spec-kit_prompt.md`.
- If read successfully, that content is the File Input; otherwise File Input is empty.

Step 2: Argument-Based Input
- If the user provides command-line arguments, they become the Argument Input (`$ARGUMENTS`).

Step 3: Input Consolidation
- Primary Input = Argument Input + File Input. Proceed using the Primary Input.

User input placeholder:
```
$ARGUMENTS
```

#### Initialization Steps
1) Determine desired mode and constitution base from the Primary Input (defaults: `Mode=MCA`, `Base=mca`):
   - Mode: one of `[MCA|ORG]`
   - Base: one of `[mca|org]`
   - AgentShell: one of `[codex-ps]` (future: codex-bash, others)

2) Execute `.specify/scripts/init_spec_kit.ps1` with the derived parameters, for example:
   - `pwsh -NoProfile -ExecutionPolicy Bypass -File .specify/scripts/init_spec_kit.ps1 -Mode MCA -Base mca -AgentShell codex-ps`

3) After the script completes, verify:
   - `.specify/memory/constitution.md` exists and matches the selected base
   - `.specify/templates/*.md` reflect the chosen mode (MCA vs ORG)
   - Emit a brief log of what changed and where

4) Output a final summary including:
   - Mode selected; Base selected
   - Files written/updated
   - Suggested next commands: `/constitution` then `/specify`

Notes
- Do not delete user files. Overwrite only the intended targets described above.
- Keep paths relative; avoid absolute drive prefixes.
- Network use is allowed when approved by the session/user.
- Always read local docs; do not use "no-network" to skip policies or checks.
