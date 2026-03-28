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
