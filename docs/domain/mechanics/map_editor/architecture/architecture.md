# Architecture: Map Forge Editor

## Visualizations

### 1. Class Diagram (The Hierarchy)
```plantuml
@startuml
class Region {
    +skybox_id
    +global_vars
    +areas: []Area
}
class Area {
    +canvas: FloorCanvas
    +boundary: []Vertex
    +walls: []Wall
    +inner_boundaries: []Boundary
}
class Intersection {
    +from_area_id
    +to_area_id
    +portal_geometry
}
class Wall {
    +thickness
    +height_inner
    +height_outer
    +texture_id
}
Region *-- Area
Area *-- Intersection
Area *-- Wall
@enduml
```

### 2. Sequence Diagram (Wall Generation)
```plantuml
@startuml
User -> Editor: Click Vertex(x, y)
Editor -> Area: AddVertex(v)
Area -> WallGenerator: GenerateSegment(v_prev, v)
WallGenerator -> Wall: Create(v1, v2)
Wall -> Renderer: LoadTexture(default)
Renderer -> Viewport: DrawThickWall()
@enduml
```

### 3. Behavioral Diagram (Editor Modes)
```plantuml
@startuml
[*] --> CanvasSelect
CanvasSelect --> VertexDraw: "N" Key
VertexDraw --> WallEdit: DoubleClick Loop
WallEdit --> PropertyPanel: Select Wall
PropertyPanel --> WallEdit: Update Height/Thickness
WallEdit --> CanvasSelect: "Esc"
@enduml
```

### 4. Component Diagram
```plantuml
@startuml
[Map Forge UI] --> [Area Manager]
[Area Manager] --> [Wall Generator]
[Wall Generator] --> [Renderer Backend]
[Area Manager] --> [Serialization (.MAP)]
@enduml
```

### 5. State Diagram (Area Lifecycle)
```plantuml
@startuml
state "Area Context" as AC {
    [*] --> Uninitialized
    Uninitialized --> Drawing: New Canvas
    Drawing --> Closed: Loop Completion
    Closed --> Validated: No Self-Intersections
    Validated --> Interconnected: Link to Region
}
@enduml
```

### 6. Activity Diagram (Physics Bridge)
```plantuml
@startuml
start
:User Places Object;
:Check Area Boundary;
if (Inside?) then (yes)
  :Register with Area Physics;
else (no)
  :Assign to Region/Intersection;
endif
stop
@enduml
```

### 7. Use Case Diagram
```plantuml
@startuml
Slayer -> (Draw Office Floor)
Slayer -> (Extrude Walls)
Slayer -> (Attach Coffee Ceiling)
@enduml
```

### 8. Object Diagram (Example Office)
```plantuml
@startuml
object "Breakroom:Area" as A1 {
    vertices = [(0,0), (10,0), (10,10), (0,10)]
}
object "Wall_01:Wall" as W1 {
    thickness = 0.5
    height = 3.0
}
A1 *-- W1
@enduml
```

### 9. Timing Diagram (Procedural Gen)
```plantuml
@startuml
robust "Editor UI" as UI
concise "Generator" as GEN
UI is "Idle"
GEN is "Idle"
@1
UI is "Vertex Add"
GEN is "Computing Normals"
@2
GEN is "Mesh Generation"
@3
UI is "Preview Updated"
GEN is "Idle"
@enduml
```

### 10. Deployment Diagram
```plantuml
@startuml
node "Client Workstation" {
    [Map Forge Executable]
    database "Asset Cache"
}
@enduml
```

### 11. Package Diagram
```plantuml
@startuml
package "Domain" {
    [Region]
    [Area]
}
package "Generator" {
    [WallFactory]
}
@enduml
```

### 12. Profile Diagram
```plantuml
@startuml
class "Volumetric" <<Stereotype>>
class "Ceiling" {
    +isInverted: true
}
@enduml
```

### 13. File Structure Diagram
```plantuml
@startuml
artifact "Map Forge Assets" {
    file "region.yaml"
    file "area_01.json"
}
@enduml
```
