# Tasks: [FEATURE NAME]

Input: Design docs from `specs/[FEATURE_SLUG]/`
Prerequisites: plan.md (required), research.md, data-model.md, contracts/

## Task Item Schema
- ID: [T###]
- Title: [short action]
- Type: [feature|fix|docs|test|refactor|observability|governance|versioning]
- Rationale: [why needed]
- Dependencies: [IDs]
- Estimate: [time or points]
- Owner: [assignee]
- Acceptance Criteria: [verifiable outcome]
- Constitution Mapping: [principle refs]

## Generation Guidance
Derive tasks from design documents.
- From contracts/: Each file → contract test task [P]
- From data model: Each entity → model task [P]; relationships → service tasks
- From user stories: Each story → integration test task [P]
- Implementation tasks exist to make tests pass

Ordering
- Tests-first policy: MUST
- Dependency order: models → services → endpoints/CLI/UI
- Mark [P] for independent tasks (different files, no deps)

## Validation Checklist
- [ ] All contracts have corresponding tests
- [ ] All entities have model tasks
- [ ] All tests come before implementation per policy
- [ ] Parallel tasks are truly independent
- [ ] Each task specifies exact file path(s)
- [ ] No two [P] tasks modify the same file
- [ ] Constitution mapping present for each task
- [ ] Provenance header present - run `.specify/scripts/provenance.ps1`
 - [ ] Character hygiene check passes (run `.specify/scripts/character_hygiene.ps1`)

## Example (commented)
<!--
[T001] [P] Create project structure (src/, tests/)
[T002] Configure linting and formatting
[T003] [P] Contract test for POST /api/example in tests/contract/test_example_post.py
[T004] Implement Example model in src/models/example.py
[T005] Service logic in src/services/example_service.py
-->

---
See `.specify/memory/constitution.md`.
