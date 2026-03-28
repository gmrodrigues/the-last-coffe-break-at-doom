---
name: game_mechanics_logic
description: Specialized skill for defining, implementing, and documenting game mechanics using DOD principles and retro-vibe constraints.
---

# Game Mechanics Logic

This skill governs the lifecycle of game mechanics—from conceptual specification to Data-Oriented implementation in Zig.

## Mechanics Documentation Hierarchy

All mechanics MUST be documented in `docs/domain/mechanics/`.
- **Naming**: `mechanic_name.md` (e.g., `player_movement.md`).
- **Template**: Every document MUST use the `mechanics_spec.md` template located in this skill's `templates/` folder.
- **Directory Structure**: `docs/domain/mechanics/[mechanic_name]/`

## Implementation Standards (DOD/Zig)

When implementing mechanics, Antigravity MUST follow these rules from the `rigorous_zig_dod` skill:
1. **SoA Dominance**: Mechanics must operate on Struct-of-Arrays (SoA) data. Avoid "Object-Oriented" entity classes.
2. **System Separation**: Mechanics logic must be implemented in "Systems" that iterate over component arrays.
3. **Stateless Logic**: Aim for pure functions that take slices of component data and return updated values or delta-states.

## Vibe Alignment

Every mechanic MUST be reviewed against the `doom_vibe_curator` standards:
- **Movement**: Enforce 2.5D constraints (no true vertical looking unless specified).
- **Physics**: Use discrete-step "Doom-style" collision detection (AABB).
- **Interaction**: Use ray-casting for world interaction (use `src/ray.zig` standard).

## Rule: Mechanic Requisition
Every new mechanic requires a standard RRA feature requisition. The RRA report MUST link to a completed `mechanic_spec.md` in the `docs/domain/mechanics/` directory.

## Rule: Asset Organization
All assets for a mechanic MUST follow the [Asset Organization Standards](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/architecture/asset_organization_standards.md).
- **Isolation**: Each unique entity must have its own subdirectory (e.g., `assets/objects/server/`).
- **Directional Cohesion**: All 8-directional views (N, NE, E, SE, S, SW, W, NW) must reside in the entity's root folder.
- **Icon standard**: The 16x16 representation of the object must be named `icon.qoi`.

## Rule: Architecture Documentation
All architecture documentation MUST follow the [Architecture Documentation Standards](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/architecture/architecture_documentation_standards.md).
- **Format**: Markdown
- **sub directory**: `docs/domain/mechanics/[mechanic_name]/architecture/`
- **Class Diagram**: All architecture documentation MUST include a PlantUML class diagram.
- **Behavior Diagram**: All architecture documentation MUST include a PlantUML behavior diagram.
- **Sequence Diagram**: All architecture documentation MUST include a PlantUML sequence diagram.
- **Component Diagram**: All architecture documentation MUST include a PlantUML component diagram.
- **State Diagram**: All architecture documentation MUST include a PlantUML state diagram.
- **Activity Diagram**: All architecture documentation MUST include a PlantUML activity diagram.
- **Use Case Diagram**: All architecture documentation MUST include a PlantUML use case diagram.
- **Object Diagram**: All architecture documentation MUST include a PlantUML object diagram.
- **Timing Diagram**: All architecture documentation MUST include a PlantUML timing diagram.
- **Deployment Diagram**: All architecture documentation MUST include a PlantUML deployment diagram.
- **Package Diagram**: All architecture documentation MUST include a PlantUML package diagram.
- **Profile Diagram**: All architecture documentation MUST include a PlantUML profile diagram.
- **Timing Diagram**: All architecture documentation MUST include a PlantUML timing diagram.
- **Deployment Diagram**: All architecture documentation MUST include a PlantUML deployment diagram.
- **Package Diagram**: All architecture documentation MUST include a PlantUML package diagram.
- **Profile Diagram**: All architecture documentation MUST include a PlantUML profile diagram.
- **File Structure**: All architecture documentation MUST include a PlantUML file structure diagram.


## Rule: Backlog Management
All backlog documentation MUST follow the [Backlog Management Standards](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/architecture/backlog.md).
