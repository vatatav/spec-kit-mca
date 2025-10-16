# Spec-Kit-MCA: Mode Layout + Parity + Flow Rename

## mc02-prep-next-spec Rules (this step only)
- Do not change files yet. Propose the spec for review.
- Wait for explicit user approval, or the user may run `/specify` directly if satisfied.

## Context
- Standardize the MCA distribution by:
  - Renaming the end-to-end flow (mc00→mc09) and adding a pre-spec step (mc02) to avoid ad-hoc edits.
  - Unifying mode assets under a canonical layout and supporting local-only switching (no network).
  - Enforcing PS/SH parity by authoring shared assets once and mirroring to both flavors.
  - Cleaning `user_prompts` (remove legacy `mca_flow`, rename remaining prompts to `mcXX-*.md`).
  - Ensuring prompts include an Input Acquisition Protocol (IAP), starting with mc08 and mc09.
  - Embedding a governance rule in MCA Constitution for capturing future ideas as GitHub issues (or local log when GH isn't configured).
  - Aligning with upstream Spec-Kit changes and maintaining a visible delta log.

## Flow Rename (mapping + semantics)
- mc00-init → initialize kit (mode/base), mark init, suggest next step from existing artifacts
- mc01-constitution → review/tweak constitution from the selected base
- mc02-prep-next-spec → pre-spec consolidation (this step)
- mc03-specify → produce/extend the feature spec
- mc04-clarify → resolve ambiguities before planning
- mc05-plan → milestone-level plan
- mc06-tasks → TDD-first tasks (small, ordered)
- mc07-analyze → cross-artifact checks; provenance/hygiene gates
- mc08-implement → focused changes with traceability; feedback loop capped to 3-5 iterations; scope pivots go back to mc02→mc03
- mc09-reflect → append "Lessons Learned" (LL) to the spec; feed back into spec/constitution

## Definitions
- Local-only switching: Selecting MCA or ORG copies assets from `.kit/modes/**` within the project; no network access required.
- Parity: Non-launcher shared files (prompts/templates/memory) are byte-identical across PS/SH (normalized EOL/timestamps). Only launchers differ (`pwsh-LOCAL.bat` vs `sh-LOCAL.sh`).
- Lessons Learned (LL): mc09 appends timestamped, concise bullets (what changed, why, surprises, follow-ups) to the current feature spec.

## Goals
- Provide a clear, renamed flow with a pre-spec step that prevents drift.
- Ship both MCA and ORG modes; on ORG selection, expose original Spec-Kit commands and hide MCA `mc*` prompts.
- Author shared assets once (single source) and mirror to both flavors to guarantee parity.
- Normalize packages: include runtime helpers; include `.kit/modes/**`; exclude dev-only scripts.
- Clean and rename `user_prompts` content to match the new `mcXX` flow names.
- Ensure IAP presence for mc08 and mc09 (and keep consistent thereafter).
- Embed "ideas capture" as constitutional policy; prompts may remind and assist.
- Track upstream Spec-Kit changes and document adaptation deltas in MCA.

## Non-Goals
- Changing upstream semantics of original Spec-Kit commands in ORG mode.
- Adding networked services for mode switching.
- Pushing to public repo before plan/analyze gates.

## Functional Requirements (FR)
- FR-001 (Mode Layout): Add `.kit/modes/` with:
  - `.kit/modes/mca/{prompts,templates}` - canonical MCA assets (single-source authored, mirrored to PS/SH).
  - `.kit/modes/org/{prompts,templates}` - canonical ORG assets (original command prompts and templates).
  - `.kit/modes/constitutions/{mca_constitution_base.md, org_constitution_base.md}` - single sources of bases.
- FR-002 (Init Copy Logic): Update init so:
  - MCA: use MCA assets (mc* prompts) as active.
  - ORG: copy `.kit/modes/org/prompts/*.md` into `.codex/prompts/` (expose `/specify`, `/clarify`, `/plan`, `/tasks`, `/analyze`, `/implement`) and hide MCA `mc*` prompts; copy `.kit/modes/org/templates/*.md` into `.specify/templates/`.
- FR-003 (Single-Source + Parity Check): Author shared assets once under `.kit/common/**` (or equivalent). Mirror to both flavors. Provide a source-only parity check that hashes PS/SH files and fails on mismatches.
- FR-004 (Packaging): Include runtime helper scripts; include `.kit/modes/**`; exclude dev-only scripts (packaging/export/CI/dev helpers). Keep `.codex` runtime artifacts out. Normalize timestamps and EOL.
- FR-005 (Prompts IAP): Add/ensure IAP sections for mc08-implement and mc09-reflect (file-based + arguments → primary input).
- FR-006 (Implement Boundaries): In mc08, cap feedback to 3-5 iterations for corrections only. For scope/technology pivots, route to mc02→mc03 refresh instead of continuing in mc08.
- FR-007 (Lessons Learned): In mc09, always append "Lessons Learned" to the current feature spec (timestamped, concise).
- FR-008 (Resume Awareness): mc00 suggests the correct next step by scanning the latest `specs/<feature>/` for `spec.md`, `plan.md`, and `tasks.md`.
- FR-009 (user_prompts Cleanup): Remove `user_prompts/mca_flow/*` from distribution; rename remaining prompts to `mcXX-*.md`. Keep `user_prompts/specify_prompt.generic.md` as guidance only (no private details).
- FR-010 (Ideas Capture Governance): Add to MCA Constitution:
  - When the user shares future work/ideas outside current scope, open GitHub issues in `vatatav/spec-kit-mca-development` (labels: `status: planned` + topic). If GitHub is not configured or user prefers local, append to `logs/ideas/LOG.md`. Prompts (e.g., mc09) may offer to file.
- FR-011 (Public Repo Timing): Do not push to `github.com/vatatav/spec-kit-mca` until mc05 and mc06 have passed.
- FR-012 (Public Repo Content Strategy): Treat the public repo as distribution source:
  - Public root mirrors the packaged dist layout (not dev repo structure).
  - Maintain separate Git history; after mc05/mc06, create an orphan baseline (v1.0.0), remove old releases/tags, and push fresh.
- FR-013 (Upstream Tracking): Track upstream Spec-Kit changes (init scaffolds, prompts, scripts) and document MCA adaptations per release (CHANGELOG or docs notes).
- FR-014 (Prompt Usage Counters): Establish `mcXX-<step>-NN` convention (optional) and a local, source-only usage log (no telemetry). Provide a tiny helper to append counts to `logs/prompt_usage.md`.
- FR-015 (Constitution Variants): Scaffold `.kit/modes/constitutions/{web,mobile,python}` as placeholders this cycle; wire recognition in mc00 for future selection (no content yet).
- FR-016 (Init Auto-Setup, Optional): Offer an opt-in flag to run `git init -b main`, make the first commit, and install a pre-commit hook (off by default).
- FR-017 (Reflection Back-port): mc09-reflect should propose back-porting key LL into the constitution/spec with explicit user approval.

## Non-Functional Requirements (NFR)
- NFR-001: English-only artifacts.
- NFR-002: Deterministic packaging (timestamps/EOL normalized); parity across PS/SH.
- NFR-003: Relative paths; avoid absolute drive letters.

## Inputs & Constraints
- Do not rely on git-ignored/scratch areas (e.g., `zzz/`, `.codex/`) unless the user explicitly references a specific path.
- Mode switching must be local-only and reversible by re-running mc00.
- This mc02 step is spec-only; no repository edits.

## Deliverables
- `.kit/modes/{mca,org,constitutions}` with shared assets authored once and mirrored to PS/SH.
- Updated init scripts implementing copy/hide rules for ORG selection and optional auto-setup flag.
- Parity check script (source-only).
- Updated prompts:
  - mc08-implement (IAP + boundaries + escalation).
  - mc09-reflect (IAP + mandatory LL append + back-port suggestion).
- `user_prompts`:
  - Legacy `mca_flow/*` removed from packages.
  - Remaining prompts renamed to `mcXX-*.md`.
  - `specify_prompt.generic.md` kept as guidance only (no private details).
- Packaging updates honoring includes/excludes and normalization.
- Upstream tracking note/changelog for MCA adaptations.
- Prompt usage helper and local log (`logs/prompt_usage.md`).
- Public repo reset plan (dist-as-source, orphan history v1.0.0 after mc05/mc06).

## Acceptance Criteria
- AC-001: ORG selection exposes original commands and hides MCA `mc*` without network calls.
- AC-002: PS/SH shared assets are byte-identical (parity check passes).
- AC-003: Packages include `.kit/modes/**`, exclude dev-only scripts, keep runtime helpers, and normalize timestamps/EOLs.
- AC-004: mc08 includes IAP and enforces feedback cap with clear escalation to mc02.
- AC-005: mc09 includes IAP, appends timestamped "Lessons Learned" to the spec, and proposes back-porting important LL to constitution/spec.
- AC-006: mc00 suggests the correct next step from existing artifacts.
- AC-007: `user_prompts` has no `mca_flow/*`; remaining prompts use `mcXX-*.md`.
- AC-008: MCA Constitution includes the ideas capture policy; prompts can assist.
- AC-009: Upstream tracking entry present (notes/changelog).
- AC-010: Prompt usage counter helper writes to `logs/prompt_usage.md`.
- AC-011: Public repo reset plan prepared (dist-as-source, orphan baseline v1.0.0 after gates).

## Migration Notes
- Rename all references (docs/scripts/prompts/user_prompts) to the new mc00→mc09 mapping.
- On ORG, hide MCA `mc*` prompts and expose only original commands.
- Author shared assets once (e.g., `.kit/common/**`) and mirror to PS/SH; run parity check before packaging.
- Remove legacy `user_prompts/mca_flow/*` from packages; keep `specify_prompt.generic.md` as guidance only.
- Keep public repo separate; reset history after mc05/mc06 to establish v1.0.0.


