---
description: Prepare the next spec revision by consolidating deltas, constraints, and out-of-band changes into a clean update path.
---

Purpose
- Capture what changed since the last spec/plan/tasks, what felt wrong, and what needs to change next.
- Convert conversational deltas into structured inputs for `/mc02-specify` (via user_prompts files) and a short prep log.

Inputs
- Primary input = arguments + `user_prompts/prep-next-spec_prompt.md` (if present)

Protocol
1) Load `user_prompts/prep-next-spec_prompt.md` if it exists; combine with `$ARGUMENTS`.
2) Scan repo for latest `specs/<feature>/` and read `spec.md`, `plan.md`, and `tasks.md` if present.
3) Produce:
   - A concise list of deltas, constraints, and decisions (what to change and why)
   - Updates to `user_prompts/specify_prompt.md` (proposed patch) aligning with the deltas
   - A short prep log entry under `logs/ideas/LOG.md` (append-only) if no GitHub issue tracker is configured
4) Ask for user approval before writing any files; show proposed patches.

Boundaries (link with /mc07)
- If changes imply a scope/technology pivot or large redesign, do not patch mid-implementation.
- Route back to `/mc02-specify` after this prep step.

Output
- Proposed patch to `user_prompts/specify_prompt.md`
- Prep summary and (optional) issues/log entries

Context: $ARGUMENTS
## Handoff
- Stop after completing this step; do not auto-start the next.
- Suggest the next command and wait for the user to run it.
- Proceed only when the user runs the explicit slash command.

## Network Policy
- "Local-only" applies to mode switching (MCA<->ORG); no external access is required for switching.
- Network use is allowed when approved by the session/user.
- Always read local docs; do not use "no-network" to skip policies or checks.
### Input Acquisition Protocol (IAP)
# Step 1: File-Based Input
# Read `user_prompts/prep-next-spec_prompt.md` as File Input.
# Step 2: Argument-Based Input
# `$ARGUMENTS` from the command invocation (if any).
# Step 3: Input Consolidation
# Primary Input = Arguments + File Input.
