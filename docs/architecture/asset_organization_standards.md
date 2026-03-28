# Asset Organization Standards

To maintain the project's 2.5D retro aesthetic and ensure compatibility with DATA-ORIENTED DESIGN (DOD) principles, all assets must follow these organizational criteria.

## 1. Directory Structure

### `assets/game/`
**Primary container for all gameplay-critical resources.**
- **`env/`**: Static world geometry (e.g., `wall.qoi`, `floor.qoi`).
- **`objects/`**: Interactive entities (prop, NPC, item).
  - **Isolation**: Each unique entity must have its own subdirectory (e.g., `server/`).
  - **Metadata**: Each entity directory MUST contain an `object.yaml` defining its traits and stats.
  - **Directional Cohesion**: All 8-directional views and animations must reside here.
  - **Icon standard**: The 16x16 representation must be named `icon.qoi`.
- **`audio/`**: Soundscapes and effects (`music/`, `sfx/`).

### `assets/tools/`
**Container for internal system and editor resources.**
- **`icons/`**: Program Manager tool icons (e.g., `voxel_icon.png`).
- **`mascots/`**: Project branding/mascot assets (e.g., the Bananas).
- **`metadata/`**: System configuration files (e.g., `tools.yaml`).

### `assets/ui/`
**Container for shared interface elements.**
- Fonts, menu backgrounds, and global UI widgets.

## 2. Technical Requirements

### Recursive Discoverability
- All asset-loading systems (like the `Content Editor`) must implement **recursive directory scanning**.
- **Rule**: Changing an object's location within `assets/objects/` should NOT require a code change to tools.

### Naming Conventions
- **Sprites**: Use directional suffixes (e.g., `N.qoi`, `S.qoi`) for multi-angle entities.
- **Metadata**: Every game object folder MUST contain its own `object.yaml`. See [Object YAML Schema] (below).

## 3. Object YAML Schema (Mandatory)
```yaml
name: "[Human Readable Name]"
entity_id: "[Internal ID]"
traits:
  physics:
    mass: [float]
    friction: [float]
    static: [bool]
    blocking: [bool] # Can block player passage (Default: true)
    pushable: [bool] # Can be pushed by force
  rendering:
    type: "directional" | "billboard" | "static"
    icon: "icon.qoi"
  interaction:
    proximity: [float]
    actions:
      - id: "[action_id]"
        label: "[Button Label]"
  destructibility:
    health: [int]
    hit_effect: "sparks" | "pixel_burst" | "glitch_flicker" | "smoke_puff"
    thresholds:
      - hp_percentage: [float] # e.g., 0.5
        sprite_suffix: [string] # e.g., "_damaged"
    resistances:
      - type: "thermal" | "kinetic" | "plasma"
        multiplier: [float]
  healing:
    rate: [float] # HP per second
    type: "health" | "vibe" | "stamina"
    interaction_cost: [resource_id]
  crafting:
    station_type: "workbench" | "brewer" | "3d_printer"
    recipes:
      - id: "[recipe_id]"
        input: { "[item_id]": [amount] }
        output: "[item_id]"
        time: [float] # Seconds to craft
```

## 5. Modular Sub-system Organization
All mechanic sub-systems MUST reside in a `system/[system_name]/` folder with the following mandatory files:
- `README.md`: Technical documentation and functional role.
- `config.yaml`: The configuration schema/defaults for this specific system.
- `assets.yaml`: Enumeration of required assets and their naming patterns.
- `structure.md`: Mapping of the system to the Zig code (Structs, Enums, Systems).

## 6. Vibe Check (Retro Constraints)
- All new directories must be compatible with the `mkqoi` generator.
- **Satirical Corporate Note**: "The Board does not tolerate 'creative filing.' An asset in the wrong folder is a lost asset, and a lost asset is a deduction from your coffee allowance."
