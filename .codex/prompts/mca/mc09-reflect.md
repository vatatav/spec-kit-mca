# mc09-reflect (MCA) - Reflect Lessons Into Specs

Intent
- After a cycle of work, synthesize lessons from actual changes, CI results, and review feedback. Update the spec (and later the constitution) to encode durable insights.

Inputs
- Recent commits and PR notes
- CI run outcomes (provenance/hygiene findings)
- What worked vs. friction points

Tasks
- Append a "Lessons Learned" section to the relevant spec with concise bullets and planned follow-ups.
- Propose constitution deltas (future change) without editing it directly if policy changes are significant.
- Open tracking issues in `vatatav/spec-kit-mca-development` for non-trivial governance changes (e.g., tagging policy, merge strategy, init automation), or append locally to `logs/ideas/LOG.md` when GH is not configured.

Output
- Updated spec with lessons and next iteration plan.


## Handoff
- Stop after completing this step; do not auto-start the next.
- Suggest the next command and wait for the user to run it.
- Proceed only when the user runs the explicit slash command.

## Network Policy
- "Local-only" applies to mode switching (MCA<->ORG); no external access is required for switching.
- Network use is allowed when approved by the session/user.
- Always read local docs; do not use "no-network" to skip policies or checks.
# mc08-reflect (MCA) - Reflect Lessons Into Specs
### Input Acquisition Protocol (IAP)
# Step 1: File-Based Input
# If `user_prompts/mc09-reflect-user.md` exists, load it as File Input; otherwise empty.
# Step 2: Argument-Based Input
# `$ARGUMENTS` from the command invocation (if any).
# Step 3: Input Consolidation
# Primary Input = Arguments + File Input.
