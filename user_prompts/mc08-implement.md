# Implement Primary Input (MCA)

MUST: Execute only the section titled "Addendum: T030 packaging smoke" below. All earlier sections are historical guidance; do not implement them. Do not auto‑advance.

Optional runtime constraints (e.g., skip long-running steps, dry-run first, extra logging).

Execution guardrails:
- Respect tasks order and dependencies; do not invent tasks without updating `tasks.md` first.
- Minimal change: preserve existing structure; avoid wholesale rewrites without explicit approval.
- Path discipline and sandbox usage as in Analyze: write only under `src/`, `tests/`, `docs/`, `.specify/`, `scripts/`, `sandbox/`, `dist/`.
- Tests-first: ensure failing tests exist before implementing behavior when TDD is specified.
- Traceability: update related docs/contracts and log a short entry via `.specify/scripts/powershell/append-user-progress.ps1`.
- Dist hygiene: do not place experimental artifacts in `dist/`.

---

Addendum: T030 packaging smoke (do not modify code)

Boundaries (MUST)
- T030 only; no changes to prompts, guards, or hooks. Do not auto-advance.

Steps
- Analyze (read-only):
  - `pwsh -NoProfile -ExecutionPolicy Bypass .specify/scripts/powershell/analyze_gate.ps1`
- Build packages:
  - `pwsh -NoProfile -ExecutionPolicy Bypass .specify/scripts/package_dist.ps1 -Flavor codex-ps -Version 0.1.0`
  - `pwsh -NoProfile -ExecutionPolicy Bypass .specify/scripts/package_dist.ps1 -Flavor codex-sh -Version 0.1.0`
- Smoke test:
  - `pwsh -NoProfile -ExecutionPolicy Bypass .specify/scripts/powershell/smoke_test_package.ps1 -ZipPath packages/spec-kit-mca-codex-ps-0.1.0.zip`
  - `pwsh -NoProfile -ExecutionPolicy Bypass .specify/scripts/powershell/smoke_test_package.ps1 -ZipPath packages/spec-kit-mca-codex-sh-0.1.0.zip`

Verify and report
- Referenced-scripts gate: OK
- Parity: OK (shared files; includes `.specify/memory/**/*.md` and `user_prompts/*.md`)
- End-user README present in each zip; `DEVELOPERS.md` excluded
- Text normalized to CRLF; uniform timestamps across staged files
- No runtime/scratch in zips: no `.codex/**`, `zzz/**`, `specs/**`, `out/**`, `data/upstream/**`

Output policy
- PASS/FAIL per zip + any WARNs from mode guard; list produced paths. No file dumps. No code changes; stop at checkpoint.

---

ARCHIVE BELOW — DO NOT EXECUTE

Addendum: Phase 3.7 wrap-up - MCA scope (do not auto-advance)

Boundaries (MUST)
- Only do these items, then STOP and present a checkpoint summary:
  - T025: Active prompts vs Mode guard (warn-only). Wire into analyze_gate.ps1 and package_dist.ps1. Print WARN lines; never fail.
  - FR-003: Expand parity_check.ps1 scope to include `.specify/memory/**/*.md` and `user_prompts/*.md` (keep LF normalization; exit 1 on mismatch/missing counterpart).
  - T042: Pre-commit stays presence-only; warn (do not fail) on generator token mismatch; run referenced_scripts_gate.ps1 only when `.codex/prompts/**` or `.specify/scripts/**` changed.
  - End-user README (English, detailed) added to both flavors; ensure `DEVELOPERS.md` remains repo-only and excluded in packaging.
- No auto-advance to other phases. No mode layout refactors or new features.

Implement
- Active-mode guard (warn-only)
  - Read active mode from `.init-mode` (default MCA if missing).
  - Compare to the prompts exposed under `.codex/prompts`:
    - If MCA active: warn if ORG prompts are active or MCA prompts missing.
    - If ORG active: warn if MCA prompts are active or ORG prompts missing.
  - Integrate:
    - analyze_gate.ps1: print WARN; exit 0.
    - package_dist.ps1: print WARN; proceed (do not fail packaging).

- Parity scope expansion (FR-003)
  - parity_check.ps1 compares PS vs SH for:
    - `.specify/templates/**`
    - `.specify/templates/constitutions/**`
    - `.codex/prompts/**`
    - `.specify/memory/**/*.md`
    - `user_prompts/*.md`
  - Normalize to LF before compare; report first differing line and missing counterpart; exit 1 on mismatch.

- Pre-commit (T042, lenient)
  - Require provenance header presence on `specs/**/{research.md,plan.md,tasks.md,quickstart.md}`.
  - Warn (do not fail) if generator token does not match file type or active mode (accept MCA and ORG tokens; warn when non-active mode appears).
  - Run `referenced_scripts_gate.ps1` only if the commit touches `.codex/prompts/**` or `.specify/scripts/**`.
  - Print: "Run analyze_gate.ps1 for full checks." Allow `--no-verify` escape hatch.

- End-user README
  - Add `README.md` to `flavors/codex-ps` and `flavors/codex-sh` explaining:
    - Start with `mc00-init`; default MCA; you can switch to ORG.
    - Flow `mc00 -> mc09`; what the Local launcher does; why a WSL2 hint may appear on Windows.
    - Only MCA prompts are active by default; ORG prompts can be enabled via `mc00-init`.
  - Ensure `DEVELOPERS.md` stays repo-only and is excluded in packaging.

Validation (perform and report)
- Run analyze gate locally:
  - `pwsh -NoProfile -ExecutionPolicy Bypass .specify/scripts/powershell/analyze_gate.ps1`
- Build and smoke both flavors:
  - `pwsh -NoProfile -ExecutionPolicy Bypass .specify/scripts/package_dist.ps1 -Flavor codex-ps -Version 0.1.0`
  - `pwsh -NoProfile -ExecutionPolicy Bypass .specify/scripts/powershell/smoke_test_package.ps1 -ZipPath packages/spec-kit-mca-codex-ps-0.1.0.zip`
  - `pwsh -NoProfile -ExecutionPolicy Bypass .specify/scripts/package_dist.ps1 -Flavor codex-sh -Version 0.1.0`
  - `pwsh -NoProfile -ExecutionPolicy Bypass .specify/scripts/powershell/smoke_test_package.ps1 -ZipPath packages/spec-kit-mca-codex-sh-0.1.0.zip`
- Expected:
  - Analyze: WARN lines only if mode/prompt misaligned; otherwise clean.
  - Parity: OK across PS/SH, including `.specify/memory/**` and `user_prompts/*.md`.
  - Referenced-scripts: OK.
  - Packaging: zips build; smoke PASS; uniform mtimes; CRLF for text.

Output policy
- Keep logs concise; list changed paths and short diffs when useful.
- Do not auto-advance. Stop after Phase 3.7 wrap-up and present a checkpoint summary.

Suggested commit messages
- `feat(guard): add active mode vs prompts warn-only check [T025]`
- `feat(parity): expand parity_check to memory and user_prompts [FR-003]`
- `chore(hooks): pre-commit presence-only + generator warn; conditional referenced-scripts [T042]`
- `docs(readme): add end-user README to flavors; keep DEVELOPERS.md repo-only`

 
