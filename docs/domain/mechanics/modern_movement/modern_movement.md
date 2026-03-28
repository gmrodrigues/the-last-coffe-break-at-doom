# Mechanic Specification: Modern FPS Movement
**Requisition ID**: RRA-018
**Status**: APPROVED
**Owner**: Antigravity (Lead Architect)

## 1. Functional Description
Replaces traditional tank controls with modern WASD standard. The player rotates horizontally using mouse movement and moves sideways (strafing) using A and D keys. This alignment is necessary for increasing the "Operational Efficiency" of the Slayer.

## 2. Input & Trigger
- **Source**: Keyboard (WASD), Mouse (X-Axis)
- **Condition**: Continuous polling during game loop.

## 3. Logical Constraints (Vibe Check)
- **Constraint 1**: Horizontal rotation only (2.5D constraint).
- **Constraint 2**: Movement speed fixed at 0.05 units/frame.
- **Constraint 3**: Mouse cursor locked in "Relative Mode" for zero-drift navigation.

## 4. Technical Implementation (DOD)
- **Primary Components**: `renderer.Camera` (`dir_x`, `dir_y`, `plane_x`, `plane_y`).
- **System**: Handled within the `main` game loop under the Input Polling stage.
- **Sub-systems**:
  - [Input Processing](system/input_processing/input_processing.md): Mouse and keyboard translation.
- **Complexity**: O(1) per frame update.

## 5. Asset & Directory Structure
This mechanic governs the player's spatial awareness and movement visuals:
- **Viewmodel Assets**: `assets/game/objects/weapon/`
  - `icon.qoi`: 16x16 icon for HUD representation.
  - `flash.qoi`: Muzzle flash overlay.
- **Calibration**: All rotation logic references the horizontal plane defined in `src/main.zig`.
- **Standards**: Must comply with [Asset Organization Standards](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/architecture/asset_organization_standards.md).

## 6. Satirical Corporate Note
"The Board believes that permitting the Slayer to look around freely reduces his fixation on the mission clock. However, we've conceded to this upgrade as it theoretically improves the speed of coffee-break transitions by 14%."
