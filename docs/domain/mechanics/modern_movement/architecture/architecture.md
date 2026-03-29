# Architecture: Modern FPS Movement
**name**: MODERN_MOVEMENT
**icon**: assets/game/objects/weapon/icon.qoi
**exec**: src/main.zig

## Standards Compliance
- [Asset Organization Standards](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/architecture/asset_organization_standards.md)
- [Architecture Documentation Standards](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/architecture/architecture_documentation_standards.md)
- [Backlog Management Standards](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/architecture/backlog.md)

## Visualizations

### 1. Class Diagram
![diag_1](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_1.png)

![diag_1](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_1.png)

![diag_1](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_1.png)

![diag_1](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_1.png)

```plantuml
@startuml
class Camera {
    +dir_x: float
    +dir_y: float
    +plane_x: float
    +plane_y: float
    +rotate(angle)
}
@enduml
```

### 2. Behavior Diagram
![diag_2](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_2.png)

![diag_2](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_2.png)

![diag_2](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_2.png)

![diag_2](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_2.png)

```plantuml
@startuml
[*] --> Stationary
Stationary --> Rotating: Mouse Move
Rotating --> Stationary: Mouse Stop
Stationary --> Strafing: A/D Pressed
Strafing --> Stationary: A/D Released
@enduml
```

### 3. Sequence Diagram
![diag_3](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_3.png)

![diag_3](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_3.png)

![diag_3](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_3.png)

![diag_3](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_3.png)

```plantuml
@startuml
User -> Input: Move Mouse Right
Input -> Camera: rotate(mouse_x * sensitivity)
Camera -> Camera: Update dir_x, dir_y
@enduml
```

### 4. Component Diagram
![diag_4](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_4.png)

![diag_4](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_4.png)

![diag_4](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_4.png)

![diag_4](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_4.png)

```plantuml
@startuml
package "Movement System" {
    [MouseHandler]
    [KeyboardHandler]
    [VectorMath]
}
@enduml
```

### 5. State Diagram
![diag_5](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_5.png)

![diag_5](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_5.png)

![diag_5](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_5.png)

![diag_5](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_5.png)

```plantuml
@startuml
state "Movement" as M {
    [*] --> Idle
    Idle --> Walking: WASD
    Walking --> Idle : Release
}
@enduml
```

### 6. Activity Diagram
![diag_6](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_6.png)

![diag_6](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_6.png)

![diag_6](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_6.png)

![diag_6](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_6.png)

```plantuml
@startuml
start
:Get Mouse Offset;
:Apply Rotation to Dir Vector;
:Apply Rotation to Plane Vector;
stop
@enduml
```

### 7. Use Case Diagram
![diag_7](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_7.png)

![diag_7](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_7.png)

![diag_7](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_7.png)

![diag_7](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_7.png)

```plantuml
@startuml
Slayer -> (Navigate Office)
Slayer -> (Strafe past Cubicles)
@enduml
```

### 8. Object Diagram
![diag_8](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_8.png)

![diag_8](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_8.png)

![diag_8](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_8.png)

![diag_8](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_8.png)

```plantuml
@startuml
object "CurrentCamera:Camera" as CC {
    dir_x = 1.0
    dir_y = 0.0
}
@enduml
```

### 9. Timing Diagram
![diag_9](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_9.png)

![diag_9](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_9.png)

![diag_9](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_9.png)

![diag_9](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_9.png)

```plantuml
@startuml
robust "Input Frequency" as IF
@0
IF is Waiting
@4
IF is Sampling
@6
IF is Processing
@16
IF is Waiting
@enduml
```

### 10. Deployment Diagram
![diag_10](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_10.png)

![diag_10](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_10.png)

![diag_10](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_10.png)

![diag_10](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_10.png)

```plantuml
@startuml
node "Workstation" {
    [Mouse]
    [Keyboard]
}
@enduml
```

### 11. Package Diagram
![diag_11](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_11.png)

![diag_11](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_11.png)

![diag_11](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_11.png)

![diag_11](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_11.png)

```plantuml
@startuml
package input {
    [SDL_Events]
}
@enduml
```

### 12. Profile Diagram
![diag_12](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_12.png)

![diag_12](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_12.png)

![diag_12](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_12.png)

![diag_12](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_12.png)

```plantuml
@startuml
class "Mobile" <<Stereotype>>
@enduml
```

### 13. File Structure Diagram
![diag_13](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_13.png)

![diag_13](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_13.png)

![diag_13](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_13.png)

![diag_13](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/modern_movement/architecture/images/diag_13.png)

```plantuml
@startuml
file "src/main.zig" as M
@enduml
```
