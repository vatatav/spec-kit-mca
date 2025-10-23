# Analyze Primary Input (MCA)

Use this section to add any extra context to check during the cross-artifact analysis.

Enforcement (must-haves):
- Minimal change: prefer surgical edits over rewrites. Flag large rewrites as CRITICAL unless explicitly approved.
- Path discipline: only create/modify files in: `src/`, `tests/`, `docs/`, `.specify/`, `scripts/`, `sandbox/`, `dist/`.
- Sandbox quarantine: any throwaway or exploratory code MUST be placed under `sandbox/` (e.g., `sandbox/scratch_<desc>.py`).
- Test placement: only `tests/` may contain `test_*` files. Flag violations.
- Dist hygiene: `dist/` MUST NOT include `sandbox/` or scratch files.
- Traceability: each change must link back to spec/plan/tasks; update docs when interfaces change; append a line to `.specify/memory/user-progress.md` (use append-user-progress.ps1).
- Constitution authority: treat `.specify/memory/constitution.md` as non-negotiable; report conflicts instead of diluting rules.

Output: list any violations with file paths and suggested remediations.
