---
name: doom_editor_ui_standards
description: Universal UI/UX standards for all internal editors and helper tools in the TLC_at_DOOM project.
---

# Doom Editor UI Standards

This skill enforces visual consistency and component architecture across ALL internal tools (Voxel Forge, Dialogue Editors, Map Editors, etc.). The rules are derived from the Voxel Forge V3 baseline.

## Universal Selection & Feedback Standards

- **Element Selection**: Active elements (colors, files, nodes) MUST be highlighted with a **White border** (1px) or **Cyan border** (1px) depending on context.
- **Active State Highlights**: Use Cyan (0x00FFFFFF) for primary viewport/spatial selections. Use White (0xFFFFFFFF) for tool/palette selections.
- **Translucency Rules**: Use **translucency** (25% to 50%) for "ghosting" or "background" elements to maintain spatial awareness without clutter.

## Standard Editor Layout (The 4-Quadrant Baseline)

All editors should strive for a 4-quadrant architecture where applicable:
1. **Utility Strip (Top)**: Buttons for atomic tools and global settings.
2. **Primary Viewport (Left)**: The main visualization area (3D, Graph, or Preview).
3. **Workspace/Editor (Right)**: The precision editing grid or attribute panel.
4. **Contextual HUD (Bottom)**: Horizontal strips for status, timelines, or quick-swaps.

## Component Documentation Requirement

Whenever a new UI element is proposed, Antigravity MUST:
- Check the `component_catalog.md` in this skill's `resources/` for existing patterns.
- Ensure the new component follows the indexed-color palette restricted to **7 active colors**.
- Use the **Shadowless Pass** rule for all 2D UI elements.

## Rule: Force Reutilization
Antigravity MUST reject ad-hoc UI implementations that do not use the established "Layer Row", "Slicing Slider", or "Directional Tile" patterns documented in the catalog.
