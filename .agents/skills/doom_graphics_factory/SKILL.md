---
name: doom_graphics_factory
description: Rules for color palettes, lighting, and sprite fidelity in the 2.5D retro engine.
---

# Doom Graphics Factory

This skill governs the visual excellence of TLC_at_DOOM, ensuring every pixel feels like 1992-Premium.

## Visual Constraints (90s Fidelity)

- **Palette**: Use the "Corporate Cyan & Blood Red" restricted 256-color palette.
- **Scaling**: All sprites must support integer retro-scaling (1x, 2x, 3x) without blurring.
- **Lighting**: Enforce the "Sectored Lighting" rule—no smooth gradients; use discrete steps of intensity (0-15).

## Asset Production Pipeline

All graphics MUST pass through the following audit:
1. **Source**: Author in high-res or 16-bit pixel art.
2. **Quantization**: Reduce to the project-standard palette.
3. **Conversion**: Use `mkqoi` or `AssetProxy` to target the `.qoi` engine-native format.

## Rule: Visual Review
Every graphics Batch requires a **Vibe Audit** in the RRA report, citing compliance with the `doom_vibe_curator` skill.
