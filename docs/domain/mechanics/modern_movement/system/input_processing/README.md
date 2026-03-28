# Sub-system: Input Processing
**Mechanic**: [Modern FPS Movement](../../modern_movement.md)
**Status**: DRAFT

## 1. Functional Role
Translates raw hardware inputs (SDL2 events) into camera rotation and vector movement.

## 2. Implementation Logic
- **Mouse Input**: Accumulates relative X-offset per frame to rotate the `dir` and `plane` vectors.
- **Keyboard Input**: Maps WASD to strafe/move vectors relative to the camera's orientation.

## 3. Data Dependency
- `renderer.Camera`: Primary data receiver.
- `SDL2_Event`: Input source.
