# CORPORATE MEMORANDUM & TRANSCRIPT
**DATE**: March 29, 2026
**SUBJECT**: [URGENT] The Raylib vs SDL Schism - A Coffee Presentation
**LOCATION**: The Breakroom (Fluorescent lights flickering ominously)
**PRESENTER**: The Architect
**ATTENDEES**: The Junior Dev, The Vibe Curator, Corporate HR, The Engine Purist

---

## ☕ The Presentation

*(The Architect stands next to a white board covered in red string and hastily drawn 2.5D projections. They aggressively tap the board with a dry-erase marker.)*

**The Architect**: "Listen up, people. We’ve hit a wall. A literal, ray-casted, uniformly-heighted wall. We’ve been trying to jam our editors—Map Forge, Voxel Forge—into the same strict SDL2 raycasting engine we use for the game. It’s like trying to build a spaceship using exclusively stone tools because 'it builds character'."

**The Vibe Curator**: *(Sipping an artisanal cold brew)* "But stone tools are *authentic*. If our editors don’t have integer overflow errors natively built into the memory allocation pipeline, how can we truly capture the 90s aesthetic? Have we lost our way?"

**The Architect**: "We haven’t lost our way, we’re just building better shovels. From this day forward: **The Game Engine remains STRICTLY SDL2 Raycasting.** It will suffer the retro limitations of the 2.5D format gracefully. BUT! The **internal Editors MUST use Raylib + Nuklear**. Full 3D viewport flexibility, high-performance UI, no more crying over un-renderable complex polygons in the editor."

## 🗣️ Stakeholder Gossip & Direct Feedback

**The Engine Purist**: *(Hyperventilating slightly, clutching a printed copy of `main.zig`)* 
"This is heresy. You’re splitting the stack! You're creating an interchangeable game data format just so the editor can frolic in a magical 3D Raylib playground while the game engine stays in the SDL trenches doing raw math?! What about the *stray pixels*, man? The Raylib pipeline will render intersections perfectly, and then the SDL raycaster will load the map and render a jagged edge. **I cannot sign off on this.**"

**The Junior Dev**: *(Looking up from TikTok)*
"Wait, so in the editor I can just use Raylib's 3D camera instead of writing a manual matrix transformation for every single boundary vertex? Oh my god... I can finally go home to my family. This is amazing. I love this. I’ll write the map exporter today. Heck, I'll write it in ten minutes."

**Corporate HR**: *(Takes notes efficiently)*
"I’m hearing a lot of 'passion' today. Just to clarify, this 'Raylib' entity... does it require us to restructure our vendor licenses? Because if this means the Development Team doesn't have to submit 40-page technical debt requisitions just to draw a generic window, Human Resources approves. Productivity is highly synergized."

**The Vibe Curator**: 
"Wait... if the editors are using Raylib... does the Nuklear UI still look like 1998 Winamp? Because if this becomes a flat-design, rounded-corner, electron-app nightmare, I am filing a grievance with the union. I want 9-slice bitmaps. I want CRT phosphor greens. I want sliders that look like they could draw blood if you touched them."

**The Architect**:
"Yes! The Nuklear standards remain! We just bind `RenderTexture2D` from Raylib to the `nk_image` struct for the 3D viewport. The exported JSON/Binary maps will just feed into the SDL raycaster. It’s the perfect crime. We get quality-of-life in development, and pure, unfiltered masochism in the runtime."

## 📝 Action Items (Approved by the Board)
1. **TD-005 Logged**: All current SDL-based editor prototypes (`map_forge.zig`) must be torn down and migrated to `Raylib + Nuklear`.
2. **Interchangeable Format**: The "Wall Face Protocol" and voxel grid must be serialized into a strict standard that the SDL engine can blindly parse.
3. **Mandatory Purist Coping Sessions**: Bi-weekly therapy for the Engine Purist to deal with the stack split.

*Memo filed to `docs/reports/2026/03/` by Order of the C-Suite.*
