---
name: nuklear_zui_standards
description: Architecture and aesthetic strictures for implementing Zoomable User Interfaces (ZUI) using the Nuklear immediate-mode GUI library with a highly customized "90s Winamp" look and feel.
---

# Nuklear ZUI Toolkit Standards

This skill governs the integration of the **Nuklear** C immediate-mode library alongside **Raylib** across all "The Last Coffee Break at D.O.O.M." editor toolkits (Map Forge, Voxel Forge, Dialogue Editors). 

**CRITICAL DIRECTIVE**: The project enforces a strict separation of concerns:
- **Game Engine**: Strict SDL2 Raycasting solution.
- **Editor Toolkits**: Raylib + Nuklear exclusively.
Editors must generate an interchangeable game data format that the SDL engine can load, eliminating the need to restrict internal tools to raycasting rendering limitations. By enforcing Raylib+Nuklear, we guarantee consistent ZUI capabilities and extreme "Winamp-style" stylistic customizability.

## 1. 3D Viewport Integration Protocol
Nuklear is a 2D draw-list generator. To render 3D scenes within Nuklear panels:
- **Texture Embedding Methodology**: Internal Raylib 3D viewports MUST be rendered to an off-screen target (e.g., `RenderTexture2D`).
- **Binding**: Pass the resulting texture handle to Nuklear using the `nk_image` or `nk_image_id()` structs.
- **Result**: The 3D scene is drawn natively inside the Nuklear window, respecting the library's clipping, scrolling, and panel-resizing logic.

## 2. The "ZUI" Camera Abstraction
Nuklear does not natively provide an "infinite canvas" node-graph out of the box. ZUI functionality MUST be abstracted by manipulating the input coordinate space:
- **Virtual Space**: Maintain a 2D camera struct (Position, Zoom-Level) for ZUI workspaces.
- **Input Transformation**: Multiply mouse coordinates by the inverse transformation matrix before passing them to `nk_input_motion()`.
- **Render Transformation**: Multiply all Nuklear-generated 2D draw commands (Rectangles, Triangles, Text) by the ZUI transformation matrix before passing the final vertex buffer to the Raylib drawing backend.

## 3. Look-and-Feel: The "Winamp Juice" Mandate
Generic, flat, "utilitarian" immediate-mode aesthetics are STRICTLY PROHIBITED in the toolkits. Editors MUST look "stylish, impactful, and non-generic."
- **Skinning the UI**: Do not rely on primitive Nuklear drawing (flat colored rects) for primary UI chrome.
- **Bitmap Extravagance**: Override the `nk_style_item` properties using `nk_style_item_image()`. Feed Nuklear customized, 9-slice scaled pixel-art textures for buttons, sliders, and panel backgrounds.
- **The 90s Aesthetic**: Embrace high-contrast borders, bevels, CRT-green phosphors (Cyan/Yellow accents), and dark industrial grays. The editors should feel like an extension of a 1998 corporate mainframe or specialized audio software (e.g., raw, hardware-like interfaces).

## 4. Architectural Rules for Implementation
When an Agent builds a UI component using Nuklear:
1. **Never use standard themes**. You MUST initialize a custom style profile and map the elements to loaded `.qoi` assets from `assets/tools/icons/`.
2. Ensure structural adherence to the 4-Quadrant baseline detailed in `doom_editor_ui_standards`.
3. Treat the UI rendering pass and the 3D rendering pass as distinctly synchronized parallel structures managed by the main application event loop.
