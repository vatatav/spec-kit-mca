---
description: Generate an actionable, dependency-ordered tasks.md for the feature based on available design artifacts.
---

### Input Acquisition Protocol (IAP)
# This protocol defines how user input is acquired, supporting multiple agent systems.
# The final, consolidated input is referred to as the 'Primary Input' in subsequent steps.

# Step 1: File-Based Input
# You will attempt to read a dedicated file for this command from a relative path.
# The file for the /tasks command is 'user_prompts/mc06-tasks-user.md'.
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

1. Run `.specify/scripts/powershell/check-prerequisites.ps1 -Json` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute.
2. Load and analyze available design documents:
   - Always read plan.md for tech stack and libraries
   - IF EXISTS: Read data-model.md for entities
   - IF EXISTS: Read contracts/ for API endpoints
   - IF EXISTS: Read research.md for technical decisions
   - IF EXISTS: Read quickstart.md for test scenarios

   Note: Not all projects have all documents. For example:
   - CLI tools might not have contracts/
   - Simple libraries might not need data-model.md
   - Generate tasks based on what's available

3. Generate tasks following the template:
   - Use `.specify/templates/tasks-template.md` as the base
   - Replace example tasks with actual tasks based on:
     * **Setup tasks**: Project init, dependencies, linting
     * **Test tasks [P]**: One per contract, one per integration scenario
     * **Core tasks**: One per entity, service, CLI command, endpoint
     * **Integration tasks**: DB connections, middleware, logging
     * **Polish tasks [P]**: Unit tests, performance, docs

4. Task generation rules:
   - Each contract file → contract test task marked [P]
   - Each entity in data-model → model creation task marked [P]
   - Each endpoint → implementation task (not parallel if shared files)
   - Each user story → integration test marked [P]
   - Different files = can be parallel [P]
   - Same file = sequential (no [P])

5. Order tasks by dependencies:
   - Setup before everything
   - Tests before implementation (TDD)
   - Models before services
   - Services before endpoints
   - Core before integration
   - Everything before polish

6. Include parallel execution examples:
   - Group [P] tasks that can run together
   - Show actual Task agent commands

7. Create FEATURE_DIR/tasks.md with:
   - Correct feature name from implementation plan
   - Numbered tasks (T001, T002, etc.)
   - Clear file paths for each task
   - Dependency notes
   - Parallel execution guidance

Context for task generation: $ARGUMENTS

The tasks.md should be immediately executable - each task must be specific enough that an LLM can complete it without additional context.
## Handoff
- Stop after completing this step; do not auto-start the next.
- Suggest the next command and wait for the user to run it.
- Proceed only when the user runs the explicit slash command.

## Network Policy
- "Local-only" applies to mode switching (MCA<->ORG); no external access is required for switching.
- Network use is allowed when approved by the session/user.
- Always read local docs; do not use "no-network" to skip policies or checks.
