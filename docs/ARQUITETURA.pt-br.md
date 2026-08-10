**[Read in English](ARQUITETURA.md)**

# Arquitetura (Domo)

Visão de como o app é montado por dentro. Para o modelo de dados e as regras
de segurança do Firestore, ver `docs/BACKEND.pt-br.md`. Para os tokens visuais
("Armário Aberto"), ver `docs/DESIGN.pt-br.md`. Para pipeline/deploy, ver
`docs/DEPLOY.pt-br.md`.

## Camadas

**Feature-first + Clean Architecture**: cada feature em `lib/features/` tem
suas próprias camadas `data` / `domain` / `presentation`, e cada camada só
conhece a camada abaixo dela através de uma interface abstrata:

```
lib/
├── core/
│   ├── analytics/        # AnalyticsService (wrapper fino sobre Firebase Analytics) + provider
│   ├── constants/        # app_constants.dart — ver nota abaixo
│   ├── providers/        # theme_provider.dart (ThemeMode global)
│   ├── router/           # app_router.dart (go_router, ver seção "Roteamento")
│   └── theme/             # app_colors, app_spacing, app_theme — tokens "Armário Aberto"
├── features/
│   ├── auth/          data/repositories → domain/repositories → presentation/pages,providers
│   ├── casa/          + domain/models (CasaModel, MembroModel via freezed)
│   ├── dispensa/      + domain/models (PantryItem, ItemStatus) e domain/constants.dart (categorias)
│   ├── mercado/       só presentation/ — é uma view derivada da dispensa, sem repositório próprio
│   └── profile/       só presentation/ — lê auth/casa, não tem estado próprio
└── shared/
    └── widgets/        # HomeShell (nav bar), DomoErrorState, DomoLeadingLogo
```

- `domain/repositories/*.dart` — contrato abstrato (interface).
- `data/repositories/*_impl.dart` — implementação concreta contra o Firestore
  (ex.: `CasaRepositoryImpl`, `DispensaRepositoryImpl`).
- `presentation/providers/` — Riverpod: um provider que expõe o repositório
  (`@riverpod` function), providers de stream para dados reativos, e um
  `Controller` (`@riverpod class extends _$X`) para ações que mutam estado
  (`FutureOr<void> build() {}` + métodos que fazem `AsyncValue.guard(...)`).
- `presentation/pages/` e `presentation/widgets/` — UI pura, lê providers via
  `ref.watch`/`ref.read`.

`mercado` e `profile` não têm `data`/`domain` próprios porque não têm modelo
de dados próprio: Mercado é uma leitura filtrada da mesma stream da Dispensa
(itens com `status == noCarrinho`), e Perfil só lê `auth`/`casa`.

## Gerenciamento de estado — Riverpod (code-gen)

Todo provider é gerado via `@riverpod` (annotation) + `build_runner`
(`*.g.dart`), nunca `Provider`/`StateNotifierProvider` manual — convenção
única no projeto, sem mistura de estilos.

Padrões usados:

- **Stream provider** para dados que vêm do Firestore em tempo real (ex.:
  `casaDoUsuario`, `membros`, itens da dispensa) — a UI reage a
  `AsyncValue.when(data:, loading:, error:)` diretamente.
- **Controller** (`@riverpod class ... extends _$X`, estado `FutureOr<void>`)
  para ações (`criarCasa`, `entrarNaCasa`, `atualizarItem`...) — o estado do
  controller carrega só o resultado da última ação (loading/erro daquela
  chamada), não o dado em si (que vive no stream provider correspondente).
- **`StateProvider` simples** só para `themeModeProvider` (não precisa de
  code-gen — é um único valor local, sem lógica assíncrona).

**Decisão registrada — providers auto-dispose em sheets/dialogs:** providers
`@riverpod` são auto-dispose por padrão. Dentro de um `BottomSheet` ou
`AlertDialog`, sempre usar `ref.read(repositoryProvider)` diretamente ao
disparar uma ação — nunca aguardar um `Future` que dependa de um provider que
pode ser descartado enquanto o widget está aberto (o sheet/dialog pode fechar
e desmontar antes do `Future` resolver, matando a referência do provider no
meio do caminho).

**Botões em `AlertDialog`** — o tema global define `minimumSize:
Size(double.infinity, 52)` (`FilledButtonThemeData`/`OutlinedButtonThemeData`
em `app_theme.dart`), o que causa overflow no `OverflowBar` de um
`AlertDialog`. Sempre sobrescrever localmente nesses dialogs:
`FilledButton.styleFrom(minimumSize: const Size(88, 44))` (ex.:
`casa_page.dart:555`).

**Cores de erro** — usar sempre `Theme.of(context).colorScheme.error` em
elementos interativos/destrutivos (logout, remover membro, deletar casa,
status "Em falta"), nunca um hex fixo — resolve automaticamente para o par
`error`/`onError` correto do tema "Armário Aberto" em light e dark (ver
`docs/DESIGN.pt-br.md` §1).

## Roteamento — go_router

`app_router.dart` define um único `GoRouter` (provider `@riverpod`) com:

- **Redirect central** (`_RouterNotifier`, ouve `authStateProvider` +
  `casaDoUsuarioProvider`): não logado → `/auth/login`; logado sem casa →
  `/casa/gate`; logado com casa mas em rota de `/auth/*` ou na gate → home.
  A lógica mora inteiramente no `redirect:` do `GoRouter` — nenhuma página
  decide sozinha para onde navegar no boot.
- **`StatefulShellRoute.indexedStack`** para as 4 rotas com nav bar
  (`/dispensa`, `/mercado`, `/casa`, `/perfil`), preservando o estado de cada
  branch ao trocar de aba (`HomeShell` em `shared/widgets/`).
- Rotas fora do shell (sem nav bar): `/auth/login`, `/auth/register`,
  `/casa/gate`, `/casa/criar`, `/casa/entrar`, `/casa/categorias`.

```
/auth/login          LoginPage
/auth/register       RegisterPage
/casa/gate           CasaGatePage
/casa/criar          CriarCasaPage
/casa/entrar         EntrarCasaPage
/casa/categorias     CategoriaOrdemPage
StatefulShellRoute (NavigationBar)
  /dispensa          DispensaPage
  /mercado           MercadoPage
  /casa              CasaPage
  /perfil            ProfilePage
```

`/casa/categorias` (`categoria_ordem_page.dart`) é uma `ReorderableListView`
para a ordem de exibição das categorias da dispensa naquela casa
(`CasaModel.ordemCategorias`, opcional — `null` cai no `kDispensaCategorias`
hardcoded). Alcançada por um ícone dedicado na `AppBar` da `CasaPage`, fora do
`PopupMenuButton` de ações administrativas/destrutivas, porque qualquer membro
ativo pode reordenar (não é uma ação de dono da casa). Dispensa e Mercado
renderizam as categorias na ordem da casa via o helper
`categoriasOrdenadas(...)` em `dispensa/domain/constants.dart`.

## Tema e identidade visual

`core/theme/` implementa os tokens da identidade **"Armário Aberto"**
(`docs/DESIGN.pt-br.md`): `AppColors` guarda os hex crus (paleta light/dark, status
Tem/Em falta/No carrinho, cores de membro), `AppTheme` monta o `ColorScheme`
completo do Material 3 e o `ThemeData` (tipografia Bitter/Manrope via
`google_fonts`, radii, elevação). Widgets sempre leem
`Theme.of(context).colorScheme`/`textTheme` — `AppColors` só é acessado
diretamente para os tokens que não têm slot no `ColorScheme` (status,
`inkSubtle`, cores de membro).

## Tratamento de erro — `DomoErrorState`

Todo `.when(error: ...)` das 4 páginas principais (Dispensa, Mercado, Casa,
Perfil) usa o widget compartilhado `shared/widgets/domo_error_state.dart` —
ícone + título amigável em português + botão "Tentar novamente" que invalida
o provider correspondente — em vez de expor a exceção crua. Substituiu o
padrão antigo `Text('Erro: $e')` em toda a base (`docs/DESIGN.pt-br.md` §4.7).

## Analytics

`core/analytics/analytics_service.dart` é um wrapper fino sobre
`FirebaseAnalytics`, inicializado em `main.dart` sem bloquear o boot
(`unawaited(...).catchError((_) {})` — analytics é opcional e uma falha nele
nunca pode travar a tela branca de inicialização; ver commit
`dc9442e`, que corrigiu exatamente esse caso). Instrumenta só 6 eventos que
rastreiam até as métricas de sucesso do refactor e das duas features mais
recentes (`casa_criada`, `casa_entrou`, `item_status_alterado`,
`carrinho_fechado`, `item_quantidade_atualizada`,
`casa_ordem_categorias_alterada`) — nenhum carrega PII (nome, foto, código de
convite, nome de item/categoria), só enums/contagens.
`item_quantidade_atualizada` dispara só em edição deliberada do usuário
(`DispensaRepositoryImpl.atualizarQuantidade`), nunca no bump automático de
fechamento de carrinho (`atualizarDispensaEmLote`) — ver doc do método em
`analytics_service.dart` para o porquê dessa distinção.

## Backend

Auth (Firebase Auth) e dados (Cloud Firestore) — modelo de dados, regras de
segurança, e o fluxo de join-por-código são documentados em profundidade em
`docs/BACKEND.pt-br.md`. Resumo de uma linha: `casas/{id}` com um mapa embutido
`membros` (fonte da verdade de autorização) + `itens/{itemId}` como
subcoleção, e uma coleção `codigos/{CODE}` como lookup seguro de convite. O
detalhamento método a método de toda leitura/escrita que o cliente faz
(argumentos, modos de falha, efeitos colaterais) está em
`docs/BACKEND.pt-br.md`, "Superfície de integração".

## Traces ponta a ponta: duas operações representativas

Duas operações, escolhidas porque exercitam a stack de formas genuinamente
diferentes: uma é uma escrita cujo efeito em tempo real é observado de volta
no *mesmo* device que a fez; a outra é uma escrita em um device cujo efeito em
tempo real é observado em um device *completamente diferente*, sem nenhuma
ação do segundo usuário.

### Trace 1 — escrita + atualização em tempo real no mesmo device: ajustar a quantidade de um item

1. **UI**: o usuário toca em `+`/`-` no stepper de quantidade do item da
   dispensa — `_QuantityZone.ajustar(delta)` em
   `lib/features/dispensa/presentation/widgets/pantry_item_card.dart` (essa
   zona só renderiza quando `item.controlaEstoque == true`; itens em modo OFF
   renderizam `_StatusToggleZone` em vez disso — ver a nota de falha abaixo).
2. **Controller**: `DispensaController.atualizarQuantidade(...)`
   (`lib/features/dispensa/presentation/providers/dispensa_controller.dart`)
   lê o uid logado a partir de `authStateProvider` e envolve a chamada em
   `AsyncValue.guard(...)`.
3. **Repositório**: `DispensaRepositoryImpl.atualizarQuantidade`
   (`lib/features/dispensa/data/repositories/dispensa_repository_impl.dart`)
   calcula o status derivado no lado do cliente via
   `PantryItem.statusPorQuantidade(quantidade, estoqueMinimo)`, depois faz um
   único `casas/{casaId}/itens/{itemId}.update({quantidade, estoqueMinimo,
   status, atualizadoEm: serverTimestamp(), atualizadoPor: userId})`.
4. **Backend**: `itemWriteValid()` → `itemOnModeConsistent()` do
   `firestore.rules` (o `controlaEstoque: true` já existente no item sobrevive
   ao merge, já que o update não toca nesse campo) re-deriva o mesmo status no
   servidor e rejeita a escrita se o `status` do cliente discordar — o cliente
   não consegue empurrar um valor derivado desatualizado ou errado.
5. **Propagação em tempo real, mesmo device**: o stream `itensProvider(casaId)`
   já aberto
   (`lib/features/dispensa/presentation/providers/dispensa_provider.dart`,
   apoiado em `DispensaRepositoryImpl.watchItens`) recebe o novo snapshot no
   instante em que o Firestore commita — o Firestore empurra updates pra todo
   listener aberto, incluindo o do próprio device que escreveu — e
   `DispensaPage`
   (`lib/features/dispensa/presentation/pages/dispensa_page.dart`) refaz o
   build via `itensAsync.when(...)`, mostrando a nova quantidade/status sem
   nenhum reload manual.
6. **Caminho de falha**: uma `FirebaseException` (ex.: permission-denied, se o
   chamador foi removido da casa no meio da sessão) é capturada pelo
   `AsyncValue.guard` e cai no estado Riverpod do `DispensaController` como
   `AsyncError` — mas `pantry_item_card.dart` só faz `ref.read` do notifier do
   controller pra chamar o método, nunca faz `ref.listen` pro erro resultante,
   então essa falha em específico hoje é silenciosa do ponto de vista do
   usuário (o valor simplesmente não muda, sem erro exibido). Ver
   `docs/BACKEND.pt-br.md`, "Superfície de integração", pra lista completa das
   telas que de fato exibem erros de controller.

### Trace 2 — leitura em tempo real cross-device: entrar numa casa por código e ser aprovado

Dois usuários diferentes, em dois devices diferentes, um fluxo contínuo.
Diferente do Trace 1 porque a escrita e a leitura em tempo real que reage a
ela acontecem em devices diferentes — o segundo device atualiza puramente
porque sua query ao vivo se reavalia, sem nenhuma ação daquele usuário.

1. **B envia um código de convite**: `EntrarCasaPage`
   (`lib/features/casa/presentation/pages/entrar_casa_page.dart`) chama
   `CasaController.entrarNaCasa(codigo)`
   (`lib/features/casa/presentation/providers/casa_controller.dart`) →
   `CasaRepositoryImpl.entrarNaCasa`
   (`lib/features/casa/data/repositories/casa_repository_impl.dart`): um
   `get codigos/{CODE}` resolve o código pra um `casaId`, depois
   `casas/{casaId}.update({'membros.$userId': {..., status: 'pendente'}})`.
   Regras: `joinAsPending()` — B só pode adicionar a si mesmo, como
   `pendente`.
2. **Tela do próprio B**: o `ref.listen(casaControllerProvider, ...)` de
   `EntrarCasaPage` mostra um snackbar de "pedido de entrada enviado" no
   sucesso. O stream `casaDoUsuarioProvider` de B (`watchCasaDoUsuario`, uma
   query em `membrosAtivos array-contains B.uid`) continua retornando nada — B
   só foi adicionado a `membros`, não a `membrosAtivos` — então o redirect
   central do router (`_RouterNotifier` em `lib/core/router/app_router.dart`)
   mantém B em `CasaGatePage`, a mesma tela genérica de "ainda sem casa"
   mostrada pra qualquer usuário sem casa nenhuma; não existe um estado de UI
   distinto pra "aprovação pendente".
3. **A (o owner) vê o membro pendente**: `CasaPage`
   (`lib/features/casa/presentation/pages/casa_page.dart`) observa
   `membrosProvider(casaId)` (`watchMembros`, um listener do doc
   `casas/{casaId}`), que inclui a entrada de B independente do status, e
   renderiza uma ação de aprovar para entradas pendentes.
4. **A aprova**: toca a ação → `CasaController.aprovarMembro(casaId, B.uid)` →
   `CasaRepositoryImpl.aprovarMembro`:
   `casas/{casaId}.update({'membros.$B.status': 'ativo', 'membrosAtivos':
   FieldValue.arrayUnion([B.uid])})`. Regras: `ownerManages()` — só o owner.
5. **Propagação em tempo real, device de B**: o listener da query
   `watchCasaDoUsuario` de B — aberto o tempo todo, esperando — se reavalia no
   instante em que o Firestore commita a escrita de A, e agora casa com o doc
   da casa (o uid de B acabou de entrar em `membrosAtivos`). O stream emite a
   casa, `casaDoUsuarioProvider` atualiza, o redirect do router percebe que B
   agora tem uma casa e roteia B automaticamente de `/casa/gate` pro shell
   (`/dispensa`) — B nunca dá refresh nem reabre o app; a transição acontece
   ao vivo, movida inteiramente pelo listener aberto.

## TODO: confirmar

- `lib/core/constants/app_constants.dart` define `usersCollection`,
  `membersCollection`, `joinRequestsCollection`, `pantryItemsCollection` e os
  status `statusHave`/`statusNeed`/`statusInCart` (valores `'have'`/`'need'`/
  `'in_cart'`). Nenhuma dessas constantes bate com o schema real observado em
  `docs/BACKEND.pt-br.md` e nos repositórios (coleção é `casas`, membros é um mapa
  embutido — não uma coleção `members`/`join_requests` —, itens vivem em
  `casas/{id}/itens`, e os valores de status reais são `tem`/`nao_tem`/
  `no_carrinho`, definidos em `ItemStatus.firestoreValue`). Confirmado por
  grep que **nenhum símbolo de `AppConstants` é referenciado em lugar nenhum
  do resto de `lib/`** — a classe inteira parece resíduo de uma versão
  anterior do modelo de dados. Não é papel desta doc apagar código; só
  sinalizando para quem decidir se remove.
