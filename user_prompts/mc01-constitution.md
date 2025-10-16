# Project Constitution & Governance (MCA Seed)

## Input Acquisition Protocol
- Primary Input = (Arguments) + (File at `.specify/memory/constitution.md`).
- Treat `.specify/memory/constitution.md` as the base; apply only project-specific deltas from arguments.

## Task
- Load `.specify/memory/constitution.md`.
- If arguments are provided, apply them as modifications (project name, dates, minor edits).
- Update the version footer placeholders: `[CONSTITUTION_VERSION]`, `[RATIFICATION_DATE]`, `[LAST_AMENDED_DATE]`.
- Validate: no leftover unexplained bracket tokens; dates ISO YYYY-MM-DD.
- Propagate any changed references to local templates if required.
- Overwrite `.specify/memory/constitution.md` with the updated content.

## Output
- Short summary with new version, bump rationale, and any follow-ups.
