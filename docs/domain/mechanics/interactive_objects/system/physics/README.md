# Sub-system: Physics System
**Mechanic**: [Interactive Object System](../../interactive_objects.md)
**Status**: DRAFT

## 1. Functional Role
Applies physical constraints to game objects, handling mass, friction, and movement during interaction.

## 2. Implementation Logic
- **SoA Components**: `ObjectPhysics` array.
- **Constraints**: Integrates velocity based on `mass` and `friction` coefficients defined in `object.yaml`.

## 3. Data Dependency
- `ObjectPhysics`: `mass`, `friction`, `velocity`.
- `Collision`: Respects the global AABB sliding rules.
