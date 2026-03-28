# Physics Mapping
**Source**: `src/physics.zig`

## 1. Structs
- `ObjectPhysics`: Data-Oriented slice for mass/friction/velocity.

## 2. Systems
- `Integrator`: Computes new position based on velocity and delta time.
- `FrictionResolver`: Applies drag based on surface/object coefficients.
