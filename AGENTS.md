# AGENTS.md - Repo-Wide Agent Guidelines

Scope: Entire repository (rooted here). All agents working in this repo should read and apply these rules first.

## Language
- Default to English for all messages and outputs.
- Do not switch languages unless the user explicitly asks.
- If the user writes in another language, politely confirm but continue in English unless they insist.

## Tone & Style
- Concise, direct, and friendly. Prioritize actionable guidance.
- Default to plain text; avoid heavy formatting unless requested. Bullets are fine.
- Wrap commands, file paths, env vars, and code identifiers in backticks.

## Plans & Preambles
- Use the plan tool for multi-step or ambiguous tasks; keep steps short.
- Before grouped tool calls, send a brief preamble (1-2 sentences) explaining what you are about to do.

## Interaction Policy
- Explain first, then act: summarize intended changes and wait for approval before making non-trivial edits.
- Once a plan is approved, proceed through the agreed steps without pausing for every micro-step, especially during implement phases.
- Batch writes to reduce approvals: group related file additions/renames/edits in a single patch when possible.

### Step Handoff (MUST)
- Do not auto-advance between workflow steps. After completing a step, stop and suggest the next slash command; proceed only when the user runs it.
- Do not ask to proceed (e.g., "devam et"); instead, present the next command explicitly.

### Network Policy (Scope Clarification)
- "Local-only" refers to mode switching (MCA<->ORG) not requiring external access.
- Network use is allowed when approved by the session/user; do not assume global offline.

## Files & Edits
- Be surgical: only touch what is necessary. Match existing style.
- Prefer minimal diffs; avoid renames unless required.
- Do not add license headers or commit changes unless the user asks.

## Git-Ignored and Scratch Areas
- Do not modify, delete, or write files under git-ignored or scratch directories (for example, `zzz/`, `.codex/`) unless the user explicitly instructs you for the current task.
- Do not read or rely on content from such directories to drive implementation decisions unless the user references a specific path (e.g., "use `zzz/abc.md` to do X").
- Treat these directories as out-of-scope for project development by default.

## Source vs Dist
- Do not edit `dist/` directly when authoring new changes. Use `src/` for edits, then promote changes to `dist/` with the repository's promotion workflow/scripts.
- Keep flavors under `dist/<flavor>` minimal and shippable; avoid dev helpers and runtime state there.

## Shell & Reading
- Prefer `rg` for search; chunk file reads to <= 250 lines.
- Keep network calls off unless approved by the user/session policy.

## Repo Conventions
- Enforce provenance and character hygiene where applicable (see `.specify/scripts`).
- If adding docs, ensure they pass the hygiene script (`.specify/scripts/character_hygiene.ps1 -Fix`).

## When In Doubt
- Ask one concise clarifying question, then proceed with the smallest viable step.

## UTF-8 Output (Non-ASCII Safe)
- When quoting file contents that may include non-ASCII characters (e.g., Turkish ç, ğ, ı, İ, ş, ö, ü), ensure the shell prints in UTF-8 first. In PowerShell:
  - `chcp 65001`
  - `[Console]::InputEncoding  = [System.Text.Encoding]::UTF8`
  - `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8`
  - `$OutputEncoding           = [System.Text.Encoding]::UTF8`
  - Then read with: `Get-Content -Raw -Encoding UTF8 <path>` (print in ≤200-line chunks).
- If the environment still garbles output, quote only the necessary snippet in the assistant message (not via a tool call), and include the file path. Prefer summaries over full dumps when practical.
- Avoid ASCII-escape blocks by default; they are harder to read. Use them only if the channel cannot render UTF-8 at all and the user requests it.

## Instruction Files
- When the user says "continue from <file>", always re-read that file before acting. Treat the referenced file as the current source of truth and do not repeat already-completed actions.
- Display the file back to the user before acting:
  - First, print it in UTF-8 from the shell (set UTF-8 encodings; chunk to avoid truncation; read with `-Encoding UTF8`).
  - If the tool output truncates or garbles, paste the full file content directly in the assistant message (not via the tool), bounded by BEGIN/END markers, and include path, size, and SHA-256. Preserve the original language in the quote.






## Instruction Files
- When the user says "continue from <file>", always re-read that file before acting.
- Do not assume prior content; treat the referenced file as the current source of truth and avoid repeating already-completed actions.

