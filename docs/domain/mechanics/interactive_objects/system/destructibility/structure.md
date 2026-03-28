# Destructibility Mapping
**Source**: `src/damage.zig`

## 1. Structs
- `HealthComponent`: `current`, `max`, `is_dead`.
- `DamageEvent`: Incoming damage packet with `type` and `magnitude`.

## 2. Systems
- `MitigationSystem`: Applies resistances/vulnerabilities from `object.yaml`.
- `VisualFeedbackSystem`: Triggers `hit_effect` and `threshold_sprite` swaps.
