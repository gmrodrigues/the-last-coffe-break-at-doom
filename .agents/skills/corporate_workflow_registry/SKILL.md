---
name: corporate_workflow_registry
description: Specialized skill for documentation standards, feature requisitions (RRA), and architectural drift analysis.
---

# Corporate Workflow Registry

This skill manages the project's documentation standards and the process for requesting new features (Requisitions).

## Documentation Hierarchy & Directory Structure

All technical assets must be organized in the following absolute paths:
- **Core Architecture**: `Tech.md`. Contains SoA/DOD, memory management, and binary formats.
- **Ubiquitous Language**: `docs/domain/ubiquitous_language.md`.
- **Entities**: `docs/domain/entities.md`. Definition of all in-game objects and their SoA structure.
- **Components**: `docs/architecture/components.md`.
- **Design Principles**: `docs/architecture/principles.md`.
- **Project Backlog**: `docs/architecture/backlog.md`. Tracks sprint progress, pending features, and next steps.
- **Task State**: `task.md` (in brain). Tracks the current execution checklist.
- **Delivery Summary**: `walkthrough.md`. Proof of work for every Sprint/Task.

## Feature Requisition Process (The Workflow)

When the USER requests a new feature, Antigravity MUST:
1. **Draft a Requisition**: Use the `requisition_form.md` template.
2. **Include PlantUML Views**: Every proposal MUST include at least one relevant diagram (C4, Sequence, User Journey, etc.).
3. **Draft Stakeholder Commentaries**: Generate brief, satirical reactions from the "Corporate Board" (Architect to HR).
4. **Update Tech Docs**: If approved, update the relevant files in `docs/domain/` or `docs/architecture/`.

## Cyclical Architectural Analysis

At the end of every implementation cycle, Antigravity MUST perform a **Drift Analysis**:
- **Fragmentation**: Check for duplicated logic or ad-hoc memory management.
- **Vibe Drift**: Check if any "modernisms" have leaked into the 2.5D renderer.
- **Backlog Reconciliation**: Move completed items to the "Audit Trail" and update pending requisition priorities in `docs/architecture/backlog.md`.
- **Compliance**: Review against `docs/architecture/principles.md`.

## Rule: PlantUML Mandatory & Local Rendering

Requisitions without an architectural view will be REJECTED. Antigravity MUST:
1. **Author**: Write the PlantUML source in a `.puml` file within the feature's documentation directory.
2. **Render**: Run the local `plantuml` command to generate a PNG:
   `plantuml -tpng path/to/diagram.puml`
3. **Embed**: Link the resulting PNG in the markdown document (e.g., `![Architecture Diagram](path/to/diagram.png)`).
4. **Clean up**: Keep the source `.puml` for future edits and ensure it is versioned in `docs/architecture/`.

Supported types: C4, Sequence, User Case, User Journey, Mind Map, Component, Class, Deploy, State Machine.

## Rule: Backlog Maintenance
Antigravity MUST maintain `docs/architecture/backlog.md`. Every new RRA must be added to the "Pending Requisitions" section. At the end of every task/sprint, Antigravity MUST move cards to "Completed (Current Sprint)" or "Next Steps".

## Rule: No Modern Task Management
Avoid using modern agile terms like "User Stories" or "Story Points". Use "Sprint", "Requisition", "Resource Allocation", and "Managerial Review".
