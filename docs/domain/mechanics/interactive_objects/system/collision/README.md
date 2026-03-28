# Sub-system: Collision (Object-Level)
**Mechanic**: [Interactive Object System](../../interactive_objects.md)
**Status**: DRAFT

## 1. Functional Role
Determines if an object occupies space in the world that can block the player or be affected by physical impulses.

## 2. Implementation Logic
- **Blocking**: Toggles the AABB "solid" flag for the entity's footprint. **Defaults to `true`** if not specified in `object.yaml`.
- **Pushing**: If `pushable: true`, the player's movement vector is transferred to the object's `velocity` during contact, modified by `mass`.

## 3. Data Dependency
- `object.yaml`: `physics.blocking`, `physics.pushable`.
- `PhysicsSystem`: Handles the impulse math.
