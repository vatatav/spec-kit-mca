# [PROJECT_NAME] Agent Guidelines

Last Updated: [DATE: YYYY-MM-DD]

## Purpose
Concise guidance for assisting agents working on this project. Aligns with the
project Constitution (v1.1.0) at `.specify/memory/constitution.md`.

## Interaction Principles
- English-only outputs for all artifacts and responses
- Follow documented procedures; escalate ambiguity with targeted questions
- Minimal, surgical changes; preserve structure unless asked otherwise
- Explain rationale briefly; note tradeoffs when relevant

## Development Rules
- Git workflow: feature branches, PR reviews, Conventional Commits
- Code standards: [LANGUAGE_STANDARDS] (e.g., Python PEP 8, type hints)
- Explicit/parametric design: no hardcoded paths/values
- Immutable history: version rather than mutating versioned artifacts
- Tests-first (TDD): failing tests MUST precede implementation

## Working Notes
- Context sources: [LINKS or PATHS]
- Build/run commands: [COMMANDS]
- Test commands: [TEST_COMMANDS]
- Lint/format: [LINT_COMMANDS]

## Review Checklist
- [ ] English-only, procedures/logging followed
- [ ] Branch/PR flow and Conventional Commits used
- [ ] Code meets standards and design is parametric
- [ ] Tests written first and initially failing; implementation follows
- [ ] Docs/contracts updated to match behavior

## Decision Log
Record significant decisions with issue links and rationale.
- Date: [DATE] | Item: [SUMMARY] | Link: [ISSUE/PR]

