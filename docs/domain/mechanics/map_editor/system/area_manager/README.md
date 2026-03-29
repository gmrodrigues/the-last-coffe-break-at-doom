# Sub-system: Area Manager
**Mechanic**: [Map Editor](../../map_editor.md)
**Status**: DRAFT

## 1. Functional Role
Manages the lifecycle, selection, and spatial organization of `Area` nodes within a `Region`.

## 2. Implementation Logic
- **Canvas Container**: Each area is treated as a self-contained canvas for inner boundaries and objects.
- **Variable Injection**: Injects region-level or area-level variables (e.g., `$wall_height`) into the properties of walls and floors.

## 3. Data Dependency
- `Region.areas`: Parent-child linkage.
- `VariableTable`: For dynamic property resolution.
