# System Components

High-level overview of the TLC_at_DOOM engine components.

## Renderer (2.5D DDA)
Responsible for raycasting and sprite billboarding.

## ZUI (Gaslight Engine)
Zoomable User Interface for dialogue and menus.

## Asset Manager (.DOOM)
Handles loading and memory-mapping of binary assets.

## Core Physics (Unified Resolver)
Bridges static world DDA collision and dynamic entity-to-entity impulses.
- Specification: [Core Physics](../domain/mechanics/core_physics/core_physics.md)
