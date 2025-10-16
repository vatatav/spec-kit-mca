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
- Network use is allowed when approved by the session/user.
- Always read local docs; do not use "no-network" to skip policies or checks.
