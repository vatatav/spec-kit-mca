# Implementation Plan: [FEATURE]

Branch: [BRANCH] | Date: [DATE: YYYY-MM-DD] | Spec: [SPEC_PATH]

## Summary
[One-paragraph overview: problem, approach, value]

## Technical Context
- Language/Version: [LANGUAGE_VERSION]
- Primary Dependencies: [DEPENDENCIES]
- Storage: [STORAGE or N/A]
- Testing: [TEST_TOOLING]
- Target Platform: [PLATFORM]
- Project Type: [single|web|mobile]
- Performance Goals: [PERF_GOALS]
- Constraints: [CONSTRAINTS]
- Scale/Scope: [SCALE]

## Constitution Compliance Checklist
See `.specify/memory/constitution.md`.
- [ ] English-only outputs for all artifacts
- [ ] Follow documented procedures; log significant actions
- [ ] Disciplined Git workflow (branches, PRs, Conventional Commits)
- [ ] Code standards per language (e.g., PEP 8, type hints) applied
- [ ] Explicit/parametric design (no hardcoded paths/values)
- [ ] Immutable history practices respected for versioned artifacts
- [ ] Governance/versioning considerations documented (SemVer)
- [ ] Tests-first policy: MUST before implementation
 - [ ] Provenance header present - run `.specify/scripts/provenance.ps1`
 - [ ] Character hygiene: ASCII hyphen, no NBSP/ZWSP, UTF-8; ran `.specify/scripts/character_hygiene.ps1`

## Project Structure
### Documentation (this feature)
```
specs/[FEATURE_SLUG]/
  plan.md         # This file
  research.md     # Phase 0 output
  data-model.md   # Phase 1 output
  contracts/      # Phase 1 output
  quickstart.md   # Phase 1 output
  tasks.md        # Created by /tasks (not by plan)
```

### Source Code (repository root)
```
src/
  models/
  services/
  api/ or cli/ or ui/

tests/
  contract/
  integration/
  unit/
```

Structure Decision: [DEFAULT single project unless context requires web/mobile]

## Phase 0: Outline & Research
1) Extract unknowns from Technical Context (mark NEEDS CLARIFICATION)
2) Research technologies and patterns for each unknown/dependency
3) Consolidate findings in `research.md` with Decisions, Rationale, Alternatives

## Phase 1: Design & Contracts
Prerequisite: `research.md` complete.
- Define contracts (APIs, CLIs, modules) and acceptance criteria
- Draft data-model.md with entities and relationships
- Draft quickstart.md for end-to-end usage flows
- Re-check Constitution Compliance Checklist and address gaps

## Phase 2: Task Planning (Describe only)
Outline how `/tasks` should generate tasks from contracts, data model, and
quickstart. Do not create `tasks.md` here.

## Risks & Mitigations
- Risk: [RISK] → Mitigation: [MITIGATION]
- Risk: [RISK] → Mitigation: [MITIGATION]

## Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Rollback/Backout Plan
- Trigger condition(s): [TRIGGERS]
- Backout steps: [STEPS]

## Traceability
- Requirements ↔ Tasks ↔ Tests mapping: [LINKING_NOTES]

## Progress Tracking
- [ ] Phase 0 complete (research.md)
- [ ] Phase 1 complete (design docs)
- [ ] Constitution checks passed (initial + post-design)
- [ ] Ready for /tasks (Phase 2 described)

---
See `.specify/memory/constitution.md`.

