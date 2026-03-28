# Mechanic Specification: Interactive Object System
**Requisition ID**: RRA-020
**Status**: DRAFT
**Owner**: Antigravity (Lead Architect)

## 1. Functional Description
Transforms static sprites into world-integrated entities. Objects (like the Server) now feature 8-directional visual fidelity, physical presence (collision/weight), and internal state machines that react to player proximity and attributes.

## 2. Input & Trigger
- **Interaction**: Proximity-based Context Menu (Right-click or Action Key).
- **Physics**: Force-based pushing/dragging (WASD contact).
- **Triggers**: State transitions based on internal counters (e.g., thermal levels) or external items (e.g., Coffee Cup in inventory).

## 3. Logical Constraints (Vibe Check)
- **Constraint 1**: Visuals must use 8-direction sprite-flipping/angle-selection to maintain 2.5D retro fidelity.
- **Constraint 2**: Collision must be AABB with per-object mass/weight affecting drag speed.
- **Constraint 3**: FSM must be stateless-ready (systems operate on state components).

## 4. Technical Implementation (DOD)
- **Primary Components**: 
  - `ObjectPhysics`: `mass`, `friction`, `velocity`.
  - `ObjectVision`: `angles[8]` (Texture pointers).
  - `ObjectState`: `current_state`, `timer`, `context_actions[]`.
  - `InventoryContainer`: `contained_items[]`, `yield_condition`.
- **System**: `InteractSystem` (proximity check), `DirectionalSpriteSystem` (angle selection).
- **Sub-systems**:
  - [Interaction System](system/interaction/interaction.md): Proximity and contextual actions.
  - [Physics System](system/physics/physics.md): Mass and friction constraints.
  - [Collision Sub-system](system/collision/collision.md): Blocking and pushing behavior.
  - [Destructibility Sub-system](system/destructibility/destructibility.md): Health and tactical vulnerabilities.
  - [Healing Sub-system](system/healing/healing.md): Vibe and health regeneration.
  - [Crafting Sub-system](system/crafting/crafting.md): Resource processing and item recipes.
- **FSM Pattern**: State transition table stored in Metadata, execution on component slices.

## 5. Asset & Directory Structure
All interactive entities must follow the isolated directory pattern:
- **Root Directory**: `assets/game/objects/[entity_name]/`
- **Mandatory Files**:
  - `object.yaml`: Traits, physics stats, and interaction definitions.
  - `icon.qoi`: 16x16 icon for inventory and map representation.
- **Directional Sprites**:
  - `[N, S, E, W, NE, NW, SE, SW].qoi`: 8-directional visual states.
- **Standards**: Must comply with [Asset Organization Standards](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/architecture/asset_organization_standards.md).

## 6. Satirical Corporate Note
"The Board has approved the electrification of office furniture. If a server feels 'heavy' or 'refuses to cooperate,' please submit a 'Non-Compliant Infrastructure' report. Remember: an inanimate object is just a lazy employee with more excuses."
