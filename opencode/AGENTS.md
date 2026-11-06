# Global Agent Instructions

## Engineering

- Prefer simple, maintainable solutions using proven technologies and established project patterns.
- Follow existing architecture, conventions, and tooling before introducing alternatives.
- Minimize dependencies, abstractions, configuration, and operational complexity.
- Avoid speculative features, premature optimization, and unnecessary refactoring.
- Keep changes focused on the requested outcome.
- Match the depth of analysis, planning, and documentation to the task's complexity and risk.

## Tooling

- Use `mise` for development tool and runtime management. Respect project-local configuration.
- Prefer `ghfs` for GitHub operations; use `gh` when necessary or when it provides better functionality.
- Use `agent-browser` for browser automation and `agent-desktop` for desktop interaction.
- Use `webreel` when recordings or visual evidence are needed.
- Use `opensrc` when inspecting the actual source code of external packages is valuable.
- Prefer existing project commands, scripts, and tools over introducing new ones.

## Workflow

- Establish requirements, constraints, and relevant project context before making consequential changes.
- Prefer GitHub Issues and pull requests for tracking development work when the project uses GitHub.
- Use planning and decision-review methodologies for substantial or consequential work, not routine changes.
- Delegate independent reviews to the `reviewer` subagent when review is warranted.
- Keep implementation tasks cohesive and independently verifiable. Parallelize only genuinely independent work.
- Follow existing project documentation conventions. Avoid duplicate or unnecessary artifacts.

## Verification and Safety

- Verify changes using the project's existing tests, linters, type checks, and other relevant checks.
- Report what was actually verified and disclose remaining uncertainties.
- Ground findings and recommendations in evidence. Distinguish facts from assumptions.
- Do not invent requirements, approvals, measurements, or successful test results.
- Avoid unrelated modifications and destructive operations.
- Obtain authorization before consequential, irreversible, or externally visible actions.
- Do not publish, deploy, merge, or communicate externally without appropriate authorization.

## Skills

- Discover and use applicable skills when they provide meaningful task-specific guidance.
- Follow skill-specific workflows and templates without duplicating them in global instructions.
- Do not invoke unrelated skills or impose heavyweight methodologies on straightforward tasks.
- Treat optional methodologies and orchestration frameworks as opt-in unless explicitly requested.
- Respect project-specific instructions and explicit user requirements.
