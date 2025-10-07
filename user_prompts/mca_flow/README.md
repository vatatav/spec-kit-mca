# MCA Flow Prompts (mcXX-*)

This folder contains a numbered prompt flow tailored for Spec-Kit MCA.

Naming
- Base files: `mc00-init.md`, `mc01-constitution.md`, `mc02-specify.md`, `mc03-clarify.md`, `mc04-plan.md`, `mc05-tasks.md`, `mc06-analyze.md`, `mc07-implement.md`, `mc08-reflect.md`.
- Optional counters: append a run count at the end (e.g., `mc02-specify-03.md`). Counting is manual for now; automation may come later.

Flow
- mc00-init -> initialize kit (mode/base), mark init.
- mc01-constitution -> review/tweak constitution from selected base.
- mc02-specify -> produce/extend the feature spec.
- mc03-clarify -> resolve ambiguities before planning.
- mc04-plan -> milestone-level plan.
- mc05-tasks -> TDD-first tasks (small, ordered).
- mc06-analyze -> cross-artifact checks; provenance/hygiene gates.
- mc07-implement -> focused changes with traceability.
- mc08-reflect -> capture lessons; feed back into spec/constitution.

Notes
- Keep outputs English-only (see AGENTS.md).
- Ensure provenance header at top of generated Markdown files.
- Character hygiene: ASCII hyphen; no NBSP/ZWSP; UTF-8.

