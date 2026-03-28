# Sub-system: Crafting
**Mechanic**: [Interactive Object System](../../interactive_objects.md)
**Status**: DRAFT

## 1. Functional Role
Allows the combination of inventory items into new artifacts or equipment upgrades.

## 2. Implementation Logic
- **Recipe Engine**: Validates the presence of `input` items in the player's inventory against the `object.yaml` recipe list.
- **Timed Execution**: If `time > 0`, the object enters a "Processing" state (FSM interaction) before yielding the `output`.

## 3. Data Dependency
- `object.yaml`: `crafting.recipes`, `crafting.station_type`.
- `InventorySystem`: Source of inputs and destination for outputs.
