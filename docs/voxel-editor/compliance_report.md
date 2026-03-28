# Relatório de Conformidade: Voxel Forge V3 📑

Este documento audita a implementação atual do **Voxel Forge V3** (`src/voxel_main.zig`) em relação aos requisitos definidos em `voxel_v3_requirements.md` e `ubiquitous_language.md`.

## 📊 Status de Implementação

| Área | Requisito Principal | Status | Observações |
| :--- | :--- | :--- | :--- |
| **3D Viewport** | Isometric Rendering | ✅ **OK** | Algoritmo do pintor (Painter's Algorithm) funcional. |
| | Glowing Plane | ✅ **OK** | Lâmina neon translúcida com transparência configurável. |
| | Ghosting Effect | ✅ **OK** | Voxels à frente do plano ficam com 25% de opacidade. |
| | Orbit/Pan/Zoom/Light| ❌ **MISSING** | Câmera fixa em 8 ângulos via Tiles; sem controle livre. |
| **2D Slice Viewer**| Orthographic Grid | ✅ **OK** | Grade 16x16 integrada ao Editor. |
| | Drawing Tools | ✅ **OK** | PEN, ERASE, FILL, LINE, CIRC, SEL implementados. |
| | Layers (Pilha) | 🟡 **PARTIAL** | Lista de camadas funcional, mas sem transformadas. |
| | Canvas Zoom/HUD | ❌ **MISSING** | Visualização 2D tem zoom fixo. |
| **Slicing Control** | Axis Selection | ✅ **OK** | Normal de corte configurável em X, Y e Z. |
| | Layer Slider | ✅ **OK** | Navegação por profundidade (0 a 15) em tempo real. |
| | Auto Play | ✅ **OK** | Animação de "escaneamento" automática funcional. |
| **8-Direction Tiles**| 8-Tile Array | ✅ **OK** | Esteira de 8 painéis para ângulos 0° a 315°. |
| | Flat-Render | ✅ **OK** | Renderiza Albedo puro (sem sombras) para os tiles. |
| | QOI Export | ✅ **OK** | Exportação paralela de 8 sprites via tecla 'P' ou botão. |

---

## 🔍 Gaps Técnicos vs. Requisitos

### 1. Independência de Camadas (Layers)
*   **Requisito:** Cada camada (`Independent Stack`) deveria suportar `Move`, `Rotate` e `Scale` individuais.
*   **Estado Atual:** Camadas são matrizes estáticas sobrepostas. O sistema de coordenadas é global para todos os layers.

### 2. Lógica Funcional de Tipos de Camada
*   **Requisito:** Tipos específicos de layer deveriam ter comportamentos matemáticos distintos.
*   **Estado Atual:** `Occlusion`, `Illumination`, `Texture` e `BumpMap` são apenas metadados (labels). A lógica de subtração de volume (`OCC`) e sombreamento (`LIT`) não foi transposta para o algoritmo de merge.

### 3. Camada de Geometria Procedural (`GEO`)
*   **Requisito:** Memória vetorial (pontos e retas) que geram voxels.
*   **Estado Atual:** Implementado apenas como "Voxel Layer" (edição direta de pixels). Não há retenção de formas procedurais.

### 4. Navegação 3D e Ferramentas Viewport
*   **Requisito:** Toolbar de viewport para `Orbit`, `Pan`, `Zoom` e `Light`.
*   **Estado Atual:** O controle de visualização é feito estritamente pelos *8-Direction Tiles*. Não há suporte para mouse-driven rotation ou posicionamento de luzes.

---

## 🛠️ Próximos Passos Recomendados

1.  **Refatoração do Merge de Camadas:** Implementar a matemática de subtração para layers `OCC` e multiplicação de cor para `LIT`.
2.  **Transformadas de Layer:** Adicionar `offset_x` e `offset_y` para permitir o movimento de layers individuais no Canvas 2D.
3.  **Engine de Textura (Sub-res):** Implementar a grade interna de `2x2` até `64x64` para os layers de textura.
