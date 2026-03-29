# Sub-system: Intersection Resolver
**Mechanic**: [Map Editor](../../map_editor.md)
**Status**: DRAFT

## 1. Functional Role
Determines the visibility and physical linkage between two distinct `Area` nodes.

## 2. Implementation Logic
- **Portal Clipping**: Uses the Shared Boundary (Portal) to clip the renderer, ensuring only the contents of the connected area are rendered through the "window."
- **Seamless Transition**: When an entity crosses the shared edge, its ownership is transferred between Area arrays.

## 3. Data Dependency
- `Intersection.From/To`: Source and target nodes.
- `PortalMesh`: Geometry for the clipping window.
