# Architecture: AABB Wall Collision
**name**: AABB_COLLISION
**icon**: assets/game/objects/server/icon.qoi
**exec**: src/main.zig

## Standards Compliance
- [Asset Organization Standards](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/architecture/asset_organization_standards.md)
- [Architecture Documentation Standards](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/architecture/architecture_documentation_standards.md)
- [Backlog Management Standards](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/architecture/backlog.md)

## Visualizations

### 1. Class Diagram
![diag_1](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_1.png)

![diag_1](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_1.png)

![diag_1](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_1.png)

![diag_1](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_1.png)

```plantuml
@startuml
class Map {
    +get(x, y) int
}
class Camera {
    +x float
    +y float
}
class CollisionSystem {
    +check(cam, map)
}
CollisionSystem ..> Map
CollisionSystem ..> Camera
@enduml
```

### 2. Behavior Diagram
![diag_2](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_2.png)

![diag_2](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_2.png)

![diag_2](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_2.png)

![diag_2](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_2.png)

```plantuml
@startuml
[*] --> Idle
Idle --> Moving: Input Detected
Moving --> CollisionCheck: Update Position
CollisionCheck --> Valid: Path Clear
CollisionCheck --> Sliding: Wall Detected
Valid --> Idle
Sliding --> Idle
@enduml
```

### 3. Sequence Diagram
![diag_3](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_3.png)

![diag_3](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_3.png)

![diag_3](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_3.png)

![diag_3](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_3.png)

```plantuml
@startuml
Player -> InputSystem: PRESS W
InputSystem -> Camera: Try Move (X, Y)
Camera -> Map: Check(NewX, OldY)
Map --> Camera: 0 (Free)
Camera -> Map: Check(OldX, NewY)
Map --> Camera: 1 (Wall)
Camera -> Player: Update (NewX, OldY)
@enduml
```

### 4. Component Diagram
![diag_4](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_4.png)

![diag_4](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_4.png)

![diag_4](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_4.png)

![diag_4](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_4.png)

```plantuml
@startuml
package "Collision Engine" {
    [Input Polling] --> [Position Logic]
    [Position Logic] --> [Map Validation]
}
@enduml
```

### 5. State Diagram
![diag_5](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_5.png)

![diag_5](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_5.png)

![diag_5](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_5.png)

![diag_5](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_5.png)

```plantuml
@startuml
state "Movement State" as MS {
    [*] --> Free
    Free --> Colliding: Contact Wall
    Colliding --> Sliding: Directional Adjustment
    Sliding --> Free: Away from wall
}
@enduml
```

### 6. Activity Diagram
![diag_6](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_6.png)

![diag_6](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_6.png)

![diag_6](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_6.png)

![diag_6](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_6.png)

```plantuml
@startuml
start
if (Key Pressed?) then (yes)
  :Calculate New X, Y;
  if (X Clear?) then (yes)
    :Update X;
  else (no)
    :Keep Old X;
  endif
  if (Y Clear?) then (yes)
    :Update Y;
  else (no)
    :Keep Old Y;
  endif
endif
stop
@enduml
```

### 7. Use Case Diagram
![diag_7](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_7.png)

![diag_7](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_7.png)

![diag_7](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_7.png)

![diag_7](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_7.png)

```plantuml
@startuml
Slayer -> (Walk into Wall)
(Walk into Wall) --> (Slide along Wall)
(Walk into Wall) --> (Stop at Boundary)
@enduml
```

### 8. Object Diagram
![diag_8](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_8.png)

![diag_8](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_8.png)

![diag_8](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_8.png)

![diag_8](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_8.png)

```plantuml
@startuml
object "Map: Instance" as M1 {
    grid = [[1,1,1],[1,0,1]]
}
object "Camera: Instance" as C1 {
    x = 1.5
    y = 1.5
}
@enduml
```

### 9. Timing Diagram
![diag_9](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_9.png)

![diag_9](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_9.png)

![diag_9](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_9.png)

![diag_9](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_9.png)

```plantuml
@startuml
concise "Movement Frame" as MF
@0
MF is Polling
@2
MF is Collision
@3
MF is Rendering
@16
MF is Polling
@enduml
```

### 10. Deployment Diagram
![diag_10](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_10.png)

![diag_10](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_10.png)

![diag_10](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_10.png)

![diag_10](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_10.png)

```plantuml
@startuml
node "DOOM_OS_311" {
    [tlc_at_doom.exe]
}
@enduml
```

### 11. Package Diagram
![diag_11](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_11.png)

![diag_11](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_11.png)

![diag_11](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_11.png)

![diag_11](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_11.png)

```plantuml
@startuml
package renderer {
    class Map
    class Camera
}
package main {
    class InputSystem
}
@enduml
```

### 12. Profile Diagram
![diag_12](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_12.png)

![diag_12](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_12.png)

![diag_12](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_12.png)

![diag_12](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_12.png)

```plantuml
@startuml
class "Entity" <<Stereotype>>
class "Slayer" {
    +isSolid: true
}
@enduml
```

### 13. File Structure Diagram
![diag_13](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_13.png)

![diag_13](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_13.png)

![diag_13](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_13.png)

![diag_13](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/collision/architecture/images/diag_13.png)

```plantuml
@startuml
artifact src {
    file main.zig
    file renderer.zig
}
@enduml
```
