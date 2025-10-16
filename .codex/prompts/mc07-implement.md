---
description: Execute the implementation plan by processing and executing all tasks defined in tasks.md
---

### Input Acquisition Protocol (IAP)
# This protocol defines how user input is acquired, supporting multiple agent systems.
# The final, consolidated input is referred to as the 'Primary Input' in subsequent steps.

# Step 1: File-Based Input
# You will attempt to read a dedicated file for this command from a relative path.
# The file for the /implement command is 'user_prompts/implement_prompt.md'.
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

Implementation boundaries and feedback loop
- Complete the initial implementation according to `tasks.md` without conversational drift.
- Feedback loop for corrections is capped at 3-5 iterations and MUST address only gaps/misinterpretations.
- Any scope/technology pivot (e.g., switching frameworks, large redesign) MUST route to `/mc09-prep-next-spec` → `/mc02-specify` refresh.
- Do not accept scope changes within `/mc07`; instead, capture them for the prep step.

1. Run `.specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute.

2. Load and analyze the implementation context:
   - **REQUIRED**: Read tasks.md for the complete task list and execution plan
   - **REQUIRED**: Read plan.md for tech stack, architecture, and file structure
   - **IF EXISTS**: Read data-model.md for entities and relationships
   - **IF EXISTS**: Read contracts/ for API specifications and test requirements
   - **IF EXISTS**: Read research.md for technical decisions and constraints
   - **IF EXISTS**: Read quickstart.md for integration scenarios

3. Parse tasks.md structure and extract:
   - **Task phases**: Setup, Tests, Core, Integration, Polish
   - **Task dependencies**: Sequential vs parallel execution rules
   - **Task details**: ID, description, file paths, parallel markers [P]
   - **Execution flow**: Order and dependency requirements

4. Execute implementation following the task plan:
   - **Phase-by-phase execution**: Complete each phase before moving to the next
   - **Respect dependencies**: Run sequential tasks in order, parallel tasks [P] can run together  
   - **Follow TDD approach**: Execute test tasks before their corresponding implementation tasks
   - **File-based coordination**: Tasks affecting the same files must run sequentially
   - **Validation checkpoints**: Verify each phase completion before proceeding

5. Implementation execution rules:
   - **Setup first**: Initialize project structure, dependencies, configuration
   - **Tests before code**: If you need to write tests for contracts, entities, and integration scenarios
   - **Core development**: Implement models, services, CLI commands, endpoints
   - **Integration work**: Database connections, middleware, logging, external services
   - **Polish and validation**: Unit tests, performance optimization, documentation

6. Progress tracking and error handling:
   - Report progress after each completed task
   - Halt execution if any non-parallel task fails
   - For parallel tasks [P], continue with successful tasks, report failed ones
   - Provide clear error messages with context for debugging
   - Suggest next steps if implementation cannot proceed
   - **IMPORTANT** For completed tasks, make sure to mark the task off as [X] in the tasks file.

7. Completion validation:
   - Verify all required tasks are completed
   - Check that implemented features match the original specification
   - Validate that tests pass and coverage meets requirements
   - Confirm the implementation follows the technical plan
   - Report final status with summary of completed work

Note: This command assumes a complete task breakdown exists in tasks.md. If tasks are incomplete or missing, suggest running `/tasks` first to regenerate the task list.

## Handoff
- Stop after completing this step; do not auto-start the next.
- Suggest the next command and wait for the user to run it.
- Proceed only when the user runs the explicit slash command.

## Network Policy
- "Local-only" applies to mode switching (MCA<->ORG); no external access is required for switching.
- Network use is allowed when approved by the session/user.
- Always read local docs; do not use "no-network" to skip policies or checks.
## Boundaries (MUST)
- Feedback iterations are capped at 3–5 for corrections only.
- For scope or technology pivots, stop and route back to mc02-prep-next-spec → mc03-specify instead of extending this step.
