# Mechanic: Map Editor (Region & Area System)
**name**: MAP_EDITOR_CORE
**icon**: assets/tools/icons/map_icon.png
**exec**: docs/domain/mechanics/map_editor/map_editor.md

## 1. Functional Overview
A hierarchical system for constructing levels using polygonal areas, connected by intersections, and grouped into regions.

## 2. Domain Entities
### 2.1 Region
The top-level container.
- **Properties**: `skybox_id`, `ambient_light`, `global_variables`.
- **Children**: List of `Area` nodes.

### 2.2 Area
A specific spatial segment defined by a floor geometry.
- **Floor Canvas**: A container for all sub-geometric elements.
- **Boundary**: A closed loop of vertices defining the floor.
- **Wall Generation**: Every vertex pair generates a `Wall` with configurable `thickness`, `height_inner`, and `height_outer`.
- **Inner Boundaries**: Negative or positive sub-polygons on the floor (islands/pits).

### 2.3 Intersection
The logical bridge between two `Area` nodes.
- **Portal logic**: Handles visibility and ray-casting transition between disconnected areas.

## 3. Sub-systems
- [Area Manager](system/area_manager/README.md): Lifecycle and node indexing.
- [Wall Generator](system/wall_generator/README.md): Procedural mesh generation from vertices.
- [Intersection Resolver](system/intersection_resolver/README.md): Portal/Linkage logic.

## 4. Satirical Corporate Note
"Region Manager is not just a title; it is a technical reality. Use the Map Forge to ensure every cubicle is properly interconnected with the breakroom. Closed loops are mandatory; we cannot have employees wandering into the unrendered void during work hours."
