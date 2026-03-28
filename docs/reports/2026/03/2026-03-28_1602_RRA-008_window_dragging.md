# Implementation Report - RRA-008: Window Dragging & Minimizing
**Date**: 2026-03-28
**Time**: 16:02
**ID**: RRA-008

## 1. Technical Approach (DOD/Memory)
- **State Management**: Windows will be tracked in an SoA-compliant manner within `DesktopManager`.
  ```zig
  const WindowBatch = struct {
      ids: []u32,
      rects: []c.SDL_Rect,
      is_minimized: []bool,
      titles: [][]const u8,
  };
  ```
- **Input logic**: Detection of mouse down on the title bar (rect `[x, y, w, 20]`) will set an `active_drag_id`.
- **Memory**: No new allocations per-frame. `ArrayListUnmanaged` usage persists.

## 2. Architectural Drift Review
- **Vibe Check**: Standard Windows 3.11 windows do not have animations for minimizing (snap-to-icon instead). This adheres to the `doom_vibe_curator` skill.
- **Fragmentation**: Reusing `SDL_Rect` intersections from the `doom_editor_ui_standards` baseline.

## 3. Step-by-Step Implementation Plan
1. **Extend `DesktopManager`**: Add `is_dragging` and `drag_offset` state.
2. **Update `handleEvent`**:
   - Detect `SDL_MOUSEBUTTONDOWN` on title bar.
   - Detect `SDL_MOUSEMOTION` to update `rect.x` and `rect.y`.
   - Detect `SDL_MOUSEBUTTONUP` to release.
3. **Minimize Logic**:
   - Add a small 16x16 button on the top-right of the title bar.
   - Toggle `is_minimized` flag. Render only an icon if minimized.
4. **Verification**: Run `zig build desktop` and verify drag collision with screen boundaries.
