# Voxel Forge V3 - User Manual 🛠️

Welcome to the **Voxel Forge V3**, the professional-grade 3D voxel CAD tool for *The Last Coffee Break at D.O.O.M.* This guide explains how to use the interface to create high-performance 2.5D assets.

## 🖥️ Interface Overview

The editor is divided into four main functional areas:
1.  **Toolbar (Top):** Core settings and drawing tools.
2.  **3D Viewport (Left):** Real-time isometric visualization with the *Glowing Plane*.
3.  **2D Slice Viewer (Right):** Precision drawing area with a dedicated *Layer Panel*.
4.  **Control Strips (Bottom):** *Slicing Controls* (top) and *8-Direction Tiles* (bottom).

---

## 🎨 Drawing & Tools

Select a tool from the toolbar and use the **Left Mouse Button** on the **2D Slice Viewer** grid.

| Tool | Label | Description |
| :--- | :--- | :--- |
| **Pencil** | `PEN` | Draws individual voxels with the active color. |
| **Eraser** | `ERASE` | Removes voxels from the active layer. |
| **Fill** | `FILL` | 2D Flood Fill — replaces all connected cells of the same color. |
| **Line** | `LINE` | Draws a line from the click point to the release point. |
| **Circle** | `CIRC` | Draws a circle. Click for center, drag for radius. |
| **Select** | `SEL` | Highlights areas (Used for batch operations). |

### 🌈 Palette
Select one of the **7 active colors** from the top-right swatches. The white border indicates your current selection.

---

## 🧊 3D Visualization

### Rolling the Camera
The bottom row displays **eight fixed isometric angles** (0° to 315°).
- **Click a Tile** to snap the 3D Viewport to that perspective.
- The active camera angle is highlighted with a cyan border.

### The Glowing Plane & Ghosting
The **Glowing Plane** is a translucent blue indicator showing exactly where your 2D slice is located in 3D space.
- Voxels **behind** the plane (deeper) are rendered with full opacity.
- Voxels **in front** of the plane (shallower) are rendered as **Ghosts** (25% transparency) so you can always see your work area.

---

## 🏗️ Layer Management

The **Layer Panel** (left side of the 2D viewer) manages up to 8 independent drawing stacks.

- **Add Layer (`+`):** Creates a new layer.
- **Select:** Click a layer row to make it active for drawing.
- **Visibility (`O` / `-`):** Toggle the eye icon to hide or show a layer in both 2D and 3D.
- **Layer Types:** `VOX` (Standard Voxel), `OCC` (Occlusion), `LIT` (Illumination), `TEX` (Texture), `GEO` (Geometry).

---

## 🔪 Slicing & Controls

Located directly below the viewports, the **Slicing Controls** handle depth navigation.

- **Axis Selection (`X`, `Y`, `Z`):** Choose the orientation of your 2D slice.
- **Layer Slider:** Navigate through the 16 depth levels of the selected axis.
- **Play Button (▶️):** Starts an automatic "scanning" animation through all layers.
- **Opacity Slider:** Adjusts how bright the *Glowing Plane* appears in 3D.

---

## 💾 Exporting Assets

The Voxel Forge generates shadowless sprite sheets for engine use.

- **Button:** Click the purple **EXPORT** button in the slicing panel.
- **Shortcut:** Press the **`P`** key on your keyboard.
- **Result:** 8 files (`voxel_0.qoi` to `voxel_7.qoi`) are saved to the `assets/` directory, representing each isometric direction.

---

## ⌨️ Global Shortcuts

- **`ESC`**: Quit the application.
- **`P`**: Export sprites.
- **`Drag (Mouse Left)`**: Paint or move sliders.
- **`Click (Mouse Left)`**: Select tools, layers, or tiles.
