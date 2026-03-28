# Sub-system: Destructibility
**Mechanic**: [Interactive Object System](../../interactive_objects.md)
**Status**: DRAFT

## 1. Functional Role
Defines how an object takes damage and breaks. Allows for tactical weaknesses (e.g., electronic servers are vulnerable to plasma).

## 2. Implementation Logic
- **Health**: Tracks a `current_hp` component. When 0, triggers `on_death` event (spawn debris, change sprite).
- **Threshold Sprites**: Automatically appends `sprite_suffix` to the base texture name when `current_hp / max_hp <= hp_percentage`.
- **Hit Effects**: Spawns a transient particle/sprite overlay based on the `hit_effect` option.
- **Vulnerabilities**: Applies `multiplier` to incoming damage based on the damage type tag.

## 3. Data Dependency
- `object.yaml`: `destructibility.health`, `destructibility.resistances`.
- `DamageSystem`: Processes the mitigation math.
