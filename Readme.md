Aqui está a documentação definitiva e consolidada do projeto, pronta para ser a "Bíblia" do desenvolvimento. O tom agora reflete o cansaço crônico de um veterano de 42 anos que só queria pagar a pensão em dia, mas acabou no meio de um apocalipse de jargões e demônios.

---

# 1. Pitch: The Last Coffee Break at D.O.O.M.
**Título:** *The Last Coffee Break at D.O.O.M. (Digital Office Optimized for Marketing)* **Gênero:** *FPS Retrô de "Limpeza" Corporativa e Gestão de Gaslight*

**A Premissa:** A D.O.O.M. inaugurou seu novo QG: um prédio de vidro reluzente construído sobre um vórtice de caos. O Marketing vende o lugar como o "ápice da produtividade", mas a realidade é um Inferno moderno. Gremlings comem os servidores, o RH abriga um lobisomem e o café está sempre queimado.  

Você é **"That Guy"**: 42 anos, divorciado, veterano de mil guerras contra pragas digitais e místicas. Você foi contratado pelo RH — o único setor que sabe a verdade — sob o disfarce de "Programador Jr.". Vestindo seu melhor moletom de startup e usando gírias millennials datadas, sua missão é dupla:  
1. **Exterminar e Exorcizar:** Eliminar as criaturas do caos e descer a porrada (exorcismo por percussão) nos colegas possuídos.  
2. **Gerir a Inocência:** Como gestor de um time de estagiários reais e ingênuos, você deve protegê-los do horror, fazendo *gaslight* constante para que eles continuem achando que o "sangue na parede" é apenas um "vazamento de toner magenta".

---

# 2. Game Design Document (GDD)

## 2.1 O Protagonista: The Hired Slayer
* **Arquétipo:** O "Tio" do TI que tenta ser *cool*.  
* **Debuffs de Idade:** A Stamina cai mais rápido após os 40. Se correr demais, a visão treme e ele solta um áudio de "estou velho demais pra isso".  
* **Armamento:** Teclados mecânicos pesados (exorcismo), Crachá de Aço (corte), Pen-drives de interferência e Café Extra-Forte (Power-up).

## 2.2 Loop de Gameplay
1. **Receber Ticket:** O RH envia uma missão secreta via canal criptografado.  
2. **Navegar e Eliminar:** Percorrer o labirinto 2.5D eliminando Gremlings e "rebootando" possuídos sem ser visto pelos "Normies".  
3. **Gaslight Social:** Se for pego com uma mão no monstro e outra no teclado, aciona o **ZUI de Manipulação**. Use jargões millennials para convencer a testemunha de que aquilo é "cultura ágil".  
4. **Proteção da Equipe:** Seus liderados estão no mapa. Se um Gremlin se aproximar, você deve agir rápido ou a "Barra de Inocência" deles cai, gerando pedidos de demissão e pânico.

## 2.3 Sistema de Facções
* **RH (The Handlers):** Seus chefes reais. Te dão armas e acesso, mas exigem discrição total.  
* **Marketing (The Chaos Causers):** Inconscientemente convidam demônios. São os inimigos mais irritantes, atacando com "projéteis de sinergia".  
* **Estagiários Liderados (The Assets):** Devem ser mantidos vivos e ignorantes. São sua maior fonte de estresse e pontos de bônus.

---

# 3. Notas Técnicas (Zig Architecture)

Arquiteto, para o Gemini começar a gerar código funcional, use estas estruturas como base.

## 3.1 O Sistema de Identidade e Atributos
O Slayer tem atributos que influenciam o renderizador e a física.

```zig
const Slayer = struct {
    age: u8 = 42,
    stamina: f32 = 100.0,
    caffeine_level: f32 = 0.0,
    cringe_factor: f32 = 100.0, // Eficácia do Gaslight em millennials
    
    // O RH sabe quem ele é
    is_hired_slayer: bool = true,
};

const Intern = struct {
    name: []const u8,
    innocence: f32 = 100.0, // Se chegar a 0, Game Over por escândalo
    current_task: []const u8 = "Refactoring Java",
};
```

## 3.2 O Engine de Exorcismo (Hitbox e State)
Diferente do Doom clássico, nem tudo que você bate deve morrer.

```zig
const EntityState = enum {
    normal,
    possessed, // Precisa de porrada (exorcismo)
    glitched,  // Afeta o renderizador (Gremlings)
    unconscious // Pós-exorcismo, pronto para Gaslight
};

fn applyPercussiveExorcism(target: *Entity, force: f32) void {
    if (target.state == .possessed) {
        target.possession_gauge -= force;
        if (target.possession_gauge <= 0) {
            target.state = .unconscious;
            // Trigger ZUI: Iniciar diálogo de Gaslight "Dinâmica de Grupo"
        }
    }
}
```

## 3.3 Estrutura de Missão (RH-Encrypted)
As missões vêm do "Digital Office" como se fossem tarefas comuns.

```zig
const Mission = struct {
    official_title: []const u8, // "Ajuste de Ar-condicionado"
    slayer_objective: []const u8, // "Matar o Lobisomem no setor 4"
    cover_story: []const u8, // "Estávamos apenas testando a acústica da sala"
};
```

---

### Próximo Passo Sugerido:
Agora que o mundo está mapeado, por onde quer que o Gemini comece a digitar?

1. **A lógica de IA dos Estagiários Liderados:** Criar o sistema de "Inocência" e como eles reagem aos horrores no prédio.
2. **O Sistema de Gaslight Millennial:** Rascunhar a árvore de diálogos e o mini-game de convencer as pessoas de que a violência é normal.
3. **O Raycaster de "Visão de Veterano":** O código em Zig para a renderização básica que sofre interferência (glitches) dos Gremlings.

**Qual o seu primeiro commit, Slayer?**