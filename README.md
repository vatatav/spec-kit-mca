# Spec-Kit MCA (Distribution)

This folder is the packaged Spec-Kit MCA distribution. It contains:
- `.specify/templates/*` - authoring templates (spec/plan/tasks)
- `.specify/scripts/*` - helper scripts (packaging, export, hygiene, provenance)
- `example-specs/` - sample specs to explore the flow

Quick Start
- Author: use `/specify`, `/clarify`, `/plan`, `/tasks`, `/analyze`, `/implement`.
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

Build the zip (from the repo root)
- `pwsh .specify/scripts/package_dist.ps1 -Version X.Y.Z`

For detailed guidance, see the repository README and the handover in `docs/HANDOVER.md`.

