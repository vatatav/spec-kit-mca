# Specify Primary Input - Spec-Kit-MCA Baseline

Project name: spec-kit-mca
Context: Adopt Spec-Kit for an existing repo that started as "supervisors" and evolved into an MCA-opinionated Spec-Kit distribution. Continue using the standard Spec-Kit workflow while enforcing MCA rules (provenance, character hygiene, TDD MUST, relative paths, clean dist packaging).

Goals
- Provide an MCA-opinionated variant of Spec-Kit that works in-place for existing projects.
- Keep the canonical Spec-Kit steps: /constitution -> /specify -> /clarify -> /plan -> /tasks -> /analyze -> /implement.
- Add MCA enforcement: provenance headers on generated artifacts, character hygiene, TDD MUST, relative path usage.
- Support dev vs dist separation: private development repo; clean distributable via packaging.
- Offer init modes: MCA (default) and Original (org) with switchable constitution bases.

Non-Goals
- Replace or fork upstream Spec-Kit CLI.
- Enforce agent-specific behavior beyond documented prompts and scripts.

User Stories
- As a maintainer, I want to initialize a project in MCA or Original mode, selecting a constitution base at start, so setup is predictable.
- As a contributor, I want slash-commands to read default inputs from `user_prompts/*`, so I can iterate without CLI args.
- As a reviewer, I want provenance headers on generated docs (tasks, plans), so I can trust steps weren't skipped.
- As a releaser, I want a clean dist zip that excludes `.codex` runtime files, so public artifacts are reproducible and safe.
- As a developer, I want prompts and templates that default to relative paths, so content is portable across machines.

Key Requirements (Functional)
- FR-001: Provide `/init-spec-kit` to run `.specify/scripts/init_spec_kit.ps1` with Mode (MCA|ORG), Base (mca|org), AgentShell (codex-ps initially).
- FR-002: Update command prompts to read inputs from `user_prompts/*` (not `.codex/prompts/codex_user_prompts/*`).
- FR-003: Produce packages via `.specify/scripts/package_dist.ps1` that exclude `.codex` runtime artifacts.
- FR-004: Ensure templates (plan/spec/tasks) include MCA governance references (constitution v1.3.0) and provenance checklist items where relevant.
- FR-005: Provide provenance stamping/verification via `.specify/scripts/provenance.ps1`.
- FR-006: Maintain character hygiene script and guidance; avoid smart punctuation and invisible characters.
- FR-007: Keep workflow order and support `/clarify` then `/analyze` to catch underspecification.

Key Requirements (Non-Functional)
- NFR-001: All docs and identifiers in English (MUST).
- NFR-002: Relative paths in docs and prompts (SHOULD); avoid absolute drive letters.
- NFR-003: Scripts run on Windows PowerShell (primary); future Bash variants acceptable.
- NFR-004: Minimal, surgical edits; preserve upstream structure unless necessary.

Inputs & Constraints
- Environment: Windows, PowerShell; Codex CLI with CODEX_HOME pointed at repo root to localize sessions.
- Policy: Constitution v1.3.0 (Provenance & Export; TDD MUST; Character Hygiene).
- Dist: Do not include `.codex/*` runtime state in packages.

Deliverables
- D1: Working init flow with MCA default and ORG option.
- D2: Prompts updated to `user_prompts/*` source.
- D3: Packaging script and documented excludes.
- D4: Example runbook (README snippet) showing initialize -> specify -> clarify -> plan -> tasks -> analyze -> implement for this repo.

Acceptance Criteria
- AC-001: `/init-spec-kit` succeeds (defaults: Mode=MCA, Base=mca, AgentShell=codex-ps) and writes `.specify/memory/constitution.md`.
- AC-002: `/specify` generates a spec file under `specs/spec-kit-mca/spec.md` summarizing scope above.
- AC-003: `/clarify` appends at least 3-5 clarifications into the spec and updates functional requirements where needed.
- AC-004: `/plan` and `/tasks` produce plan/tasks that include provenance requirements and reference constitution v1.3.0.
- AC-005: Packaging produces `packages/spec-kit-mca-codex-ps-*.zip` without `.codex` runtime files.

Notes
- Treat this as "using Spec-Kit with an existing project." We keep current files, add governance/flows, and iterate using standard steps.

