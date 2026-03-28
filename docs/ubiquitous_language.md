# Linguagem Ubíqua (Ubiquitous Language) - D.O.O.M. Voxel Forge V3

Para garantirmos máxima sintonia entre Arquitetura de Software e a User Interface (baseada no Mockup VOXELSCRIPT 3.2), toda a equipe de programadores deve alinhar as referências nas rotinas, structs SDL e manuais aos termos abaixo:

---

## A. Viewports & Área Principal (Componentes de Render)
- **3D Viewport:** O painel imersivo localizado à esquerda. É a janela responsável pelo Renderer Isométrico manipulável por `Orbit`, `Pan` e `Zoom`.
- **2D Slice Viewer:** O painel de trabalho à direita. Uma tela ortográfica puramente baseada em *arrays planares*. É o único local projetado para receber cliques de Mouse associados a desenho direto de *Matrix Color Indices*.
- **Grid Layout / Blue Grid:** A textura quadriculada do plano de fundo no visor bidimensional que orienta a posição do cursor sobre os Voxels.

---

## B. Motores de Corte e Profundidade (Domain do Motor 3D)
- **Slicing Control:** O módulo ou escopo de variáveis UI logo abaixo do *3D Viewport*. Responsável pela manipulação cartesiana do modelo.
- **Layer (Camada):** A coordenada *Escalar* de progressão num eixo. O termo antigo "Depth" fica defasado. O correto é usar `Layer` nas iterações loopadas (Ex: do Layer 0 ao Layer 64).
- **Axis Menu (X, Y, Z):** Constantes Enum de direções perpendiculares de fatiamento no modelo `[X, Y, Z]`.
- **Glowing Plane (Lâmina Transmissora):** O artefato visual desenhado *dentro* do *3D Viewport* como um polígono translúcido (neon) que exibe fisicamente a *Layer* dissecada. Ocultável em parte através do *Plane Opacity Slider*.

---

## C. Utensílios de Mapeamento (CAD Tools)
- **Slice Tools:** Agrupamento nativo das ferramentas do cursor para uso livre sobre a tela bidimensional.
    - **Pencil:** Escrita atômica ou arrasto Voxel base single-unit.
    - **Brush:** Pinturas mais robustas que abrangem mais pixels num radius determinado.
    - **Fill:** Algoritmo *Flood-Fill* BFS para repovoamento maciço de massas conexas de Voxel pela Cross-Section (Layer Isolado).
    - **Select / Marquee:** O Box de array retangular manipulável (a borda sublinhada indicando escopo fechado).
- **Palette Array:** A UI lateral direita contendo a matriz de tons Hexadecimais para seleção. O código textual exato (`Selected Hex`) fica em destaque garantindo padronização da arte por *Strings Hexadecimais* em substituição a paletas RGB genéricas.

---

## D. O Ecossistema Multicamadas (The Independent Stack)
Componentes internos da Prancheta 2D que podem sofrer Transformada Linear Global (`Move`, `Rotate`, `Scale`) independente dos outros. Dividem-se obrigatoriamente por domínio funcional:
- **Voxel Layer (Solid Cast):** Instanciacão material cúbica primária. Base da malha espacial.
- **Geometry/Volume Layer (Vector Memory):** Fio procedural vetorial gerador de cubos. Uma coleção flexível de vértices e splines (abertas ou fechadas) que "imprime" voxels no seu caminho. Pelo fato de reter a identidade paramétrica originária do polígono, a edição de nós (agrupar, rotacionar, modificar forma geométrica) atua fluidamente sobre todo o conjunto.
- **Occlusion Layer (Void Mapper):** Regiões de apagar geométrico e opacionamento forçado.
- **Illumination Layer (Light / Shading):** Aplicação de corante relacional (matemática Aditiva/Multiplicativa) sem afetar malha nativa.
- **Texture Layer (Micro-Paint):** Adição restrita de texturas customizadas aplicáveis a apenas uma face voxel, em fragmentos que variam de `2x2` até `64x64`.
- **Bump Map Layer (Displacement):** Camada adjacente a Textures focadas puramente na distorção física dos limites cartesianos sub-layer produzindo textura 3D real no recorte do bloco.

---

## E. A Grelha Isométrica Resultante
- **8-Direction Tiles (Tira Inferior):** Refere-se à dock fixada de "oito painéis retangulares paralelos" localizados no radapé da aplicação que reflete as imagens completas do asset isométrico exportável.
- **Flat-Render Base (Shadowless Pass):** A determinação absoluta de desenho da *8-Direction Tiles*, onde sobram-se e engolem-se as *Occlusion/Illuminations* a priorizar a renderização limpa do Voxel despido de projeção tridimensional de sombreados diretos — essencial para o corte limpo da folha 2D de sprites do jogo D.O.O.M.
