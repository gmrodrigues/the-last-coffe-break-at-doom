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
- **Mechanics**: `docs/domain/mechanics/`. Specification documents for all game-feel features.
- **Editor Features**: `docs/editors/features/`. Workflow and specifications for internal tool enhancements.
- **Components**: `docs/architecture/components.md`.
- **Design Principles**: `docs/architecture/principles.md`.
- **Project Backlog**: `docs/architecture/backlog.md`. Tracks sprint progress and IDs.
- **Implementation Reports**: `docs/reports/YYYY/MM/`. Standardized review documents generated before execution.
- **Task State**: `task.md` (in brain). Tracks the current execution checklist.
- **Delivery Summary**: `walkthrough.md`. Proof of work for every Sprint/Task.

## Feature Requisition Process (The Workflow)

When the USER requests a new feature, Antigravity MUST:
1. **Draft a Requisition**: Use the `requisition_form.md` template. Assign a unique ID (e.g., **RRA-015**).
2. **Include PlantUML Views**: Every proposal MUST include at least one relevant diagram (C4, Sequence, User Journey, etc.). All docs must reference the compiled image of the diagram.
3. **Draft Stakeholder Commentaries**: Generate brief, satirical reactions from the "Corporate Board" (Architect to HR).
4. **Generate Implementation Report**: Before starting code changes, generate a report in `docs/reports/` using the format `YYYY-MM-DD_HHMM_[brief_description].md`.
5. **Update Tech Docs**: If approved, update the relevant files in `docs/domain/` or `docs/architecture/`.

## Cyclical Architectural Analysis

At the end of every implementation cycle, Antigravity MUST perform a **Drift Analysis**:
- **Fragmentation**: Check for duplicated logic or ad-hoc memory management.
- **Vibe Drift**: Check if any "modernisms" have leaked into the 2.5D renderer.
- **Backlog Reconciliation**: Move completed items to the "Audit Trail" and update pending requisition priorities in `docs/architecture/backlog.md`.
- **Compliance**: Review against `docs/architecture/principles.md`.
- **Technical Debt Logging**: Any structural 'hacks' or implementation fragments discovered MUST be filed into the Technical Debt Backlog (`docs/architecture/technical_debt.md`).

## Rule: Engine vs Editor Separation Philosophy
- **The Game Engine**: MUST remain a STRICT SDL2 Raycasting solution. It is bound by the retro limitations of the 2.5D format.
- **The internal Editors (Map Forge, Voxel Forge, etc.)**: MUST use **Raylib + Nuklear**. This allows the editors to bypass the rendering limitations of the raycaster (enabling full 3D viewport flexibility, high-performance UI) while generating an interchangeable game data format that the strict SDL raycasting engine can load and execute natively.

## Rule: Technical Debt Governance
Antigravity MUST actively track and document technical debt in `docs/architecture/technical_debt.md`. When encountering non-compliant implementations (e.g., bare SDL code instead of Nuklear ZUI standards), Antigravity MUST file a `TD-###` card to the Active Tech Debt register to maintain architectural transparency. **Mandatory:** Every Technical Debt card MUST include a direct link to the specific Stakeholder Memorandum (Coffee Presentation) or architectural discussion that initiated or discovered the debt.

## Rule: PlantUML Mandatory & Local Rendering

Requisitions without an architectural view will be REJECTED. Antigravity MUST:
1. **Author**: Write the PlantUML source in a `.puml` file within the feature's documentation directory.
2. **Render**: Run the local `plantuml` command to generate a PNG:
   `plantuml -tpng path/to/diagram.puml`
3. **Embed**: Link the resulting PNG in the markdown document (e.g., `![Architecture Diagram](path/to/diagram.png)`).
4. **Clean up**: Keep the source `.puml` for future edits and ensure it is versioned in `docs/architecture/`.

Supported types: C4, Sequence, User Case, User Journey, Mind Map, Component, Class, Deploy, State Machine.

## Rule: Backlog Maintenance
Antigravity MUST maintain `docs/architecture/backlog.md`. Every new RRA must be assigned a unique sequential ID and added to the "Pending Requisitions" section. At the end of every task/sprint, Antigravity MUST move cards to "Completed (Current Sprint)" or "Next Steps". **Mandatory:** Every item added to the backlog MUST reference or link to the specific Stakeholder Memorandum or source discussion that initiated it.

Every RRA implementation MUST be preceded by a report in `docs/reports/YYYY/MM/`. The report MUST include:
- Technical approach (DOD/Memory impact).
- Review of potential architectural drift.
- Step-by-step implementation plan.
Naming convention: `YYYY-MM-DD_HHMM_description.md`.

## Rule: Periodic Directory Audit
Antigravity MUST periodically (at least once per cycle) audit the directory structure documented in all active skills. If a skill's tree standard in its `SKILL.md` becomes inconsistent with the actual repository state or requires new hierarchical layers (e.g. chronological archiving), Antigravity MUST immediately propose a refactor and update the skill.

## Rule: No Modern Task Management
Avoid using modern agile terms like "User Stories" or "Story Points". Use "Sprint", "Requisition", "Resource Allocation", and "Managerial Review".

## Rule: The Corporate Memorandum (Coffee Presentation)
When a major architectural paradigm shift occurs, Antigravity MUST file a Corporate Memorandum.
- **Format**: Memorandums MUST take the narrative form of a "Coffee Presentation" transcript or watercooler gossip session.
- **Content**: Must include the technical details wrapped in corporate satire, featuring direct quotes, complaints, and gossipy feedback from key stakeholders (e.g., The Architect, The Junior Dev, Corporate HR, The Vibe Curator, The Retro Computing Purist). It must be funny and insightful.
- **Location**: Store inside `docs/reports/YYYY/MM/` with the prefix `YYYY-MM-DD_HHMM_MEMO_`.
