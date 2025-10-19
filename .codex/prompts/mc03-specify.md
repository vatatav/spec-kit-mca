---
description: Create or update the feature specification from a natural language feature description.
---

### Input Acquisition Protocol (IAP)
# This protocol defines how user input is acquired, supporting multiple agent systems.
# The final, consolidated input is referred to as the 'Primary Input' in subsequent steps.

# Step 1: File-Based Input
# You will attempt to read a dedicated file for this command from a relative path.
# The file for the /specify command is 'user_prompts/specify_prompt.md'.
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

The text the user typed after `/specify` in the triggering message **is** the feature description. Assume you always have it available in this conversation even if `$ARGUMENTS` appears literally below. Do not ask the user to repeat it unless they provided an empty command.

Given that feature description, do this:

1. Run the script `.specify/scripts/powershell/create-new-feature.ps1 -Json "$ARGUMENTS"` from repo root and parse its JSON output for BRANCH_NAME and SPEC_FILE. All file paths must be absolute.
  **IMPORTANT** You must only ever run this script once. The JSON is provided in the terminal as output - always refer to it to get the actual content you're looking for.
2. Load `.specify/templates/spec-template.md` to understand required sections.
3. Write the specification to SPEC_FILE using the template structure, replacing placeholders with concrete details derived from the feature description (arguments) while preserving section order and headings.
4. Report completion with branch name, spec file path, and readiness for the next phase.

Note: The script creates and checks out the new branch and initializes the spec file before writing.
## Handoff
- Stop after completing this step; do not auto-start the next.
- Suggest the next command and wait for the user to run it.
- Proceed only when the user runs the explicit slash command.

## Network Policy
- "Local-only" applies to mode switching (MCA<->ORG); no external access is required for switching.
- Network use is allowed when approved by the session/user.
- Always read local docs; do not use "no-network" to skip policies or checks.
