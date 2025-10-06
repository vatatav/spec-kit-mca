# Spec-Kit MCA (Distribution)

Spec-Kit MCA is an opinionated GitHub Spec-Kit distribution with:
- Provenance headers (generator + UTC timestamp) enforced by pre-commit + CI
- Character hygiene gates (ASCII hyphen; no NBSP/ZWSP; UTF-8)
- Packaging and export scripts for reproducible zips and governance bundles
- Original templates with minimal MCA checklist bullets

Quick Start
- Use `/specify`, `/clarify`, `/plan`, `/tasks`, `/analyze`, `/implement` as usual
- Generated docs under `specs/<feature>/` must carry a provenance header at top
- Normalize characters before committing (or let pre-commit fix staged files)

Scripts
- `.specify/scripts/provenance.ps1` - add/verify provenance headers
- `.specify/scripts/character_hygiene.ps1` - check/normalize characters
- `.specify/scripts/package_dist.ps1` - build dist zips into `packages/`
- `.specify/scripts/export_pipeline.ps1` - export governance bundle

License
- See repository license or contact the maintainer.

