# Sub-system: Impulse Engine
**Mechanic**: [Core Physics](../../core_physics.md)
**Status**: DRAFT

## 1. Functional Role
Handles the application of forces and impulses to entities, including gravity, friction, and player-induced pushes.

## 2. Implementation Logic
- **Force Integration**: Accumulates all active impulses on an entity and resolves the resulting `velocity` vector.
- **Pushing Mechanism**: When `CollisionBridge` detects a contact between a move-active entity and a `pushable` entity, it transfers a portion of the move-vector based on relative `mass`.

## 3. Data Dependency
- `PhysicsBodyComponent`: `mass`, `friction`, `velocity`.
- `ImpulseQueue`: Thread-safe buffer for incoming force packets.
