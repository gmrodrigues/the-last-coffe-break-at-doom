# Map Validation Mapping
**Source**: `src/renderer.zig`

## 1. Structs
- `Map`: The primary world occupancy grid.
  - `data: []u8`
  - `width: usize`
  - `height: usize`

## 2. Functions
- `Map.get(x: f32, y: f32) -> u8`: Converts float world coords to grid indices and returns the tile value.

## 3. Systems
- `CollisionResolver`: Logical unit in `main.zig` that calls `Map.get` to update camera position.
