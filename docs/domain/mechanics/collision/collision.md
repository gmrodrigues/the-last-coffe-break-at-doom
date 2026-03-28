# Mechanic Specification: AABB Wall Collision
**Requisition ID**: RRA-019
**Status**: DRAFT
**Owner**: Antigravity (Lead Architect)

## 1. Functional Description
Prevents the player from passing through walls defined in the `renderer.Map`. Implements "sliding collision" where the player can continue moving along a surface even if walking into it at an angle.

## 2. Input & Trigger
- **Source**: `renderer.Camera` position updates.
- **Condition**: Continuous check during the movement polling stage (`W`/`A`/`S`/`D`).

## 3. Logical Constraints (Vibe Check)
- **Constraint 1**: Player has a collision radius of 0.2 units.
- **Constraint 2**: Sliding allowed (X and Y checked independently).
- **Constraint 3**: Map boundaries (outside the defined grid) are treated as solid walls.

## 4. Technical Implementation (DOD)
- **Primary Components**: `renderer.Map`, `renderer.Camera`.
- **System**: Input System in `main.zig`.
- **Sub-systems**:
  - [Map Validation](system/map_validation/map_validation.md): World occupancy queries.
- **Logic**: 
  ```zig
  if (map.get(new_x, old_y) == 0) player.x = new_x;
  if (map.get(old_x, new_y) == 0) player.y = new_y;
  ```
- **Complexity**: O(1) per frame.

## 5. Asset & Directory Structure
This mechanic relies on the world geometry and player representation:
- **World Assets**: `assets/game/env/`
  - `wall.qoi`: Vertical surfaces used for raycasting/collision.
- **Player Icon**: `assets/game/objects/player/icon.qoi` (Metadata and 16x16 map locator).
- **Standards**: Must comply with [Asset Organization Standards](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/architecture/asset_organization_standards.md).

## 6. Satirical Corporate Note
"The Board has noticed an alarming trend of employees attempting to 'phase' through department boundaries to avoid performance reviews. RRA-019 effectively terminates this loophole. Solid walls mean solid productivity."
