# Impulse Engine Mapping
**Source**: `src/physics.zig`

## 1. Structs
- `PhysicsBody`: DOD slice for velocity/force/mass.

## 2. Systems
- `Integrator`: Updates position based on `velocity * dt`.
- `FrictionSystem`: Applies surface-specific drag.
