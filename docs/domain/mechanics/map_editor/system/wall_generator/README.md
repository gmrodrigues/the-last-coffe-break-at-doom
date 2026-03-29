# Sub-system: Wall Generator
**Mechanic**: [Map Editor](../../map_editor.md)
**Status**: DRAFT

## 1. Functional Role
Procedurally generates 3D wall meshes from 2D vertices defined in an `Area` boundary.

## 2. Implementation Logic
- **Extrusion**: Takes two vertices `(A, B)` and creates a polygon with the defined `height`.
- **Thickening**: Generates inner and outer faces based on the `thickness` property, creating a volumetric wall instead of a flat plane.
- **Normal Alignment**: Automatically computes normals for correct shading in the 2.5D renderer.

## 3. Data Dependency
- `Area.boundary`: Source vertices.
- `Wall.properties`: Thickness and height.
