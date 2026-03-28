---
name: editor_feature_workflow
description: Specialized skill for managing the lifecycle of features within the TLC_at_DOOM internal editor ecosystem.
---

# Editor Feature Workflow

This skill standardizes the process for adding capabilities to internal tools like Voxel Forge, Content Editor, and the Desktop Simulator.

## Editor Feature Documentation Hierarchy

Every editor feature MUST reside in its own dedicated directory:
`docs/editors/features/<editor_name>/<feature_name>/`

**Required Files per Feature:**
- `spec.md`: Detailed functional and UI specification (use `spec.md` template).
- `backlog.md`: Feature-specific task tracking and milestones.
- `discussions.md`: Design debates, stakeholder feedback, and UX reviews.
- `poc_notes.md`: Documentation of editor playgrounds and prototype results.

## The Playground Mandate

NO editor feature may be integrated into the tool's main codebase without a validated **Editor Playground**:
1. **Isolated Module**: Develop the feature as a decoupled component or separate Zig test.
2. **Visual Validation**: The playground must demonstrate the UI interaction and data persistence.
3. **UI Standard Compliance**: Must be reviewed against `doom_editor_ui_standards` before integration.

## Rule: Board Approval
Every editor feature requisition (RRA) REQUIRES a stakeholder commentary from both the "CEO" (Vision) and "UX Lead" (Usability).
