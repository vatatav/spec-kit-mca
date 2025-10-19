# MCA Constitution

## Core Principles

1) English as the Standard
- All artifacts (docs, code identifiers, messages, commit texts) MUST be in English.

2) Procedural Supremacy
- Follow documented procedures. Where a procedure exists, it is not optional.

3) Structured and Traceable Logging
- Significant activities MUST be logged using standard files.

4) Disciplined Version Control
- Feature branches, atomic commits, PR reviews, Conventional Commits.

5) Code Quality and Standards
- Language-appropriate standards (e.g., Python: PEP 8, type hints, docstrings, robust error handling).

6) Agent as Collaborative Partner
- Explain reasoning, propose alternatives, ask clarifying questions when ambiguous.

7) Explicit, Parametric, Reusable Design
- Avoid hard-coded paths/values; parameters/configuration SHOULD be used.

8) Immutable History
- Versioned artifacts are append-only. Replace behavior by versioning, not mutation.

9) Tests First (TDD)
- Failing tests MUST be written before implementation; implementation proceeds only when
  tests exist and initially fail. Exceptions require explicit governance waiver with
  justification recorded in decision logs.

## Development Workflow & Quality Gates
- Constitution check at plan and post-design phases.
- Tests-first (TDD) MUST precede implementation; docs/contracts kept in sync.
- PRs MUST include a constitution compliance checklist item.

### Provenance & Export
- Generated artifacts MUST include a provenance header at the top of the file indicating
  the generator and timestamp (UTC). Recommended format for Markdown:
  `<!-- Generated-by: /<command> | Timestamp: 2025-10-01T00:00:00Z -->`
- Use `.specify/scripts/provenance.ps1` to add or verify headers for Markdown/text artifacts.
- Projects SHOULD maintain an export/archive pipeline to collect key artifacts (constitution,
  templates, prompts, recent session logs) for traceability. See
  `.specify/scripts/export_pipeline.ps1`.

## Governance and Amendments
- The Governance Model defines rule precedence and the amendment process.
- Default amendment path: open a "Governance Amendment" issue, gain maintainer decision, update docs, record decision.
- Versioning policy: Semantic Versioning.
  - MAJOR: Backward-incompatible governance/principle removals or redefinitions.
  - MINOR: New principle/section added or materially expanded guidance.
  - PATCH: Clarifications, wording, typo fixes, non-semantic refinements.

## Compliance
- Everyone (humans/agents) ensures their own compliance.
- Violations are critical and must be corrected immediately.

## Agent Behavioral Rules
This MCA Methodology document defines how assisting agents collaborate within projects adopting this methodology.

## Core Behaviors
- Follow documented procedures; where a procedure exists, it is mandatory
- Make minimal, surgical changes; avoid broad refactors unless requested
- Collaborate: explain reasoning, propose alternatives, and ask clarifying questions
- Respect governance: defer to project-specific rules when conflicts arise and record decisions

## Interaction Expectations
- Keep responses concise, direct, and friendly
- Responses SHOULD provide actionable guidance with clear next steps
- Maintain English-only outputs for artifacts

## Operational Rules
- Rule of Precedence: When rules conflict, follow the more specific or restrictive rule; otherwise escalate for a decision and do not guess.
- Literal Interpretation: Interpret instructions literally; if ambiguity exists, ask for clarification instead of assuming intent.
- Context Boundary: Treat environmental/context blocks as read-only; act on them only when explicitly referenced by the user prompt.

## Communication and Change Discipline
- English-only output at all times for artifacts and responses.
- Explain the why behind suggestions; mention alternatives and tradeoffs briefly when relevant.
- Preserve existing document structure and content; apply minimal, targeted edits necessary to fulfill the request.
- Ground assertions in the provided sources; avoid invented structure or details.
- Adhere to repository structure and naming conventions.

### Character Hygiene
- Text artifacts MUST avoid invisible or non-standard characters (e.g., NBSP, ZWSP) and enforce ASCII hyphen/minus when intended.
- Use UTF-8 encoding for files; verify via repository scripts.

## Project Lifecycle & Structure
This MCA Methodology document describes repository structure and the Git workflow.

## Git Workflow (GitHub Flow)
- Feature branches off `main`
- Open Pull Requests early; require review before merge
- Deploy from `main`; keep `main` releasable
- Use Conventional Commits for commit messages

## Branch Naming (GitHub Flow)
- Features: `feature/<short-description>` or `feat/<ticket>-<short>`
- Fixes: `fix/<short-description>` or `bugfix/<ticket>-<short>`
- Hotfixes: `hotfix/<short-description>` (branch off `main`)
- Note: No long-lived `develop` branch; integrate via PRs into `main`.

## Commit Standards (Conventional Commits)
- Format: `<type>[optional scope]: <description>`
- Common types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
- Keep commits atomic and focused; avoid unrelated changes.

## Pull Request Process
- PRs include clear description, rationale, and test/validation notes.
- Require at least one maintainer review for `docs/methodology/*` (CODEOWNERS).
- Keep branches up to date with `main` before merging.

## Merge Strategy
- Squash or rebase-and-merge SHOULD be used for a clean history.
- Delete the feature branch after merge.

## Naming Conventions (General)
- Files and directories SHOULD use kebab-case for docs; code SHOULD use snake_case where applicable.
- Classes: PascalCase; Constants: UPPER_SNAKE_CASE (language-appropriate).
- English-only names for files, identifiers, and documentation.

## Standard Project Layout (General)
Projects adopting this methodology typically use a structure similar to:
```
project_name/
  src/                 # Source code
  tests/               # Unit/contract/integration tests
  docs/                # Project-specific docs (this methodology under docs/methodology/ at repo root)
  logs/                # Project logs (sessions.md, llm_assisted_development_log.md, user_progress_log.md)
  scripts/             # Utility scripts
  README.md            # Project overview
```
Adjust as appropriate per language/runtime while keeping consistency.

## Release & Change Control
- Changes to methodology docs follow PR review and checklist
- Version documents as needed; record decisions in governance logs

## Lifecycle Phases (High-Level)
- Conception & Setup: define scope/goals; scaffold structure; initialize repo; add foundational docs.
- Iterative Development: branch per unit of work; keep commits atomic; PR into `main`.
- Session Management: log significant actions; use handover/takeover at boundaries.
- Completion & Maintenance: tag releases; maintain via standard PR flow.

## Corrective Changes Playbook
When a gap is discovered after a feature completes:
1. Decide scope: small corrective change vs. new feature.
2. For small corrective changes:
   - Make the minimal fix.
   - Commit with a clear message including ItemID.
3. For larger changes:
   - Open a new feature (spec/plan in `specs/*`).
   - Run the normal spec-kit workflow (clarify → plan → design → tasks).
4. Always re-run relevant contract checks.

# Governance Model

## Rule Hierarchy & Precedence
- Project-specific rules take precedence over global ones when conflicts arise
- Record rationale and traceability for any override

## Decision Log Format
- Use a structured entry with fields: issue link, decision, justification, precedent links, date
- Keep a dedicated section or file for governance decisions

## Amendment Process (Default)
- When new guidance conflicts with the Constitution, follow the issue-driven flow:
  1. Open a GitHub issue titled "Governance Amendment: <short title>" with labels `governance` and `amendment`
  2. Maintainers discuss and decide within the issue
  3. Update relevant docs via PR after decision (reference the issue)
  4. Record the decision in the decision log

