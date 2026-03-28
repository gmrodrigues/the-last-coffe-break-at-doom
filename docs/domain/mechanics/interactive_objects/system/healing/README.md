# Sub-system: Healing
**Mechanic**: [Interactive Object System](../../interactive_objects.md)
**Status**: DRAFT

## 1. Functional Role
Facilitates the restoration of player or entity health components via timed or instantaneous interaction.

## 2. Implementation Logic
- **Regeneration**: If `healing.rate > 0`, applies a health delta per second during active interaction.
- **Resource Exchange**: Can require a specific `interaction_cost` (e.g., "Corporate Credits" or "Coffee Beans") to activate.

## 3. Data Dependency
- `object.yaml`: `healing.rate`, `healing.type`, `healing.interaction_cost`.
- `HealthComponent`: Primary target for the healing delta.
