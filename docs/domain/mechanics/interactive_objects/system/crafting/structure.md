# Crafting Mapping
**Source**: `src/crafting.zig`

## 1. Structs
- `Recipe`: Input-outcome data structure.
- `CraftingStation`: Tracks current progress and timers.

## 2. Systems
- `CraftingProcessor`: Progresses items through the production lifecycle.
- `YieldSystem`: Finalizes output and updates inventory.
