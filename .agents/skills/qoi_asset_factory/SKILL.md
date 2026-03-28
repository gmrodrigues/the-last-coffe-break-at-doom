---
name: qoi_asset_factory
description: Specialized skill for generating 8-direction QOI sprites with YAML metadata and logical tree organization.
---

# QOI Asset Factory

This skill provides a standardized workflow for generating assets compatible with the TLC_at_DOOM engine and Voxel Forge editor.

## 8-Direction Naming Convention

All sprites for directional objects MUST follow this naming scheme:
- `N.qoi` (North)
- `NE.qoi` (North-East)
- `E.qoi` (East)
- `SE.qoi` (South-East)
- `S.qoi` (South)
- `SW.qoi` (South-West)
- `W.qoi` (West)
- `NW.qoi` (North-West)

## Logical Tree Organization

Assets must be organized in a hierarchical folder structure:
`assets/<category>/<object_name>/<animation_name>/`

**Example:**
`assets/enemies/gremlin/walk/`
- `N.qoi`, `NE.qoi`, ... `NW.qoi`
- `metadata.yaml`

## YAML Metadata Schema

Every animation folder MUST contain a `metadata.yaml` file with the following keys:

```yaml
asset_name: "gremlin_walk"
type: "sprite_8dir"
frame_count: 1
frame_duration_ms: 0 # 0 for static
pivot:
  x: 8
  y: 15
collision_box:
  width: 12
  height: 12
flags:
  - "lit"
  - "no_shadow"
```

## Integration with mkqoi.zig

When using `mkqoi.zig` or similar tools, ensure the output path follows the logical tree. If the directory does not exist, create it.

## Rule: Automate YAML Generation
Antigravity MUST use the `gen_metadata.py` script provided in this skill's `scripts/` folder when creating new asset batches to ensure metadata consistency.
