# Implementation Report - RRA-017: Asset Pipeline Automation
**Date**: 2026-03-28
**Time**: 16:37
**ID**: RRA-017

## 1. Technical Approach
- **Decoding**: Integrate `SDL_image` (the `SDL2_image` library) to decode PNG into SDL Surfaces.
- **Surface-to-Pixel Conversion**: Extract raw RGBA pixels from the SDL Surface.
- **Encoding**: Use `src/qoi.zig`'s `encode` function to generate a QOI buffer.
- **Caching Logic**:
  - When a tool requests `asset.png`:
  - 1. Check if `asset.qoi` exists AND is newer than `asset.png`.
  - 2. If yes: Load `asset.qoi` directly.
  - 3. If no: Load `asset.png`, convert to `asset.qoi`, save to disk, and then proceed.

## 2. Architectural Drift Review
- **Ubiquity**: This implements the "Ubiquitous Asset Pipeline" requested in the Voxel Forge standards.
- **DOD**: The conversion will happen in a dedicated "Pipeline Arena" to ensure no fragmentation of main game memory.

## 3. Implementation Plan
1. **Build System**: Update `build.zig` to link `SDL2_image`.
2. **Asset Bridge**: Create `src/asset_proxy.zig` as a universal loader.
3. **Editor Integration**: Update `src/voxel_main.zig` to use the `asset_proxy`.
4. **Desktop Integration**: Optional, but recommended for icon loading.
