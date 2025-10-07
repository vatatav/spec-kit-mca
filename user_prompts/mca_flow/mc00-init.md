# mc00-init (MCA)

Goal
- Initialize Spec-Kit for this repo with MCA or Original mode and a chosen constitution base.

What to do
- Choose Mode: MCA (default) or ORG.
- Choose Base: mca (default) or org.
- Run: `pwsh .specify/scripts/init_spec_kit.ps1 -Mode MCA -Base mca -AgentShell codex-ps`
- Result: `.specify/memory/constitution.md` populated; `.specify/.init-mode` recorded; templates aligned if ORG.

Notes
- Future enhancement: auto `git init -b main`, initial commit, and install pre-commit hook if not a repo.
- Keep outputs English-only; use relative paths.

Provenance
- Ensure any generated docs start with a provenance header (generator + UTC timestamp).

