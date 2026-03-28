Este documento detalha as especificações de arquitetura e implementação para a *codebase* em **Zig** do projeto **The Last Coffee Break at D.O.O.M.** Como Arquiteto de Sistemas, as decisões aqui visam performance bruta, controle total de memória e uma estrutura que facilite a sátira mecânica (como os *glitches* de renderização e o sistema de *gaslight*).

---

# Documento de Especificação Técnica: Engine TLC_at_DOOM (Zig)

## 1. Paradigma de Arquitetura: Data-Oriented Design (DOD)
Diferente da Programação Orientada a Objetos, utilizaremos **DOD**. Em Zig, isso significa organizar os dados em *structs* simples e processá-los em arrays contíguos para maximizar o cache da CPU.

* **SoA (Structure of Arrays):** Para os **Gremlings** e **Estagiários**, usaremos arrays separados para posições, estados de saúde e níveis de inocência. Isso permite que o sistema de física processe movimentos sem carregar dados de diálogo desnecessários na memória.
* **Comptime:** Utilizaremos o `comptime` do Zig para gerar tabelas de busca (look-up tables) para funções trigonométricas e resoluções de texturas em tempo de compilação, economizando ciclos de CPU durante o *runtime*.

## 2. Gerenciamento de Memória (Explicit Allocation)
Não haverá Garbage Collector. O controle será manual e rigoroso:

* **ArenaAllocator:** Para o loop de renderização (frame-by-frame). Toda memória temporária usada para calcular raios e colisões é liberada instantaneamente ao fim de cada quadro.
* **GeneralPurposeAllocator (GPA):** Para o estado persistente do jogo (status do Slayer, inventário de pen-drives e progresso da semana).
* **Pool Allocator:** Para as entidades (Gremlings e Projéteis), garantindo que a criação e destruição constante de inimigos não fragmente a memória.

## 3. O Sistema de Arquivos Personalizado: `.DOOM` (ou `.CORP`)
Para evitar dependências externas e garantir que o Marketing não "leia" nossos segredos, usaremos um formato binário *packed*.

```zig
const AssetHeader = packed struct {
    magic: [4]u8 = "DOOM",
    version: u32 = 1,
    asset_count: u32,
};

const AssetEntry = packed struct {
    id: [16]u8,        // Nome (ex: "S_GREMLIN_IDLE")
    offset: u64,       // Posição no arquivo
    size: u64,         // Tamanho em bytes
    type: AssetType,   // Enum: Texture, Sound, DialogueTree, Map
};
```
* **Decisão:** O carregador de assets usará `Memory Mapped Files` (`mmap` no Linux/POSIX) para que o sistema operacional gerencie o cache de leitura do arquivo `.doom` de forma ultraeficiente.

## 4. O Motor de Renderização: Raycasting 2.5D com "Glitch-Injection"
A engine será um software renderer baseado no algoritmo **DDA (Digital Differential Analyzer)**, similar ao Doom original, mas com uma camada de pós-processamento para o caos.

* **The Glitch Factor:** Quando um Gremling está no campo de visão, ele altera o `VerticalSlice` da renderização.
    * *Implementação:* O raio atinge a parede -> Calcula a altura -> Se o `glitch_factor` for > 0, aplicamos um bitwise XOR nos pixels da coluna ou deslocamos a textura em $Y$ usando um valor aleatório baseado no `frame_count`.
* **Resolution Scaling:** O jogo rodará internamente em 320x200 ou 640x400 (upscaled) para manter a estética retrô e garantir que o "Slayer de 42 anos" se sinta em casa.

## 5. Sistema de NPCs e IA: Inocência vs. Possessão
A IA será baseada em **Máquinas de Estado Finitas (FSM)** simples, porém integradas ao sistema de áudio/visão.

* **Aura de Gerenciamento:** O Slayer possui um raio de influência. Estagiários dentro deste raio recuperam `Innocence` passivamente (presença de liderança).
* **Ray-Casting de Visão de NPC:** Se um Estagiário tiver uma linha de visão desobstruída para um Gremlin ou um Exorcismo em progresso, o valor de `Innocence` sofre um *clamping* negativo imediato.
* **Percussive Exorcism Logic:**
    ```zig
    const PossessionStatus = struct {
        level: f32, // 0.0 a 100.0
        threshold: f32 = 50.0,
        
        pub fn applyHit(self: *PossessionStatus, impact: f32) void {
            self.level -= impact; // Reduz a entidade no corpo
            if (self.level <= 0) triggerGaslightEvent();
        }
    };
    ```

## 6. ZUI (Zoomable User Interface) para Gaslight
O sistema de diálogos não será uma lista estática. Como Arquiteto, definimos uma estrutura de **Grafo de Nós**.

* **Estrutura de Nó:** Cada nó de mentira/gaslight é um ponto em um espaço 2D infinito. Ao escolher uma opção, a câmera faz um *zoom* e *pan* para o próximo conjunto de mentiras.
* **Cringe Modifier:** Se o Slayer (42 anos) usar uma gíria millennial em um momento errado, o peso da dificuldade do próximo nó aumenta em 20%.

---

## Próximos Passos de Implementação (Timeline Técnica):

1.  **Sprint 1 (O Esqueleto):** Setup do `build.zig`, implementação do `ArenaAllocator` e o loop básico do Raycaster (paredes coloridas sem texturas).
2.  **Sprint 2 (A Burocracia):** Implementação do `AssetPacker` para gerar o arquivo `.doom` e carregamento de texturas BMP/PNG brutas.
3.  **Sprint 3 (O Slayer):** Sistema de movimentação, colisão 2D e o HUD de Sanidade/Stamina de 42 anos.
4.  **Sprint 4 (Caos & Mentiras):** Sistema de IA de Gremlings e a primeira versão funcional da árvore de Gaslight.