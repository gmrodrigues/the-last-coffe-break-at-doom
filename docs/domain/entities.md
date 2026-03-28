# Project Entities (SoA Definitions)

This document defines the core data structures for all game entities, adhering to the Struct of Arrays (SoA) pattern.

## Gremlins
```zig
const GremlinBatch = struct {
    positions: []Vec3,
    health: []f32,
    innocence: []f32,
};
```

## Office Equipment
[To be defined]
