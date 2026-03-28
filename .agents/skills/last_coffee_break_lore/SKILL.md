---
name: last_coffee_break_lore
description: Standards for storyline composition, character development, and "The Gaslight" dialogue tree.
---

# Last Coffee Break Lore

This skill ensures narrative consistency across the existential, corporate-satire world of TLC_at_DOOM.

## Narrative Constraints

All story elements MUST align with the "Infinite Monday" theme:
- **Tone**: Absurdist, bureaucratic, and mildly Lovecraftian.
- **Setting**: The office is infinite, the coffee is lukewarm, and the demons are just mid-level managers.

## Character Development

Every NPC/Major character MUST have a profile in `docs/domain/characters/` using the `character.md` template.
- **The "Core Burden"**: Every character must have a specific corporate grievance that defines their dialogue.

## The Gaslight System (Dialogue)

Dialogue trees must be documented as ZUI-compatible maps:
- **Depth**: Minimum 3 layers of "gaslighting" (circular logic) per interaction.
- **Standard**: Follow the logic defined in `gaslight_zui_logic` skill.

## Rule: Narrative Audit
If a game mechanic or level design contradicts the "Infinite Monday" lore, it MUST be flagged for a "Board Revision" (RRA update).
