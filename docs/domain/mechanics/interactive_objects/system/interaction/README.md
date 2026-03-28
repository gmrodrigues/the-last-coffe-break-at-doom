# Sub-system: Interaction System
**Mechanic**: [Interactive Object System](../../interactive_objects.md)
**Status**: DRAFT

## 1. Functional Role
Detects player proximity to entities and facilitates contextual actions (Power, Use, Inspect).

## 2. Implementation Logic
- **Trigger**: Ray-casting or Proximity sphere (defined in `object.yaml`).
- **Context Actions**: Reads the `actions` array from the entity metadata and populates the command queue.

## 3. Data Dependency
- `ObjectState`: Tracks entity lifecycle.
- `object.yaml`: Metadata for interaction radii and labels.
