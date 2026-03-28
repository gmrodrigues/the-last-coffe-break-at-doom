# Sub-system: Map Validation
**Mechanic**: [AABB Wall Collision](../../collision.md)
**Status**: DRAFT

## 1. Functional Role
Responsible for querying the static world occupancy grid (`renderer.Map`) to determine if a target spatial coordinate is navigable.

## 2. Implementation Logic
- **Input**: `(x, y)` world coordinates.
- **Source**: `src/renderer.zig` -> `Map.get(x, y)`.
- **Sliding Behavior**: Validates X and Y axes independently to allow grazing against surfaces.

## 3. Data Dependency
- `renderer.Map`: 2D Uint8 array.
- `0`: Walkable.
- `>0`: Solid wall.
