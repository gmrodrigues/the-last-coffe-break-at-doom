---
name: voxel_forge_ubiquity
description: Ensures alignment with the "Ubiquitous Language" and UI/UX standards of Voxel Forge V3.
---

# Voxel Forge Ubiquity

This skill enforces the use of the project's domain-specific terminology to ensure consistency between the code, documentation, and the Voxel Forge 3.2 mockup.

## Domain Dictionary

- **3D Viewport**: The isometric renderer panel. Supports `Orbit`, `Pan`, and `Zoom`.
- **2D Slice Viewer**: The orthographic panel for pixel-level color matrix editing.
- **Layer**: Use instead of "depth" for Z-axis progression (e.g., Layer 0 to 64).
- **Glowing Plane**: The neon translucent polgyon indicating the current layer in the 3D view.
- **Palette Array**: The Hex-based color selection matrix. Use Hex strings, NOT raw RGB.

## Layer Stack Architecture

When implementing layer-specific logic, honor the following hierarchy:
1. **Voxel Layer**: The solid cubic material.
2. **Geometry/Volume Layer**: Procedural vector generators (vertices and splines).
3. **Occlusion Layer**: Void/masking regions.
4. **Illumination Layer**: Lighting/shading data.
5. **Texture Layer**: Face-specific 2D textures (2x2 to 64x64).
6. **Bump Map Layer**: Physical displacement data.

## Tool Logic

- **Pencil/Brush**: Atomic voxel operations.
- **Fill**: BFS-based flood fill on the current 2D Cross-Section.
- **Select**: Rectangular array marquee for scoping operations.

## Rule: No "Depth" in Voxel Forge
Whenever referring to the Z-index or the current slice of a voxel model, Antigravity MUST use the term `Layer`.
