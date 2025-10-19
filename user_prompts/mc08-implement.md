# Implement Primary Input (MCA)

Optional runtime constraints (e.g., skip long-running steps, dry-run first, extra logging).

Execution guardrails:
- Respect tasks order and dependencies; do not invent tasks without updating `tasks.md` first.
- Minimal change: preserve existing structure; avoid wholesale rewrites without explicit approval.
- Path discipline and sandbox usage as in Analyze: write only under `src/`, `tests/`, `docs/`, `.specify/`, `scripts/`, `sandbox/`, `dist/`.
- Tests-first: ensure failing tests exist before implementing behavior when TDD is specified.
- Traceability: update related docs/contracts and log a short entry via `.specify/scripts/powershell/append-user-progress.ps1`.
- Dist hygiene: do not place experimental artifacts in `dist/`.
