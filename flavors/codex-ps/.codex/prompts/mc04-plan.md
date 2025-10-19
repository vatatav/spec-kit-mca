---
description: Execute the implementation planning workflow using the plan template to generate design artifacts.
---

### Input Acquisition Protocol (IAP)
# This protocol defines how user input is acquired, supporting multiple agent systems.
# The final, consolidated input is referred to as the 'Primary Input' in subsequent steps.

# Step 1: File-Based Input
# You will attempt to read a dedicated file for this command from a relative path.
# The file for the /plan command is 'user_prompts/plan_prompt.md'.
# Use the `read_file` tool to load the content of that file.
# If the file is read successfully, its content is the 'File Input'. If not, the 'File Input' is empty.

# Step 2: Argument-Based Input
# The '$ARGUMENTS' variable below will be populated if the user provides direct command-line arguments.
# This is the 'Argument Input'.

# Step 3: Input Consolidation
# The 'Primary Input' is the combination of both sources to allow for maximum flexibility.
# 'Primary Input' = 'Argument Input' + 'File Input'.
# You MUST now proceed using the 'Primary Input'.

User input:

$ARGUMENTS

Given the implementation details provided as an argument, do this:

1. Run `.specify/scripts/powershell/setup-plan.ps1 -Json` from the repo root and parse JSON for FEATURE_SPEC, IMPL_PLAN, SPECS_DIR, BRANCH. All future file paths must be absolute.
   - BEFORE proceeding, inspect FEATURE_SPEC for a `## Clarifications` section with at least one `Session` subheading. If missing or clearly ambiguous areas remain (vague adjectives, unresolved critical choices), PAUSE and instruct the user to run `/clarify` first to reduce rework. Only continue if: (a) Clarifications exist OR (b) an explicit user override is provided (e.g., "proceed without clarification"). Do not attempt to fabricate clarifications yourself.
2. Read and analyze the feature specification to understand:
   - The feature requirements and user stories
   - Functional and non-functional requirements
   - Success criteria and acceptance criteria
   - Any technical constraints or dependencies mentioned

3. Read the constitution at `.specify/memory/constitution.md` to understand constitutional requirements.

4. Execute the implementation plan template:
   - Load `.specify/templates/plan-template.md` (already copied to IMPL_PLAN path)
   - Set Input path to FEATURE_SPEC
   - Run the Execution Flow (main) function steps 1-9
   - The template is self-contained and executable
   - Follow error handling and gate checks as specified
   - Let the template guide artifact generation in $SPECS_DIR:
     * Phase 0 generates research.md
     * Phase 1 generates data-model.md, contracts/, quickstart.md
     * Phase 2 generates tasks.md
   - Incorporate user-provided details from arguments into Technical Context: $ARGUMENTS
   - Update Progress Tracking as you complete each phase

5. Verify execution completed:
   - Check Progress Tracking shows all phases complete
   - Ensure all required artifacts were generated
   - Confirm no ERROR states in execution

6. Report results with branch name, file paths, and generated artifacts.

Use absolute paths with the repository root for all file operations to avoid path issues.
## Handoff
- Stop after completing this step; do not auto-start the next.
- Suggest the next command and wait for the user to run it.
- Proceed only when the user runs the explicit slash command.

## Network Policy
- "Local-only" applies to mode switching (MCA<->ORG); no external access is required for switching.
- Network use is allowed when approved by the session/user.
- Always read local docs; do not use "no-network" to skip policies or checks.
