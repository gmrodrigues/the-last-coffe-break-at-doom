# Architectural Drift Report: Legacy UI vs Nuklear ZUI
**Report ID**: ADR-2026-03-29-ZUI
**Date**: 2026-03-29 13:10
**Status**: REVIEW REQUIRED

## 1. Fragmentation Analysis
- **Finding**: Utilitarian UI Fragmentation. The existing implementations of `tlc_editor` (Asset Browser) and `tlc_map_forge` (Playground) rely on raw, disjointed SDL2 rectangle drawing. They lack cohesive state management, theme skinning, and proper ZUI (Zoomable) canvas abstractions.
- **Rule Violated**: `nuklear_zui_standards` (The 90s Winamp Aesthetic & ZUI wrapping).
- **Risk**: High. The lack of a unified immediate-mode GUI backbone guarantees divergent look-and-feel across corporate tools and prevents robust viewport camera scaling.

## 2. Technical Debt Migration
- **Finding**: `editor_main.zig` and `map_forge.zig` contain hard-coded coordinate logic that needs to be superseded by the `nk_context` drawing pipeline.
- **Action**: A new `technical_debt.md` backlog has been established to track the progressive refactoring of all standalone C/Zig tools to the Nuklear standard.

## 3. Recommended Implementation Strategy (Nuklear)
- Introduce `nuklear.h` as a single-header dependency.
- Bind `SDL2` event loops to `nk_context`.
- Abstract drawing bounds of the "Map Viewport" into an off-screen texture OR an explicit `nk_window`.

## 4. Satirical Corporate Commentary
- **Architect**: "Drawing hard-coded rects in SDL in 2026? We're not savages. Adopt the standard."
- **UX Lead**: "The current editor lacks 'Juice'. I want to feel like a hacker from 1998 defragmenting a hard drive when I place a wall vertex."
- **HR**: "The GUI must prominently display the mandatory Coffee Break timer. No exceptions."
