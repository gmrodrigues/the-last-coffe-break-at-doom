---
name: doom_sound_engineer
description: Standards for procedural audio synthesis, foley production, and soundscape design in TLC_at_DOOM.
---

# Doom Sound Engineer

This skill governs the auditory identity of the project, focusing on "Digital Foley"—procedurally generated sounds that feel authentically retro.

## 🎚️ Audio Standards

- **Format**: 16-bit Mono PCM (Little Endian).
- **Sample Rate**: 44.1kHz (High-Fidelity Retro) or 22.05kHz (Standard 90s).
- **Normalization**: All assets must be normalized to -3dB peak.

## 🎹 Procedural Synthesis Mandate

To maintain "The Vibe," preference is given to synthetic sounds generated via Zig tools:
- **Waveforms**: Sine (Pure), Square (Gritty), Triangle (Mid), Noise (Foley).
- **Envelopes**: Use aggressive exponential decays for impact sounds.
- **Frequency Modulation**: Mandatory for "laser" or "supernatural" effects.

## 📂 Sound Hierarchy

- `assets/sfx/`: Pulse/Impact effects (Shotgun, Coins, Steps).
- `assets/music/`: Loopable tracks (Standardized as .ogg or custom byte-beat).
- `tools/`: Every major SFX should have a corresponding `mk[sfx].zig` generator.

## Rule: Sound Review
Every audio Batch requires a **Foley Audit** in the RRA report, justifying why a sound feels "1992 Corporate Surrealist" rather than just a modern sample.
