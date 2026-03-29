# Sub-system: Collision Bridge
**Mechanic**: [Core Physics](../../core_physics.md)
**Status**: DRAFT

## 1. Functional Role
The primary bridge that unifies World DDA (raycasting) and Entity AABB collision. Ensures a single point of truth for "solidity" in the world.

## 2. Implementation Logic
- **Unified Query**: Performs a world grid check using `Map.get()` and then an entity query using the `SpatialPartitionSystem`.
- **Precedence**: Static world geometry always blocks. Entity blocking is conditional on the `ColliderComponent.blocking` flag.

## 3. Data Dependency
- `renderer.Map`: Static data.
- `ColliderComponent`: Dynamic entity data.
