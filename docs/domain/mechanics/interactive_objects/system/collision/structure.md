# Object Collision Mapping
**Source**: `src/physics.zig`, `src/renderer.zig`

## 1. Structs
- `MapCollider`: Footprint data for object-level blocking.

## 2. Systems
- `CollisionResolver`: Integrates into the main move-resolver to block player passage based on `blocking: true`.

## 3. Options
- `blocking`: Boolean toggle.
- `pushable`: Boolean toggle for impulse response.
