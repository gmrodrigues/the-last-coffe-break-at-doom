# Architecture Documentation Standards

All architectural documentation in the TLC_at_DOOM project must adhere to the following standards to ensure "Corporate Operational Clarity."

## 1. Required Fields
Every architectural specification MUST include:
- **name**: Human-readable name of the system/component.
- **icon**: Path to the 16x16 `icon.qoi` representing the system.
- **exec**: Path to the executable binary or main source file.

## 2. Visualization (PlantUML)
Every specification MUST provide a comprehensive visual suite. Use the `@startuml ... @enduml` block for each.

### Required Diagrams:
1. **Class Diagram**: Static structure of components and interfaces.
2. **Behavior Diagram**: General behavior description.
3. **Sequence Diagram**: Interaction between components over time.
4. **Component Diagram**: Logical grouping of source code.
5. **State Diagram**: State transitions (FSM).
6. **Activity Diagram**: Procedural flow of logic.
7. **Use Case Diagram**: System goals and actor interactions.
8. **Object Diagram**: Instance-level snapshot.
9. **Timing Diagram**: Performance and time-based constraints.
10. **Deployment Diagram**: Binary distribution and OS integration.
11. **Package Diagram**: Module dependencies.
12. **Profile Diagram**: Domain-specific stereotypes.
13. **File Structure Diagram**: Physical artifact locations.

## 3. Format & Vibe
- **Format**: Standard GitHub Flavored Markdown.
- **Tone**: Professional with a hint of satirical corporate dystopia.
- **Satirical Corporate Note**: "The Board believes that a system without fourteen diagrams is just a hallucination. Visualize or be terminated."
