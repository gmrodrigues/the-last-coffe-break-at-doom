# Architecture: Interactive Object System
**name**: INTERACTIVE_OBJECTS
**icon**: assets/game/objects/server/icon.qoi
**exec**: src/entities.zig

## Standards Compliance
- [Asset Organization Standards](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/architecture/asset_organization_standards.md)
- [Architecture Documentation Standards](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/architecture/architecture_documentation_standards.md)
- [Backlog Management Standards](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/architecture/backlog.md)

## Visualizations

### 1. Class Diagram
![diag_1](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/interactive_objects/architecture/images/diag_1.png)

```plantuml
@startuml
class Entity {
    +physics: ObjectPhysics
    +vision: ObjectVision
    +state: ObjectState
}
Entity *-- ObjectPhysics
Entity *-- ObjectVision
Entity *-- ObjectState
@enduml
```

### 2. Behavior Diagram
![diag_2](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/interactive_objects/architecture/images/diag_2.png)

```plantuml
@startuml
[*] --> Idle
Idle --> Interacting: Player Near
Interacting --> StateChange: Action Triggered
StateChange --> Idle
@enduml
```

### 3. Sequence Diagram
![diag_3](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/interactive_objects/architecture/images/diag_3.png)

```plantuml
@startuml
Player -> InteractSystem: Interact(Entity)
InteractSystem -> Entity: GetState()
Entity --> InteractSystem: State: Active
InteractSystem -> Entity: ApplyAction(HeatUp)
@enduml
```

### 4. Component Diagram
![diag_4](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/interactive_objects/architecture/images/diag_4.png)

```plantuml
@startuml
package "Entity System" {
    [PhysicsEngine]
    [RenderEngine]
    [FSM_Processor]
}
@enduml
```

### 5. State Diagram
![diag_5](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/interactive_objects/architecture/images/diag_5.png)

```plantuml
@startuml
state "Server State" as SS {
    [*] --> Off
    Off --> Booting: Power On
    Booting --> Online: System Ready
    Online --> Overheated: High Load
    Overheated --> Off: Shutdown
}
@enduml
```

### 6. Activity Diagram
![diag_6](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/interactive_objects/architecture/images/diag_6.png)

```plantuml
@startuml
start
:Check Proximity;
if (Within Range?) then (yes)
  :Display Interaction Menu;
  :Wait for Input;
else (no)
  :Hide Menu;
endif
stop
@enduml
```

### 7. Use Case Diagram
![diag_7](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/interactive_objects/architecture/images/diag_7.png)

```plantuml
@startuml
Slayer -> (Kick Server)
Slayer -> (Check Thermal Status)
@enduml
```

### 8. Object Diagram
![diag_8](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/interactive_objects/architecture/images/diag_8.png)

```plantuml
@startuml
object "Server:Prop" as S1 {
    mass = 150kg
    state = Overheated
}
@enduml
```

### 9. Timing Diagram
![diag_9](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/interactive_objects/architecture/images/diag_9.png)

```plantuml
@startuml
robust "Interaction Window" as IW
@0
IW is Closed
@5
IW is Open
@10
IW is Processing
@12
IW is Closed
@enduml
```

### 10. Deployment Diagram
![diag_10](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/interactive_objects/architecture/images/diag_10.png)

```plantuml
@startuml
node "DOOM_OS_311" {
    [AssetLoader] --> [EntityFactory]
}
@enduml
```

### 11. Package Diagram
![diag_11](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/interactive_objects/architecture/images/diag_11.png)

```plantuml
@startuml
package entities {
    class ObjectPhysics
    class ObjectState
}
@enduml
```

### 12. Profile Diagram
![diag_12](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/interactive_objects/architecture/images/diag_12.png)

```plantuml
@startuml
class "Interactive" <<Stereotype>>
@enduml
```

### 13. File Structure Diagram
![diag_13](file:///home/glauber/arquivos/projetos/code-labs/the-last-coffe-brak-at-doom/docs/domain/mechanics/interactive_objects/architecture/images/diag_13.png)

```plantuml
@startuml
artifact assets {
    folder game {
        folder objects {
            folder server
        }
    }
}
@enduml
```
