# Collision Bridge Mapping
**Source**: `src/physics.zig`

## 1. Structs
- `Collider`: AABB data structure.
- `CollisionPair`: Temporary storage for overlap tests.

## 2. Systems
- `Resolver`: The central loop that iterates over active colliders and resolves contacts against the `renderer.Map` and other `Collider` components.
