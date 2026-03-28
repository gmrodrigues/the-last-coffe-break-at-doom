# Input Processing Mapping
**Source**: `src/main.zig`

## 1. Structs
- `renderer.Camera`: `pos_x`, `pos_y`, `dir_x`, `dir_y`, `plane_x`, `plane_y`.

## 2. Systems
- `InputPollSystem`: Captures SDL2 events and updates camera vectors.

## 3. Options
- `mouse_sensitivity`: Float scaling for rotation.
- `move_speed`: Float scaling for translation.
