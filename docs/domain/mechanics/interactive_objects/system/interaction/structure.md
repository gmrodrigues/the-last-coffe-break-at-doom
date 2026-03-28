# Interaction Mapping
**Source**: `src/entities.zig`, `src/main.zig`

## 1. Structs
- `ObjectState`: Tracks lifecycle and available actions.
- `InteractEvent`: Signal generated when player triggers an object.

## 2. Functions
- `InteractSystem.update()`: Scans proximity and triggers logic based on `object.yaml` actions.

## 3. Systems
- `InteractionResolver`: Executes the specific action logic (e.g., Power Cycle).
