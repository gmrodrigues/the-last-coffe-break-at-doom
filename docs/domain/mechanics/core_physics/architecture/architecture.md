# Architecture: Core Physics System

## Visualizations

### 1. Class Diagram
```plantuml
@startuml
class PhysicsSystem {
    +update(dt)
}
class CollisionBridge {
    +resolve(a, b)
}
class Entity {
    +Transform
    +PhysicsBody
    +Collider
}
PhysicsSystem --> CollisionBridge
CollisionBridge ..> Entity
@enduml
```

### 2. Behavioral Diagram
```plantuml
@startuml
[*] --> Idle
Idle --> Movement: Impulse Applied
Movement --> CollisionCheck: Update Sub-step
CollisionCheck --> WorldCollision: Raycast DDA
CollisionCheck --> EntityCollision: AABB Overlap
WorldCollision --> Response: Slide
EntityCollision --> Response: Push/Block
Response --> Idle
@enduml
```

### 3. Sequence Diagram
```plantuml
@startuml
PhysicsSystem -> Transform: Get Pos
PhysicsSystem -> PhysicsBody: Apply Gravity
PhysicsSystem -> CollisionBridge: Check(Pos)
CollisionBridge -> World: Raycast(Pos)
World --> CollisionBridge: Hit Wall
CollisionBridge -> Transform: Adjust(Slide)
@enduml
```

### 4. Component Diagram
```plantuml
@startuml
[Input] --> [Physics Engine]
[Physics Engine] --> [Collision Bridge]
[Collision Bridge] --> [Map Validation]
[Collision Bridge] --> [Entity State]
@enduml
```

### 5. State Diagram
```plantuml
@startuml
state "Physical State" as PS {
    [*] --> Static
    Static --> Moving: Force > Friction
    Moving --> Colliding: Penetration Deteted
    Colliding --> Sliding: Resolve Tangent
    Sliding --> Static: Velocity < Min
}
@enduml
```

### 6. Activity Diagram
```plantuml
@startuml
start
:Integrate Velocity;
:Find Candidate Position;
if (World Hit?) then (yes)
  :Apply Slide;
endif
if (Entity Hit?) then (yes)
  if (Pushable?) then (yes)
    :Transfer Impulse;
  else (no)
    :Block Move;
  endif
endif
:Update Transform;
stop
@enduml
```

### 7. Use Case Diagram
```plantuml
@startuml
Player -> (Push Box)
Player -> (Wall Slide)
Box -> (Block Path)
@enduml
```

### 8. Object Diagram
```plantuml
@startuml
object "Slayer: Entity" as E1 {
    mass = 80
}
object "Server: Entity" as E2 {
    mass = 150
    blocking = true
}
@enduml
```

### 9. Timing Diagram
```plantuml
@startuml
robust "Physics Loop" as PL
PL is "Idle"
@1
PL is "Integration"
@2
PL is "Collision"
@3
PL is "Resolution"
@16
PL is "Idle"
@enduml
```

### 10. Deployment Diagram
```plantuml
@startuml
node "Game Loop" {
    [PhysicsSystem]
    [MovementSystem]
}
@enduml
```

### 11. Package Diagram
```plantuml
@startuml
package "Core Physics" {
    [CollisionBridge]
    [ImpulseEngine]
}
package "Renderer" {
    [DDA_Raycaster]
}
[CollisionBridge] ..> [DDA_Raycaster]
@enduml
```

### 12. Profile Diagram
```plantuml
@startuml
class "KineticBody" <<Stereotype>>
class "Player" {
    +isSolid: true
}
@enduml
```

### 13. File Structure Diagram
```plantuml
@startuml
artifact "src" {
    file physics.zig
    file entities.zig
    file renderer.zig
}
@enduml
```
