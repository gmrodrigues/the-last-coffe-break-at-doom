# Universal Component Catalog - Doom Tools

## 1. Directional/Perspective Tiles
- **Description**: Square tiles representing fixed angles or states (e.g. 8-direction camera angles).
- **States**:
  - `Default`: Grey background, 1px dark border.
  - `Selected`: **Cyan border** (0x00FFFFFF).
- **Behavior**: Clicking snaps the 3D Viewport's camera to the corresponding angle.

## 2. Contextual Control Rows (e.g., Layer Panel)
- **Description**: A vertical or horizontal stack of controls for managing state layers.
- **Controls**:
  - `Visibility Toggle`: Eye icon (Visible) / Dash (Hidden).
  - `Label`: 3-character type (VOX, OCC, LIT, TEX, GEO).
  - `Selection`: Row background glows slightly when active.
- **Behavior**: Only one layer can be "Active" for drawing at a time.

## 3. Parameter Strips (e.g., Slicing Controls)
- **Description**: Horizontal bars with sliders and toggle buttons for navigating multi-dimensional data.
- **Features**:
  - `Axis Buttons`: X, Y, Z toggle buttons.
  - `Slider`: Navigates integer layers (0-15).
  - `Play/Stop`: Toggles automatic slice scanning.
- **Aesthetic**: All buttons are flat-render (shadowless).

## 4. Palette Swatch
- **Description**: Small square color blocks in the toolbar.
- **Constraint**: Maximum 7 active colors + 1 selected.
- **Feedback**: **White border** (0xFFFFFFFF) on the active swatch.
