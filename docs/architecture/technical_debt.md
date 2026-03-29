# Technical Debt Backlog
**Purpose**: A centralized corporate register for tracking architectural inconsistencies, temporary hacks, and compliance violations requiring future remediation sprints. 
**Governing Skill**: `corporate_workflow_registry`

## 📉 Active Tech Debt Cards
- [ ] **TD-001**: **UI Fragmentation in tlc_editor**
  - **Description**: `editor_main.zig` uses raw SDL2 draw calls instead of the certified `nuklear_zui_standards`. Needs full refactor to immediate-mode layout.
- [ ] **TD-002**: **Map Forge ZUI Migration**
  - **Description**: `map_forge.zig` requires transitioning from flat SDL viewport drawing to `nk_context` rendering, including the ZUI transformation matrix abstraction for camera zoom.
- [ ] **TD-003**: **Voxel Forge Ubiquity Compliance**
  - **Description**: Cross-check the Voxel Forge UI against the `doom_editor_ui_standards` 4-quadrant layout.
- [ ] **TD-004**: **Legacy DDA Fragmentation**
  - **Description**: The core `main.zig` raycaster still uses tile-grid bounds and does not natively interact with Map Forge's polygonal `Area/Wall` procedural arrays. A voxelization bridge is required.
- [ ] **TD-005**: **Editor Engine Migration to Raylib**
  - **Description**: `map_forge.zig` and the surrounding internal tools currently use `SDL2` + Nuklear. Pursuant to the new "Engine vs Editor Separation Philosophy," these must be rewritten to utilize `Raylib` + Nuklear to unlock strict 3D rendering independence from the raycaster engine constraints.
  - **Origin**: [2026-03-29_1327_MEMO_engine_separation.md](../reports/2026/03/2026-03-29_1327_MEMO_engine_separation.md)
- [ ] **TD-006**: **Map Forge Deterministic Object Snapping**
  - **Description**: Raylib uses `f32` vectors which break SDL raycaster collision bounds. The editor MUST implement enforced vertex/object grid-snapping during the new Raylib migration.
  - **Origin**: [2026-03-29_1335_MEMO_retro_purist.md](../reports/2026/03/2026-03-29_1335_MEMO_retro_purist.md)
- [ ] **TD-007**: **Raylib 'WYSIWYG' Quantization Override**
  - **Description**: Raylib renders anti-aliased 32-bit scenes, gaslighting artists. The ZUI editor requires a custom shader or rendering pass to crush colors to 8-bit matching the SDL engine palette to maintain visual fidelity.
  - **Origin**: [2026-03-29_1335_MEMO_retro_purist.md](../reports/2026/03/2026-03-29_1335_MEMO_retro_purist.md)
- [ ] **TD-008**: **The 'Purist Preview' Embedded Raycaster**
  - **Description**: A non-interactive SDL rendering panel embedded inside the Raylib Editor GUI. It tracks the editor cursor's floor coordinates (with a delay), renders a continuous 360-degree panning preview from that exact location, and includes a direct "Play Region" handoff button to the main engine.
  - **Origin**: [2026-03-29_1335_MEMO_retro_purist.md](../reports/2026/03/2026-03-29_1335_MEMO_retro_purist.md)

## 📈 Resolved Tech Debt (Audit Trail)
*(No debt cleared yet... the corporate backlog only grows.)*
