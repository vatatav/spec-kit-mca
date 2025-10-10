# Spec-Kit MCA (Distribution)

This folder is the packaged Spec-Kit MCA distribution. It contains:
- `.specify/templates/*` - authoring templates (spec/plan/tasks)
- `.specify/scripts/*` - helper scripts (init, hygiene, provenance, export)
- `.codex/prompts/*` - mc00→mc08 and `org/` prompts

Quick Start
- Download release zip (codex-ps or codex-sh) and extract; `git init -b main`.
- Initialize: PowerShell `./.specify/scripts/init_spec_kit.ps1 -Mode MCA -Base mca` or Bash `./.specify/scripts/bash/init_spec_kit.sh -m MCA -b mca`.
- Use the flow: `/mc02-specify`, `/mc03-clarify`, `/mc04-plan`, `/mc05-tasks`, `/mc06-analyze`, `/mc07-implement`, `/mc08-reflect`.
- Provenance: generated docs should include a top-of-file provenance header.
- Hygiene: normalize characters before committing (ASCII hyphen; no NBSP/ZWSP; UTF-8).

MCA Flow (mc00 → mc08)
- `/mc00-init` → initialize kit (mode/base)
- `/mc01-constitution` → review/tweak constitution
- `/mc02-specify` → write/extend spec
- `/mc03-clarify` → resolve ambiguities
- `/mc04-plan` → phased plan
- `/mc05-tasks` → TDD-first tasks
- `/mc06-analyze` → checks + gates
- `/mc07-implement` → focused changes
- `/mc08-reflect` → lessons back to specs/constitution

Build the zip (from the dev repo root)
- `pwsh .specify/scripts/package_dist.ps1 -Flavor codex-ps -Version X.Y.Z`
- `pwsh .specify/scripts/package_dist.ps1 -Flavor codex-sh -Version X.Y.Z`

Which zip should I use?
- Curated: `spec-kit-mca-codex-ps-X.Y.Z.zip` or `spec-kit-mca-codex-sh-X.Y.Z.zip` (use these to start projects).
- “Source code (zip)” on GitHub releases is a snapshot of the repo at the tag.

