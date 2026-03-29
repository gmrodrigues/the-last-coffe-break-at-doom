# Core Physics System
**name**: CORE_PHYSICS
**icon**: assets/game/objects/server/icon.qoi
**exec**: src/physics.zig

## 1. Functional Goal
To unify the fragmented collision logic into a single, high-performance Data-Oriented system. This system bridges the gap between the static world occupancy grid (DDA) and dynamic entity-to-entity interactions.

## 2. Technical Implementation (DOD)
- **Primary Components**:
  - `TransformComponent`: Position `(x, y)` and orientation.
  - `PhysicsBodyComponent`: Mass, friction, velocity, and `is_static` flag.
  - `ColliderComponent`: AABB dimensions and `blocking`/`pushable` traits.
- **Core Systems**:
  - [Collision Bridge](system/collision_bridge/README.md): The unified resolver for World and Entity contact.
  - [Impulse Engine](system/impulse_engine/README.md): Vector-based physics integration.

## 3. Standards Compliance
- [Asset Organization Standards](../../../architecture/asset_organization_standards.md)
- [Architecture Documentation Standards](../../../architecture/architecture_documentation_standards.md)

## 4. Satirical Corporate Note
"The Board has approved the unification of Physical Laws. Previously, gravity and solid matter were managed by separate departments, leading to 'quantum paperwork' where employees would exist in two meetings at once. The Core Physics System ensures you are occupied by exactly one task at any given time."
