# Feature Specification: [FEATURE NAME]

Feature Branch: [BRANCH]
Created: [DATE: YYYY-MM-DD]
Status: Draft
Input: [SOURCE_DESCRIPTION or LINK]

## Problem Statement
[What problem are we solving and why it matters]

## Goals and Non-Goals
- Goals: [GOAL_1], [GOAL_2]
- Non-Goals: [NONGOAL_1], [NONGOAL_2]

## User Scenarios & Testing (mandatory)
### Primary User Story
[Describe the main user journey in plain language]

### Acceptance Scenarios
1. Given [initial state], When [action], Then [expected outcome]
2. Given [initial state], When [action], Then [expected outcome]

### Edge Cases
- [boundary condition handling]
- [error scenario handling]

## Requirements (mandatory)
### Functional Requirements
- FR-001: System MUST [capability]
- FR-002: System MUST [capability]
- FR-003: Users MUST be able to [interaction]
- FR-004: System MUST [data behavior]
- FR-005: System MUST [observability/logging requirement]

Examples of unclear requirements to mark explicitly:
- FR-00X: System MUST [NEEDS CLARIFICATION: missing detail]

### Non-Functional Requirements
- Performance: [targets]
- Reliability: [targets]
- Security: [requirements]
- Observability: [logs/metrics/traces requirements]
- Accessibility: [requirements]

### Key Entities (include if data involved)
- [Entity 1]: [summary]
- [Entity 2]: [summary]

## Constraints & Policies
Map relevant constitution principles to this feature.
- English-only outputs: [Yes/Notes]
- Procedural compliance & logging: [Notes]
- VC discipline (branches, PRs, Conventional Commits): [Notes]
- Code standards (language-specific): [Notes]
- Explicit/parametric design: [Notes]
- Immutable history: [Notes]
- Governance/versioning impacts: [Notes]
 - Character hygiene (ASCII hyphen, no NBSP/ZWSP, UTF-8): [Notes]

## Interfaces / Contracts
- [Interface 1]: [behavior, inputs/outputs]
- [Interface 2]: [behavior, inputs/outputs]

## Data Model
- Entities and relationships: [diagram/description]

## Testing Strategy
- Contracts: [files]
- Integration: [scenarios]
- Unit: [coverage goals]
- Tests-first policy: MUST

## Documentation Updates
- quickstart.md: [sections]
- contracts/: [files]
- api.md or cli.md: [notes]

## Review & Acceptance Checklist
Content Quality
- [ ] Written for stakeholders (what/why, not how)
- [ ] Mandatory sections completed
- [ ] No implementation details (languages, frameworks, APIs)

Requirement Completeness
- [ ] No [NEEDS CLARIFICATION] remain or they're justified
- [ ] Requirements are testable and unambiguous
- [ ] Success criteria measurable
- [ ] Scope bounded; dependencies and assumptions identified

---
See `.specify/memory/constitution.md`.

