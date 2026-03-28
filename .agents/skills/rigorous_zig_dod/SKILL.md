---
name: rigorous_zig_dod
description: Specialized instructions for highly optimized Zig code following Data-Oriented Design (DOD) and explicit memory management.
---

# Rigorous Zig DOD

This skill ensures that all code written for the TLC_at_DOOM project adheres to the strict performance and architectural standards defined in `Tech.md`.

## Core Principles

1. **Performance over Objects**: Use Data-Oriented Design (DOD). Prefer Struct of Arrays (SoA) for bulk processing (e.g., NPCs, particulates).
2. **Explicit Allocation**: Never use a global allocator. Always require an `Allocator` as an argument or use specific allocators (Arena for frame-temp, GPA for state, Pool for particles).
3. **Comptime Magic**: Leverage `comptime` for look-up tables and type-safe meta-programming to move runtime costs to compile-time.
4. **Glitch-Injection Ready**: When writing rendering code, ensure there are hooks for "glitch factors" and "bitwise XOR" post-processing as per the "TLC_at_DOOM" aesthetic.

## Allocator Usage Patterns

- **Frame Allocator (Arena)**: Used for rendering loops. Reset every frame.
- **Persistent Allocator (GPA)**: Used for game state, inventory, and long-lived items.
- **Pool Allocator**: Essential for entities that are frequently created and destroyed (e.g., bullets, gremlins).

## DOD Patterns

Prefer this:
```zig
const EntityBatch = struct {
    positions: []Vec3,
    health: []f32,
    innocence: []f32,
};
```
Over this:
```zig
const Entity = struct {
    pos: Vec3,
    health: f32,
    innocence: f32,
};
const entities: []Entity;
```

## Anti-Patterns

- Using `std.heap.page_allocator` directly in performance loops.
- Over-using interfaces and deep object hierarchies.
- Forgotten `defer allocator.free(s)` statements (Antigravity MUST check for memory leaks).
