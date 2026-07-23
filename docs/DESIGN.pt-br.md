**[Read in English](DESIGN.md)**

# Domo — refactor de identidade & spec de UX das telas principais ("Armário Aberto")

Status: direção aprovada, pronta para implementação pelo especialista mobile.
Dono do escopo: design UX/UI. Dono da implementação: especialista mobile
(Flutter) — tudo em `lib/core/theme/`, `pubspec.yaml`, e as telas listadas em
§4 são responsabilidade dele/dela de mexer. Eu não editei nenhum arquivo
`.dart` nem `pubspec.yaml`.

Isso substitui a identidade "Sage Home" (verde `#4A7C59` + Nunito) — que foi
construída às pressas junto com o app irmão **Dindin** e acabou lendo como
"o mesmo app, logo diferente" (ambos verdes, ambos meio-Material-3-padrão) —
por uma identidade totalmente própria para o Domo, enraizada no domínio real
(despensa/cozinha/casa compartilhada), não na metáfora de envelope/dinheiro
do Dindin. Mesma régua de rigor de `dindin/docs/DESIGN.md`: todo par de cor
usado para texto de verdade abaixo tem sua razão de contraste WCAG 2.1
calculada (luminância relativa → razão de contraste, via um script pequeno,
não no olho) e declarada ao lado, para que o especialista mobile possa
confiar sem precisar re-derivar. AA exige ≥4.5:1 para texto abaixo de ~18px
regular / ~14px bold, ≥3:1 para texto maior e para objetos puramente
gráficos/não-texto (ex.: um ícone sólido ou um divisor decorativo).

---

## 0. Conceito: "Armário Aberto" (o armário/despensa aberto e compartilhado)

**Metáfora:** o Domo é o único armário/despensa que a casa inteira consegue
ver e reabastecer junto — não uma lista pessoal, não um livro-caixa. Onde o
Dindin ("Envelope caloroso") é papel quente/dinheiro — bolsas macias, papel
marfim, uma serifa que lê como um livro-caixa escrito à mão — o Domo é
cerâmica vitrificada e madeira: um pote de cerâmica azul numa prateleira, uma
etiqueta de giz/papel amarrada no gargalo, uma cesta de vime perto da porta.
Concretamente, isso aparece como:

- **Uma tela "cerâmica" fria** (cinza-azulado claro, não o marfim quente do
  Dindin) — a prateleira onde os potes ficam.
- **Um primário azul-cobalto/vidrado** (`#2C4A7C`, "Azul Louça") em vez de
  qualquer verde — evoca louça/azulejo de cerâmica azul e branca vitrificada,
  uma pista clássica de "cozinha", e é inequivocamente diferente tanto do
  verde-floresta do Dindin quanto do seu acento categórico petróleo-teal
  (`#2E6B78`) — escolhido com distância de matiz suficiente de ambos para
  ler como uma família diferente, não um tom deslocado.
- **Um acento mostarda/madeira** (`#8A5F12`, "Mostarda") para a ação coletiva
  em destaque — tons de grão, vime, madeira de armário — em vez do
  coral/terracota do Dindin.
- **Geometria mais quadrada, "etiqueta-tag"** para os elementos que mais se
  repetem (chips de status), em vez do pill cheio e macio do Dindin em tudo
  quanto é lugar — uma etiqueta presa a um pote, não uma aba de envelope. Os
  cards continuam levemente arredondados mas mais apertados que o raio de
  bolsa do Dindin (10dp vs. 16dp).
- **Uma serifa slab para títulos (Bitter)** em vez da serifa old-style/suave
  do Dindin (Fraunces) — uma serifa slab lê como uma etiqueta
  estampada/estêncil num pote de cerâmica ou numa placa de giz de despensa;
  é uma *classe* diferente de serifa (mecânica/robusta vs. quente/
  caligráfica), não só um typeface diferente na mesma família, então os dois
  apps não rimam nem de relance.
- **Cores de membro** em todo avatar (§1.3) — um sinal deliberado de "esta
  lista é de toda a casa, não sua", e um gancho que o spec de produto pediu
  mesmo que a atribuição por item ("quem marcou isso") ainda não exista: o
  vocabulário de cor já está pronto para isso sem prometer visualmente hoje
  (nenhuma UI de atribuição por item é adicionada nesta passada).

**Atualização — controle de quantidade entregue depois deste spec,
reconciliado aqui:** este spec originalmente dizia que o app não carregaria
visuais de quantidade/nível de estoque, raciocinando a partir de um modelo
de dados puramente ternário (Tem / Em falta / No carrinho). Isso não é mais
preciso: agora existe um controle de quantidade + estoque mínimo **opt-in,
por item** (`PantryItem.controlaEstoque`, padrão desligado — todo item que
não o ativa continua exatamente como este spec originalmente descreve). O
que continua valendo, e era a real intenção por trás da ressalva original:
**sem data de validade, sem barras de progresso, sem modelo de inventário
mais rico** — isto é estritamente "um número e um mínimo", não um app de
gestão de estoque.

Concretamente, o controle de quantidade (`_QuantityZone`,
`pantry_item_card.dart`) substitui a zona de toggle de status *só* nos itens
que optaram por ele, e foi construído para se encaixar na linguagem visual
existente em vez de adicionar uma nova:
- Ele reusa a **mesma receita de container tonal/on-container** do chip de
  status comum (tabela §1.1/§4.1 — containers `statusTem`/`statusFalta`),
  chaveada pelo status derivado do item, então a zona de um item ON lê com o
  mesmo peso visual do chip de um item OFF, só que com um stepper (−,
  contagem, +) e uma legenda `mín N` em vez de um label de status. Nenhum
  token de cor novo foi introduzido para isso.
- O status em si continua sendo exatamente o mesmo ternário para o qual o
  vocabulário de chip/dot (§1.1, §4.1) foi construído — agora ele às vezes é
  *derivado* de `quantidade`/`estoqueMinimo` em vez de sempre alternado
  manualmente, mas o componente de chip/dot em si, e todo o resto do app que
  lê `ItemStatus`, continua inalterado.
- A sheet de adicionar/editar item (§4.5) ganhou um toggle + campos inline de
  quantidade/mínimo para itens existentes — nenhuma família de componente
  nova, o mesmo chrome de sheet e padrão de mensagem de validação já
  especificados ali.

---

## 1. Tokens de cor

### 1.1 Tema claro

| Token | Hex | Notas |
|---|---|---|
| `primary` | `#2C4A7C` | "Azul Louça" — azul-cobalto de vidrado cerâmico. A cor da identidade. |
| `onPrimary` | `#FFFFFF` | Em `primary`: **8.83:1** |
| `primaryContainer` | `#D7E1F0` | Preenchimento tonal (indicador de navegação selecionado, card de código de convite, `FilledButton.tonal` quando explicitamente estilizado como primary) |
| `onPrimaryContainer` | `#16233D` | Em `primaryContainer`: **11.86:1** |
| `secondary` | `#63584A` | "Grafite Quente" — grafite/taupe quente, evoca uma prateleira de madeira/azulejo ardósia. Ações de baixa ênfase. |
| `onSecondary` | `#FFFFFF` | Em `secondary`: **6.94:1** |
| `secondaryContainer` | `#F0E4D0` | |
| `onSecondaryContainer` | `#4A3A22` | Em `secondaryContainer`: **8.71:1** |
| `tertiary` (acento) | `#8A5F12` | "Mostarda" — ocre dourado/madeira. **Usado com moderação**: a família de status "No carrinho" e qualquer futura ação coletiva em destaque — nunca chrome geral de UI. |
| `onTertiary` | `#FFFFFF` | Em `tertiary`: **5.64:1** |
| `tertiaryContainer` | `#F4E7C8` | |
| `onTertiaryContainer` | `#3E2E10` | Em `tertiaryContainer`: **10.67:1** |
| `error` | `#B83A2A` | Vermelho-tijolo. Reusado como `statusFalta` abaixo. |
| `onError` | `#FFFFFF` | **5.71:1** |
| `errorContainer` | `#F9DCD6` | |
| `onErrorContainer` | `#5A2318` | **9.62:1** |
| `background` (tela do scaffold) | `#EEF1F1` | Cinza "pedra cerâmica" frio — a prateleira, não o marfim quente do Dindin. |
| `surface` (cards, linhas de lista) | `#FFFFFF` | "Vidrado" branco nítido |
| `surfaceElevated` (dialogs/sheets/menus) | `#FFFFFF` | Igual a `surface`; distinguido pela elevação, ver §3 |
| `inkPrimary` | `#1B2024` | Quase-preto frio (undertone oposto ao `#211A12` quente do Dindin). Em `background`: **14.46:1** |
| `inkSecondary` | `#4F5A61` | Em `background`: **6.23:1**, em `surface`/branco: **7.08:1** |
| `inkSubtle` | `#5A6469` | Em `background`: **5.34:1**, em `surface`/branco: **6.07:1** — este é o tier usado para legendas/datas de 12px, checado em 4.5:1 e não só 3:1. (Um primeiro rascunho mais claro, `#6B767C`, dava 4.10:1 em `background` — **falha** AA no tamanho de legenda — então foi escurecido para este valor; sinalizando para que o mesmo quase-erro não seja reintroduzido.) |
| `border`/divisor | `#1B2024` a 12% de alpha (`0x1F1B2024`) | Só hairline decorativo (divisores de linha, contorno de card) — mesmo raciocínio "puramente cosmético, não uma fronteira de UI significativa" do spec do Dindin: a regra 3:1 de não-texto do WCAG é geralmente lida como aplicável a fronteiras significativas de componente, não divisores cosméticos. |
| `outline` (sólido, para contornos reais de componente: borda padrão de `OutlinedButton`/`TextField`) | `#5C6B78` | Em `background`: **4.83:1**, em `surface`/branco: **5.48:1** — ambos passam o 3:1 com folga de sobra. |
| `statusTem` (tem) | `#286B5C` | "Verde Jade" — um verde celadon/jade cerâmico, escolhido com um undertone claramente mais azulado/frio que o verde-floresta com viés amarelo do Dindin (`#2E6F4D`) para que a única convenção compartilhada inevitável (verde = "bom/tem", uma cor de status quase universal que os dois apps legitimamente precisam) ainda não leia como o mesmo swatch. Em `surface`/branco: **6.27:1** |
| `statusFalta` (falta) | `#B83A2A` | Igual a `error`. Em `surface`/branco: **5.71:1** |
| `statusCarrinho` (no carrinho) | `#8A5F12` | Igual a `tertiary` — deliberado: "no carrinho" é o único momento em que a casa inteira age junto, então ele toma emprestada a cor de acento de ação-coletiva do app em vez de inventar um quarto matiz. Em `surface`/branco: **5.64:1** |

**Receita de preenchimento/texto do chip de status (importante — corrige um
bug de acessibilidade real na implementação de hoje):** o `_StatusChip` de
`pantry_item_card.dart` atualmente renderiza a cor de status como texto
diretamente em cima dessa *mesma* cor a 12–15% de alpha
(`color.withValues(alpha: 0.12)`). Eu chequei esse padrão exato contra seu
fundo real (o chip fica direto em `surface`/branco, sem `Card` envolvendo):
o tingimento pálido resultante mais a cor saturada como texto cai em
**3.6–4.4:1 dependendo do status** — abaixo do 4.5:1 que o label realmente
precisa no seu tamanho de ~12px. Esse é o mesmo modo de falha sinalizado no
spec do Dindin (container de alpha tingido + texto do mesmo matiz), e ainda
por cima depende do fundo (quebra diferente de novo no dark mode). Fix,
aplicado consistentemente aos três status:

- **Dot / badge sólido / ícone:** use o token saturado diretamente
  (`statusTem`/`statusFalta`/`statusCarrinho` acima) — eles já passam
  5.6–6.3:1 com branco, então um badge de preenchimento sólido com texto
  branco é sempre seguro se algum dia for necessário (ex.: uma contagem
  estilo notificação).
- **Chip tonal do dia a dia** (o usado em toda linha de item da despensa
  hoje — mantenha isso, é o peso visual certo para algo repetido dezenas de
  vezes por tela, não blocos saturados sólidos): use um **hex de container
  pálido dedicado e explícito por status** (não um blend de alpha) + um
  **hex escuro dedicado de `onXContainer`** — a mesma receita de
  `primaryContainer`/`tertiaryContainer` acima, não uma re-derivação em
  tempo de renderização:

| Status | Preenchimento do container | Texto on-container | Razão |
|---|---|---|---|
| Tem | `#D9EDE7` | `#124338` | **9.13:1** |
| Em falta | `#F9DCD6` (=`errorContainer`) | `#5A2318` (=`onErrorContainer`) | **9.62:1** |
| No carrinho | `#F4E7C8` (=`tertiaryContainer`) | `#3E2E10` (=`onTertiaryContainer`) | **10.67:1** |

  Os três caem em 9–11:1 — margem confortável para um label que vai
  frequentemente renderizar em 12px. Spec de componente em §4.1.

### 1.2 Tema escuro

| Token | Hex | Notas |
|---|---|---|
| `primary` | `#9BB8DE` | Em `background`: **8.84:1** |
| `onPrimary` | `#16233D` | Em `primary`: **7.68:1** |
| `primaryContainer` | `#223A61` | |
| `onPrimaryContainer` | `#C9D9F0` | Em `primaryContainer`: **7.95:1** |
| `secondary` | `#C9BBA8` | Em `background`: **9.58:1** |
| `onSecondary` | `#3A2F22` | Em `secondary`: **6.93:1** |
| `secondaryContainer` | `#3F362B` | |
| `onSecondaryContainer` | `#E8DEC9` | Em `secondaryContainer`: **8.86:1** |
| `tertiary` | `#E0B84A` | Em `background`: **9.55:1** |
| `onTertiary` | `#3E2E10` | Em `tertiary`: **6.94:1** |
| `tertiaryContainer` | `#4A3A14` | |
| `onTertiaryContainer` | `#F4E0A8` | Em `tertiaryContainer`: **8.43:1** |
| `error` | `#E8897A` | Em `background`: **7.12:1** |
| `onError` | `#4A160E` | Em `error`: **5.87:1** |
| `errorContainer` | `#4A1B14` | |
| `onErrorContainer` | `#F7CFC5` | Em `errorContainer`: **10.07:1** |
| `background` | `#12171C` | Quase-preto frio, undertone azul-acinzentado (oposto ao preto-marrom quente `#16130F` do Dindin) |
| `surface` (cards) | `#1B2128` | |
| `surfaceElevated` (dialogs/sheets/menus) | `#222932` | |
| `inkPrimary` | `#EDEFF1` | Em `background`: **15.64:1** |
| `inkSecondary` | `#B9C1C7` | Em `background`: **9.88:1** |
| `inkSubtle` | `#8F9AA1` | Em `background`: **6.27:1**, em `surface`: **5.64:1** |
| `border`/divisor | `#EDEFF1` a 12% de alpha (`0x1FEDEFF1`) | |
| `outline` (sólido) | `#8D9AA6` | Em `background`: **6.27:1**, em `surface`: **5.64:1** |
| `statusTem` | `#6FC2AC` | Em `background`: **8.57:1** |
| `statusFalta` | `#E8897A` | Igual a `error`. **7.12:1** |
| `statusCarrinho` | `#E0B84A` | Igual a `tertiary`. **9.55:1** |

Containers de chip tonal no dark (mesma receita do claro, preenchimentos
mais profundos + texto claro):

| Status | Preenchimento do container | Texto on-container | Razão |
|---|---|---|---|
| Tem | `#163F35` | `#BEE8DD` | **8.78:1** |
| Em falta | `#4A1B14` (=`errorContainer`) | `#F7CFC5` (=`onErrorContainer`) | **10.07:1** |
| No carrinho | `#4A3A14` (=`tertiaryContainer`) | `#F4E0A8` (=`onTertiaryContainer`) | **8.43:1** |

### 1.3 Cores de membro (sinal de coletividade, identidade de avatar)

O briefing de produto pediu um sinal visual de "esta é a lista de toda a
casa, não só minha" mesmo que a atribuição por item ainda não esteja
construída. Em vez de inventar essa feature, isso reserva uma **cor de
membro** — um matiz fixo por membro da casa, usado hoje só como o fundo do
avatar (lista de membros da Casa, o próprio avatar do Perfil) quando não há
foto, e **pronta para se estender** depois a um pequeno dot colorido numa
linha de item da despensa ("marcado por ○") sem inventar uma segunda
linguagem visual quando esse dia chegar.

6 cores, ajustadas à mesma família "cerâmica vitrificada + madeira" da
identidade central (estendendo `primary`/`tertiary`/`statusTem`/`secondary`
em vez de buscar matizes arbitrários), cada uma verificada com texto de
iniciais **branco** a ≥5:1 (claro) / texto de iniciais escuro a ≥6:1
(escuro) — iniciais de avatar são texto de verdade, não um dot decorativo,
então recebem a mesma régua de contraste de qualquer label:

| # | Nome | Claro (fundo) | On (claro, texto branco) | Escuro (fundo) | On (escuro, texto escuro) |
|---|---|---|---|---|---|
| 1 | Azul Louça (=`primary`) | `#2C4A7C` | `#FFFFFF` — **8.83:1** | `#9BB8DE` | `#16233D` — **7.68:1** |
| 2 | Mostarda (=`tertiary`) | `#8A5F12` | `#FFFFFF` — **5.64:1** | `#E0B84A` | `#3E2E10` — **6.94:1** |
| 3 | Verde Jade (=`statusTem`) | `#286B5C` | `#FFFFFF` — **6.27:1** | `#6FC2AC` | `#0B2C24` — **7.13:1** |
| 4 | Ameixa | `#6B4A73` | `#FFFFFF` — **7.36:1** | `#C9A0CE` | `#3A1B40` — **6.67:1** |
| 5 | Grafite Quente (=`secondary`) | `#63584A` | `#FFFFFF` — **6.94:1** | `#C9BBA8` | `#3A2F22` — **6.93:1** |
| 6 | Argila | `#A15A34` | `#FFFFFF` — **5.21:1** | `#DDA275` | `#4A2410` — **6.12:1** |

Atribuição: determinística, ex.: hash do `userId` módulo 6 — não escolhível
pelo usuário na v1 (não foi pedido, adiciona uma superfície de settings sem
necessidade validada ainda).

Regra de uso (inegociável, mesmo raciocínio da paleta categórica do
Dindin): a cor de membro **nunca é a única portadora de identidade** — ela
sempre fica atrás da inicial do membro (avatar) ou ao lado do seu nome, que
já carrega o significado real em `inkPrimary`/`inkSecondary`. 6 matizes mais
luminosidade variada (Mostarda/Argila mais claros, Azul Louça/Ameixa mais
escuros) também ajuda usuários em escala de cinza/CVD, mas a inicial/nome é
o piso real de acessibilidade aqui, não a separação de matiz.

---

## 2. Tipografia

**Fonte de título: Bitter** (Google Fonts, SIL Open Font License 1.1 —
gratuita, sem atribuição necessária). Fonte:
https://fonts.google.com/specimen/Bitter

**Fonte de corpo/UI: Manrope** (Google Fonts, OFL 1.1). Fonte:
https://fonts.google.com/specimen/Manrope

Por que esse pareamento: Bitter é uma serifa slab originalmente desenhada
para leitura em tela em tamanhos pequenos — robusta, com stress vertical
mecânico, o equivalente tipográfico de uma etiqueta estampada ou estêncil
num pote de cerâmica/placa de giz de despensa. Isso é uma *classe* diferente
de serifa da Fraunces do Dindin (old-style/caligráfica suave), não só um
corte diferente — os títulos dos dois apps não vão rimar nem lado a lado.
Manrope carrega a carga de leitura/UI: geométrica-humanista, nítida em
tamanhos pequenos, bom suporte a números tabulares para o código de convite
de 6 caracteres e quaisquer contagens futuras; nitidamente mais
geométrica/nítida que o calor humanista mais arredondado da Work Sans, que é
exatamente a diferenciação que esta passada precisa já que os dois apps
sentam no mesmo esqueleto Material 3.

**Entrega de fonte — deliberadamente diferente da abordagem do Dindin,
sinalizando o porquê:** o Dindin empacota arquivos `.ttf` estáticos de peso
como assets do app. O `pubspec.yaml` do Domo já depende de
`google_fonts: ^6.2.1` e o usa *dinamicamente* hoje
(`GoogleFonts.nunitoTextTheme()`, `app_theme.dart:14`) — sem bloco `fonts:`,
sem arquivos empacotados, o pacote busca+cacheia os pesos específicos
pedidos em tempo de execução. Estou recomendando **manter esse mecanismo
existente** (trocar `nunitoTextTheme()` por
`bitterTextTheme()`/`manropeTextTheme()`, e os call sites ad-hoc de
`GoogleFonts.nunito(...)` por `GoogleFonts.bitter(...)`/
`GoogleFonts.manrope(...)`) em vez de mudar o Domo para a abordagem de
empacotamento de asset do Dindin. Trade-off, então essa é uma decisão
consciente e não um padrão: empacotar é mais previsível offline (sem busca
de rede no primeiro lançamento) mas é genuinamente mais setup para um
mantenedor solo (baixar zips, gerenciar um bloco `fonts:`, manter arquivos
de fonte no repositório); o Domo já fez a escolha oposta, mais simples, para
a Nunito e ela funciona bem — trocar de mecanismo *só porque a identidade
mudou* seria um custo de manutenção novo sem relação com o objetivo real
desta passada. Se offline-first-launch algum dia virar uma reclamação real,
revisite então.

### Escala tipográfica → `TextTheme` do Flutter

| Slot | Fonte | Peso | Tamanho/altura de linha | Uso atual no app |
|---|---|---|---|---|
| `displayLarge` | Bitter | 400 | 57/64 | não usado, definido por completude |
| `displayMedium` | Bitter | 400 | 45/52 | não usado |
| `displaySmall` | Bitter | 600 | 36/44 | não usado; reservado se um futuro número hero quiser mais impacto |
| `headlineLarge` | Bitter | 600 | 32/40 | não usado |
| `headlineMedium` | Bitter | 600 | 28/36 | não usado |
| `headlineSmall` | Bitter | 700 | 24/32 | "Sua casa te espera!" da `CasaGatePage`, texto grande do input de código de convite da `EntrarCasaPage` |
| `titleLarge` | Bitter | 600 | 22/28 | **Títulos de página no AppBar** (`DomoPageTitle` — Dispensa/Lista de Compras/nome da casa/Perfil). Hoje hardcoded como `GoogleFonts.nunito(fontSize:18, w700)` em `appBarTheme.titleTextStyle` (`app_theme.dart:31`) — substituir por este slot do tema para que o header de toda tela carregue a nova identidade, e parar de hardcodar a fonte/tamanho no call site de definição do tema. |
| `titleMedium` | Manrope | 600 | 16/24 | subtítulos de dialog/seção |
| `titleSmall` | Manrope | 600 | 14/20 | títulos de sheet ("Novo item"/"Editar item"), headers de seção de card ("Na casa", "Aparência", "Conta") |
| `bodyLarge` | Manrope | 400 | 16/24 | nomes de item nas linhas de despensa/mercado |
| `bodyMedium` | Manrope | 400 | 14/20 | texto de ajuda/descrição, corpo do `EmptyState`, subtítulo do `InfoTile` |
| `bodySmall` | Manrope | 400 | 12/16 | linha de crédito do rodapé, legendas de menor ênfase |
| `labelLarge` | Manrope | 600 | 14/20 | labels de botão |
| `labelMedium` | Manrope | 700 | 12/16 | labels do chip de status (aplicar `letterSpacing: 0.2`), pill "Pendente" de membro |
| `labelSmall` | Manrope | 700 | 11/16 | headers de seção em maiúsculas ("LATICÍNIOS", "MEMBROS (3)") — aplicar `letterSpacing: 1.2` no call site, mesmo padrão de hoje, só na fonte nova |

Embuta os pesos `w600`/`w700` diretamente em `titleLarge`/`titleSmall`/
`labelMedium`/`labelSmall` na definição do tema em vez de toda tela fazer
`.copyWith(fontWeight: ...)` como hoje (`dispensa_page.dart:135`,
`profile_page.dart:282`, etc.) — limpeza puramente aditiva, os
`.copyWith()` existentes ficam redundantes, nunca errados.

**Exibição do código de convite** (o código grande de 6 caracteres de
`casa_page.dart`, o input de `entrar_casa_page.dart`): aplique
`FontFeature.tabularFigures()` além do `letterSpacing: 6`/`8` existente — o
código mistura letras e dígitos, e figuras tabulares mantêm a largura dos
dígitos consistente com a das letras para que o letter-spacing fixo não
pareça desigual caractere a caractere.

---

## 3. Forma, espaçamento, elevação

- **Raio de card: 10dp** (reduzido dos 16dp `AppSpacing.radiusLg` de hoje)
  — mais nítido, tipo azulejo, não a bolsa macia do Dindin. Mudança trivial
  de valor de `RoundedRectangleBorder`.
- **Raio de input: 8dp** (reduzido dos 12dp `AppSpacing.radiusMd` de hoje).
- **Raio de chip/tag de status: 6dp — NÃO um pill cheio.** Este é o maior
  diferenciador tátil único do Dindin (que mantém tudo, incluindo badges,
  como uma forma estádio cheia) e é o elemento *repetido* (toda linha de
  item da despensa tem um), então é a decisão de forma mais barata e de
  maior retorno neste spec inteiro: uma tag quadrada lê como uma etiqueta
  presa a um pote, não uma aba de envelope. Mesmo custo baixo das mudanças
  de raio acima (`BorderRadius.circular(20)` do `_StatusChip` em
  `pantry_item_card.dart:141` → `BorderRadius.circular(6)`).
- **Botões (`FilledButton`/`OutlinedButton`/`TextButton`): inalterados,
  mantêm a forma padrão pill/estádio do Material 3.** Deliberadamente *não*
  quadrando esses também — botões são grandes, de baixa frequência, e já
  diferenciados por cor; gastar o "orçamento" de ousadia na forma do chip de
  alta frequência em vez de em tudo mantém isso uma mudança nativa da stack,
  de baixa manutenção, em vez de um sistema de forma customizado por
  completo.
- **Escala de espaçamento:** mantenha os passos existentes do `AppSpacing`
  (4/8/16/24/32/48 + raios) — já formalizados como constantes, nenhuma
  mudança necessária na escala em si, só nos *valores* de raio específicos
  acima.
- **Elevação — decisão:** mover da `elevation: 0` plana de hoje (card
  distinguido do fundo só por um hairline `outlineVariant`, conforme
  `app_theme.dart:37-44`) para **elevação 1 + borda hairline, os dois ao
  mesmo tempo**, `surfaceTintColor: Colors.transparent` explícito no
  `CardThemeData` e nos temas de dialog/sheet/menu — mesmo raciocínio do
  spec do Dindin: um card só-hairline pode parecer plano/genérico, uma
  sombra pura sem borda pode parecer "flutuante"; os dois juntos leem como
  "um pote descansando numa prateleira", e ainda é um `Card` nativo, sem
  `BoxShadow` customizado para construir e manter na mão.
  - *Por que `surfaceTintColor: transparent`:* o `app_theme.dart` já
    constrói o `ColorScheme` explicitamente via seu construtor (não
    `.fromSeed`), então já é totalmente ajustado à mão — o auto-tint padrão
    do M3 em direção ao primary em elevações mais altas, do contrário,
    mudaria silenciosamente esses tokens exatos. Desligar isso mantém
    `surface`/`surfaceElevated` exatamente como especificado
    independentemente da elevação. (Essa escolha de construtor já estava
    correta no código existente — nenhuma mudança necessária ali, só
    adicionando o override de tint transparente junto com a nova elevação.)
  - Dialogs/bottom sheets/menus: elevação 3, mesmo override, fundo =
    `surfaceElevated`.
- **Mapeamento de papel `background`/`surface` — uma correção a fazer já
  que este arquivo está sendo mexido de qualquer forma:** hoje,
  `scaffoldBackgroundColor` aponta para `colorScheme.surface` e
  `CardThemeData.color` aponta para `colorScheme.surfaceContainerLowest`
  (`app_theme.dart:24,38`) — ou seja, o *card* hoje senta no slot de
  container "recuado/mais baixo" e o *scaffold* senta no slot plano de
  "surface". Isso está invertido em relação ao que esses nomes de papel do
  M3 servem (surface = "uma coisa elevada," o container mais baixo = "a
  tela recuada atrás dela") e é o que os tokens `background`/`surface` deste
  spec assumem. Concretamente: aponte `scaffoldBackgroundColor` para
  `colorScheme.surfaceContainerLowest` (→ token `background`, §1) e
  `CardThemeData.color`/`inputDecorationTheme.fillColor` para
  `colorScheme.surface` para cards / fique em `surfaceContainerLowest` para
  o visual de "slot recuado" do input (um campo de texto preenchido com o
  tom de `background` dentro de um card branco lê como um encaixe recuado,
  a mesma receita que o Dindin usa) — ou seja, troque de qual slot os dois
  hoje leem, não invente papéis novos.

---

## 4. Specs de componente

### 4.1 Chip / dot de status (`PantryItemCard._StatusDot` / `_StatusChip`,
`pantry_item_card.dart`)

- **Dot** (círculo de 10dp, tamanho inalterado): preenchimento sólido
  `statusTem`/`statusFalta`/`statusCarrinho`, sem borda necessária (já ≥3:1
  não-texto contra `background` e `surface`).
- **Chip:** `BorderRadius.circular(6)` (era 20 — ver §3), preenchimento = o
  hex de container dedicado do status (tabela §1.1/§1.2, **não** um blend
  de alpha da cor do dot — esse é o fix de acessibilidade), texto = o
  `onXContainer` correspondente, `12px`/`labelMedium`/w700, sem borda
  necessária (o preenchimento do container já tem contraste de valor
  suficiente contra `surface`/`background` para ler como um chip distinto
  sem um contorno; se um passe de QA de design mais tarde quiser um mesmo
  assim, use o token `border` a 12% de alpha, não uma cor sólida, para
  evitar reintroduzir um segundo anel saturado ao redor de um chip já
  colorido).
- Layout de linha inalterado: dot → gap de 12px → nome (flex) → gap de 8px
  → chip.

### 4.2 Linha de item da despensa / `PantryItemCard`

- Modelo de interação inalterado (tocar na linha → sheet de edição, swipe
  para deletar com dialog de confirmação) — esse já é um padrão sólido e
  convencional (reconhecimento em vez de lembrança, prevenção de erro via o
  passo de confirmação) — sem redesign necessário, só o recolor/reshape
  acima.
- Itens "Tem": hoje renderizados a 45% de opacidade + tachado. Mantenha
  esse tratamento — é o sinal certo de "já resolvido, prioridade menor"
  para um caso de uso de olhada rápida na cozinha (alguém escaneando o que
  precisa comprar não deveria ter o olho fisgado pelo que já tem).

### 4.3 Mercado (`MercadoPage`)

- Padrão de checkbox-circle (`_MercadoItemTile`) estruturalmente inalterado;
  recolorir o preenchimento do estado marcado de `AppColors.statusInCart`
  para `statusCarrinho` (mesmo valor, nome de token novo) — esse é o único
  lugar onde `tertiary`/`statusCarrinho` está fazendo trabalho interativo
  de verdade (o momento em que alguém se compromete a comprar algo), que é
  o motivo de a cor de acento ter sido escolhida para dobrar como esse
  status: é rara o suficiente em outros lugares para ainda ler como um
  acento, e cai exatamente no momento de "ação coletiva".
- **Botão CTA do rodapé** (`_RodapeBotao`): estrutura inalterada
  (`FilledButton.icon` de largura total, estado desabilitado quando
  `quantidadeNoCarrinho == 0`). O recolor é automático assim que o
  `ColorScheme` for reconstruído — nenhuma referência direta de hex a mexer
  aqui além do que já é baseado em `Theme.of(context)`.
- Padrão de header/divisor de seção: inalterado, recolor é automático
  (referência a `theme.colorScheme.primary` já existente).

### 4.4 Navegação inferior (`HomeShell`, 4 destinos)

- Mantenha o `NavigationBar` nativo — nenhum override customizado de
  forma/indicador necessário. O indicador selecionado padrão do M3 resolve
  para `secondaryContainer` automaticamente assim que o `ColorScheme` for
  reconstruído (§1) — nenhuma estilização direta necessária em
  `home_shell.dart`.
- Fundo = token `surface` (painel de "chrome fixo" distinto, não parte da
  tela que rola) — combina com a correção `background`/`surface` em §3 em
  vez de se misturar com o scaffold.
- Ícones/ordem/labels inalterados (Dispensa/Mercado/Casa/Perfil) — essa já
  é a estrutura certa (ordenada por frequência: conferir a despensa e
  compras são as duas coisas abertas o tempo todo, Casa/Perfil raramente) e
  uma convenção padrão de aba inferior; nenhum motivo para mexer.

### 4.5 Sheet de adicionar/editar item (`AddEditItemSheet`)

- Padrão estrutural inalterado (bottom sheet, alça de arrastar via
  `RoundedRectangleBorder` em `showModalBottomSheet`, campo de nome +
  `DropdownMenu` de categoria, botão primário Salvar) — essa é a affordance
  nativa mobile certa para um formulário de dois campos; nenhum motivo para
  trocar por um dialog mesmo em layouts largos/web, dado que o formulário é
  tão curto (diferente dos formulários de transação mais longos do Dindin,
  que precisam do split largo/estreito).
- **Corrigir um gap real já que este arquivo está sendo mexido de qualquer
  forma (visibilidade de status do sistema, hoje faltando):** o `_save()`
  hoje faz um `return` silencioso quando o nome está vazio
  (`add_edit_item_sheet.dart:46`) — um usuário que toca em "Adicionar" com
  um campo vazio vê literalmente nada acontecer. Adicione validação inline:
  uma mensagem `_nomeError` ("Digite um nome para o item.") mostrada
  embaixo do campo do mesmo jeito que o padrão `_error` do Dindin funciona,
  e/ou desabilite o botão Salvar enquanto o campo aparado estiver vazio
  (`labelMedium`, cor do token `error`, 12px, 6px abaixo do campo — ver
  mockup). Mesmo fix para o branch `catch (_)` na falha de salvamento
  (linha 72) — hoje ele reseta silenciosamente `_isLoading` sem nenhuma
  mensagem; adicione um erro inline de uma linha ("Não foi possível salvar.
  Tente novamente.") no mesmo slot.
- Chrome de campo/dropdown recolore automaticamente via
  `inputDecorationTheme` assim que §1/§3 forem aplicados — nenhuma
  estilização direta necessária neste arquivo além da adição de mensagem
  de validação acima.

### 4.6 Casa / membros (`CasaPage`)

- **Card de código de convite:** estrutura inalterada (ícone + label +
  código grande num container tonal) — o recolor de
  `primaryContainer`/`onPrimaryContainer` (já referenciado pelo tema,
  `casa_page.dart:157-192`) é automático. Aplique o upgrade
  `titleLarge`→`headlineSmall`/Bitter + figuras tabulares de §2 ao texto do
  código especificamente (é a única exibição numérica-ish "hero" nesta
  tela, vale o peso visual extra).
- **Tiles de membro** (`_MembroTile`): dê a todo `CircleAvatar` (a lista de
  membros desta tela *e* o próprio avatar do Perfil) um **fundo de cor de
  membro** (§1.3) em vez do padrão sem estilo de hoje quando não há foto —
  determinístico por `userId`, iniciais em branco/escuro conforme a tabela
  de §1.3. Esse é o momento concreto de "a casa se vê, não só um nome" que
  o briefing de produto pediu.
- **Seção pendente** ("Aguardando aprovação"): mantenha o par existente de
  ícone-botão de aprovar/rejeitar (`check_circle_rounded`/`cancel_rounded`,
  já verde-`statusTem`/vermelho-`error` via
  `colorScheme.primary`/`.error`) — esse já é um padrão claro, reversível,
  de baixo risco (prevenção de erro: rejeitar não é instantaneamente
  destrutivo, só desconvida). Adicione um pequeno pill de label "Pendente"
  ao lado do nome (`labelMedium`, outlined — contorno do token `border`,
  texto `inkSubtle`, sem preenchimento) para que os ícones de aprovar/
  rejeitar *só de admin* não sejam o único sinal de que uma linha está num
  estado diferente de um membro ativo — um não-admin vendo a mesma lista
  hoje vê uma linha pendente sem ícones e sem nenhuma outra pista de que
  ela é diferente (o gating de admin nos ícones já existe,
  `casa_page.dart:342`, esse pill é a resposta para "o que um não-admin vê
  em vez disso").
- **Ações com gate de permissão** (deletar casa / remover membro: só admin;
  sair da casa: só não-admin) já estão corretamente gated no código
  (checagens de `isAdmin` por todo lado) — nenhuma mudança necessária, só
  recolor.

### 4.7 Estados de vazio / erro / carregamento — auditoria em Dispensa, Mercado, Casa

- **Estados vazios** (`Dispensa._EmptyState`, `Mercado._EmptyState`): já bem
  construídos — ícone + título + corpo explicativo + (só Dispensa) um CTA
  primário. Mantenha a estrutura, o recolor via tema é automático (tint de
  ícone `theme.colorScheme.primary.withValues(alpha:0.4)`, etc. — nenhuma
  referência direta de hex a mexer). O estado vazio do Mercado
  deliberadamente não tem CTA (não há nada para *fazer* daqui, a lista se
  popula sozinha a partir da Dispensa) — correto, não adicione um.
- **Estados de erro — atualmente um gap real, não cosmético:** o
  `.when(error: (e, _) => Center(child: Text('Erro: $e')))` de toda tela
  (`dispensa_page.dart:24,67`, `mercado_page.dart:23,49`,
  `casa_page.dart:87`, `profile_page.dart:30`) expõe uma string de exceção
  crua sem ícone, sem copy amigável, sem ação de retry — isso falha
  "prevenção de erro/reconhecimento em vez de lembrança" para o único
  momento (offline, erro de permissão, etc.) em que um usuário de primeira
  vez mais precisa de garantia de que o app não simplesmente quebrou. Spec:
  um widget `DomoErrorState` compartilhado — ícone de triângulo de aviso
  (token `error`, 44px), um **título amigável, em português, específico à
  situação** (não a exceção crua — ex.: "Não foi possível carregar sua
  dispensa."), um subtítulo `bodyMedium` ("Verifique sua conexão com a
  internet e tente novamente."), e um `OutlinedButton.icon` "Tentar
  novamente" que chama `ref.invalidate(...)` no provider relevante.
  Substitua os quatro call sites de `Text('Erro: $e')` por ele. (Não estou
  pedindo copy por tipo de exceção nesta passada — uma mensagem amigável
  genérica cobre o conjunto realista de causas para um app de escala
  pessoal; revisite só se uma classe de erro específica ficar comum o
  suficiente para precisar de seu próprio copy.)
- **Estados de carregamento:** mantenha o padrão existente de
  `CircularProgressIndicator()` puro em todo lugar — ele já recolore
  automaticamente para o novo `primary`, e um placeholder shimmer/skeleton
  seria polimento visual novo sem necessidade validada e um custo real de
  manutenção (uma dependência nova ou placeholders animados feitos à mão)
  para um mantenedor solo; não vale a pena para uma passada de identidade
  v1. Sinalizando como um "não" considerado em vez de um descuido.
- **Primeira execução / sem-casa-ainda** (`CasaGatePage`): já é um estado
  vazio de dois caminhos limpo e convencional ("Criar uma Casa" primário /
  "Tenho um código de convite" secundário) — o recolor via tema é
  automático (ícone `theme.colorScheme.primary`, estilos de texto
  `headlineSmall`/`bodyLarge` já referenciados pelo tema). Nenhuma mudança
  estrutural; o upgrade do slot `headlineSmall` para Bitter (§2) é a única
  mudança visível aqui.
- **Fluxo de entrar na casa** (`EntrarCasaPage`): já tem validação inline
  real (código vazio/de tamanho errado) e um snackbar para erros do lado do
  servidor (código inválido/expirado) — nenhum gap aqui, só o passe de
  recolor/fonte e a adição de figuras tabulares ao campo de código anotada
  em §2.

---

## 5. Logo (sinalização, não um pedido de redesign)

`assets/icons/domo_icon.svg` é uma marca geométrica verde de casa/telhado em
`#4A7C59` + `#25402D` — ambas **da paleta que esta passada substitui**.
Diferente da nota de logo do Dindin (onde o verde antigo e o novo eram
meros tons diferentes do mesmo matiz), este é um descompasso maior: uma
marca verde ao lado de uma identidade agora azul vai ler como não
relacionada, não "mesma marca, asset mais antigo". Como a marca é formas
geométricas de preenchimento chapado (sem gradientes/textura para
reconstruir), recolori-la é uma **troca de dois valores hex** no SVG
existente (`#4A7C59`→`primary` `#2C4A7C`, `#25402D`→um tom mais escuro
dele, ex.: `#16233D`/`onPrimaryContainer`) — não um redesenho. Eu não fiz
essa edição (não é um arquivo `.dart`, mas ainda é uma mudança de
implementação fora da minha fronteira de "só spec" nesta passada) —
recomendando que o especialista mobile a aplique no mesmo PR da mudança de
tema, já que lançar a nova identidade azul ao lado do ícone/logo verde
antigo do app minaria imediatamente todo o ponto desta passada.

---

## O que eu de fato fiz vs. o que fica para o mobile

- **Escrevi este spec** em `/home/felip/projetos/domo/docs/DESIGN.md`.
- **Não mexi em** `lib/**`, `pubspec.yaml`, nem
  `assets/icons/domo_icon.svg` — conforme a fronteira de ownership de
  arquivo desta tarefa (só spec).
- **Produzi um mockup HTML interativo** (claro + escuro, todas as telas
  principais: Dispensa populada/vazia, Mercado populado/vazio, Casa com
  código de convite + pendentes + cores de membro, sheet de adicionar item
  com o fix de validação, o novo estado de erro, Perfil, e uma folha de
  referência de paleta/tipografia) e renderizei toda tela via Playwright
  para checar contraste e geometria antes de escrever os hexes acima — não
  só raciocinei a partir de markup.

## Perguntas abertas / sinalizações para o orquestrador

1. **Mecanismo de entrega de fonte** (§2): mantive a busca dinâmica
   existente do Domo via `google_fonts` em vez de trocar para a abordagem
   de arquivo estático empacotado do Dindin — sinalizando como uma
   divergência deliberada com um trade-off declarado, não um descuido.
2. **Recolor do logo** (§5): uma edição barata de dois valores hex no SVG,
   não um redesign — recomendado para entrar na mesma passada para que o
   ícone do app não contradiga a nova identidade no dia um, mas está fora
   da minha fronteira de ownership de arquivo para eu mesmo fazer.
3. **Troca de papel `background`/`surface`** (§3): uma correção de qual
   slot do `ColorScheme` `scaffoldBackgroundColor`/`CardThemeData.color`
   apontam, não um conceito novo — sinalizando claramente para que leia
   como "alinhar o mapeamento ao que esses nomes de token significam" em
   vez de um diff sem explicação durante a revisão de implementação.
4. **Fix de contraste do chip de status** (§1.1/§4.1), **gap de
   salvamento-vazio silencioso / falha-de-salvamento silenciosa na sheet de
   adicionar item** (§4.5), e **texto de exceção crua nos estados de erro**
   (§4.7): três gaps reais e pré-existentes de UX/acessibilidade encontrados
   ao especificar o recolor, não problemas novos introduzidos por esta
   passada — agrupados neste mesmo spec já que o especialista mobile já
   está mexendo nesses arquivos exatos para a mudança de identidade, em vez
   de arquivados como tickets de follow-up separados.
