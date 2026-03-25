# CONVENTIONS.md
Coding conventions and guidance for AI coding agents working in this repository.

## 1. General Expectations
- Make small, incremental, and well‑scoped changes.
- Follow existing architecture, coding style, naming, and file structure.
- When unsure about a convention, inspect nearby code and adopt the most common pattern.
- Keep diffs minimal, focused, and easy to review.

## 2. Project Navigation
When deciding where to implement changes:
- Search the repository for relevant functionality or naming matches.
- Explore surrounding files to understand patterns and structure.
- Place new files near similar functionality unless a clear alternative exists.

## 3. Quality & Consistency
- Match existing formatting conventions (indentation, naming, file layout).
- Follow established patterns for function design, error handling, and structure.
- Add or update tests whenever functionality is added or changed.
- Respect and reuse existing utilities rather than duplicating functionality.

## 4. Dependencies & Environment
- Reuse existing dependencies whenever possible.
- Only introduce new dependencies when absolutely necessary and justified.
- Follow the project's established build or run processes by reviewing existing configuration files and scripts.

## 5. Documentation Requirements
- **Always update relevant documentation** when making changes.
  - Update `README.md` to reflect new features, changed commands, or modified behavior.
  - Update other documentation files (architecture docs, setup guides, API docs, etc.) when they become outdated.
  - Documentation must remain accurate and aligned with the codebase.

## 6. Safety & Boundaries
Avoid:
- Modifying environment variables, credentials, deployment config, or sensitive files.
- Changing unrelated areas of the codebase.
- Large refactors unless explicitly instructed.

## 7. Planning Before Coding
- Begin by summarizing your understanding of the relevant parts of the codebase.
- Outline a clear plan describing which files will change and why.
- Keep plans concise and focused on the requested work.

## 8. Generating Code
- Prefer clarity over cleverness.
- Maintain consistent structure with existing code.
- Add tests where applicable.
- Generally avoid using comments in code but do document non‑obvious decisions or code with comments if helpful.

## 9. Handling Uncertainty
If the request is ambiguous or multiple solutions are possible:
- Ask clarifying questions.
- Propose options with reasoning.
- Choose the approach that best matches project conventions when guidance is limited.
