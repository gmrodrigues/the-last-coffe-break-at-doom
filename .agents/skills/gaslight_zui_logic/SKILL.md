---
name: gaslight_zui_logic
description: Specialized knowledge for implementing the Zoomable User Interface (ZUI) and the "Gaslight" dialogue tree.
---

# Gaslight ZUI Logic

This skill provides the logic and constraints for the dialogue system and the unique infinite-2D ZUI.

## ZUI Principles

- **Infinite 2D Space**: The dialogue graph exists on an unbounded 2D plane.
- **Transformations**: Transitions between dialogue nodes MUST use smooth Zoom/Pan animations.
- **Node-Based Navigation**: Selecting an option triggers a camera move to the target node's coordinates.

## Gaslight Mechanics

- **Lie/Truth Polarity**: Nodes should be tagged with their "deceit level".
- **Cringe Modifier**: Track the Slayer's usage of "millennial slang". 
  - *Trigger:* If slang is used incorrectly, set `next_node_difficulty_multiplier = 1.20`.
- **Innocence vs. Possession**: IA nodes must account for the `PossessionStatus` of the listener.

## Data Structures

Dialogue nodes should follow the graph-based schema:
```json
{
  "id": "node_id",
  "position": {"x": 100, "y": 200},
  "text": "The lie goes here...",
  "options": [
    {
      "text": "Gaslight them",
      "target_node": "target_id",
      "slang_risk": true
    }
  ],
  "is_glitched": false
}
```

## Aesthetic Constraints

- **Shadowless Pass**: Dialogue UI must render without 3D shadows.
- **Retro Scaling**: Internal dialogue state should assume a target resolution of 320x200 or 640x400 for coordinate mapping.
