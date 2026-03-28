---
name: doom_vibe_curator
description: Guardian of the 90s FPS aesthetic; enforces 2.5D constraints, pixel-art fidelity, and retro-scaling.
---

# Doom Vibe Curator

This skill ensures that all technical and creative decisions align with the "Classic Doom" vibe of *The Last Coffee Break at D.O.O.M.*

## The 2.5D Golden Rules

1. **No Real 3D Models**: All entities (Gremlins, Slayer, Office Supplies) MUST be 8-direction QOI sprites.
2. **Vertical Consistency**: All walls must be perfectly vertical (Standard Raycasting constraint). No "slopes" unless implemented via sector-height hacks.
3. **Billboard NPCs**: Sprites must always face the camera or follow 8-direction billboarding logic.

## Rendering Constraints

- **Internal Resolution**: Code must assume a base coordinate system of **320x240** (or 320x200) or **640x480** (high-res). Scaling to 1080p+ must be handled via pixel-perfect upscaling, never by increasing internal detail.
- **Palette Shading**: Use indexed lighting (dimming colors to black) rather than smooth gradients.
- **Shadowless Pass**: UI elements should not have real-time 3D shadows; use flat colors or simple dithered "drop shadows".

## Aesthetic Identity: "Corporate Grimdark"

- **Texture Work**: Use gritty, dithered textures (16x16 to 64x64).
- **The Glitch Factor**: When "chaos" occurs, use bitwise XOR or row-shifting on the framebuffer. Never use "modern" post-processing like Bloom or Motion Blur.
- **The Slayer's Age (42)**: UI and dialogue should reflect the perspective of a tired, 42-year-old corporate survivor.

## Rule: Flag Modernisms
Antigravity MUST flag the following as "Modernisms" during reviews:
 - Anti-aliasing.
 - High-poly geometry.
 - PBR (Physically Based Rendering) materials.
 - 16:9 native pixel ratios (Stick to 4:3 internally).
