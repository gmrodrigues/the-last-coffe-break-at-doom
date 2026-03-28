# Implementation Report - RRA-016: Dynamic Tool Metadata
**Date**: 2026-03-28
**Time**: 16:30
**ID**: RRA-016

## 1. Technical Approach
- **Metadata Format**: Use a simplified YAML structure in `assets/tools.yaml`.
  ```yaml
  tools:
    - name: "Voxel Forge"
      icon: "assets/nano_voxel.qoi"
      exec: "./zig-out/bin/tlc_voxel"
  ```
- **Parsing**: Implement a lightweight YAML-like parser in `src/desktop_main.zig` (since a full YAML parser is heavy). It will look for key-value pairs.
- **Asset Pipeline**: Generate 16x16 or 32x32 QOI icons using `generate_image` and the `qoi_asset_factory` skill.

## 2. Architectural Drift Review
- **Vibe**: Dynamic loading reinforces the "OS" simulation. The "Nano Banana" mascot adds to the corporate-weird identity.
- **Memory**: Metadata strings will be allocated into the `Arena` during initialization to avoid fragmentation.

## 3. Implementation Plan
1. **Asset Generation**: Use `generate_image` to create "Nano Banana" versions of our tool icons.
2. **YAML Construction**: Create `assets/tools.yaml`.
3. **Parser Implementation**: Add `loadMetadata` to `DesktopManager`.
4. **Main Update**: Replace hardcoded `addTool` calls with `loadMetadata()`.
