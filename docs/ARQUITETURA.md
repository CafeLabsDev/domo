# Arquitetura (Domo)

Visão de como o app é montado por dentro. Para o modelo de dados e as regras
de segurança do Firestore, ver `docs/BACKEND.md`. Para os tokens visuais
("Armário Aberto"), ver `docs/DESIGN.md`. Para pipeline/deploy, ver
`docs/DEPLOY.md`.

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
`docs/DESIGN.md` §1).

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
  `/casa/gate`, `/casa/criar`, `/casa/entrar`.

```
/auth/login          LoginPage
/auth/register       RegisterPage
/casa/gate           CasaGatePage
/casa/criar          CriarCasaPage
/casa/entrar         EntrarCasaPage
StatefulShellRoute (NavigationBar)
  /dispensa          DispensaPage
  /mercado           MercadoPage
  /casa              CasaPage
  /perfil            ProfilePage
```

## Tema e identidade visual

`core/theme/` implementa os tokens da identidade **"Armário Aberto"**
(`docs/DESIGN.md`): `AppColors` guarda os hex crus (paleta light/dark, status
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
padrão antigo `Text('Erro: $e')` em toda a base (`docs/DESIGN.md` §4.7).

## Analytics

`core/analytics/analytics_service.dart` é um wrapper fino sobre
`FirebaseAnalytics`, inicializado em `main.dart` sem bloquear o boot
(`unawaited(...).catchError((_) {})` — analytics é opcional e uma falha nele
nunca pode travar a tela branca de inicialização; ver commit
`dc9442e`, que corrigiu exatamente esse caso). Instrumenta só 4 eventos que
rastreiam até as métricas de sucesso do refactor (`casa_criada`,
`casa_entrou`, `item_status_alterado`, `carrinho_fechado`) — nenhum carrega
PII (nome, foto, código de convite), só enums/contagens.

## Backend

Auth (Firebase Auth) e dados (Cloud Firestore) — modelo de dados, regras de
segurança, e o fluxo de join-por-código são documentados em profundidade em
`docs/BACKEND.md`. Resumo de uma linha: `casas/{id}` com um mapa embutido
`membros` (fonte da verdade de autorização) + `itens/{itemId}` como
subcoleção, e uma coleção `codigos/{CODE}` como lookup seguro de convite.

## TODO: confirmar

- `lib/core/constants/app_constants.dart` define `usersCollection`,
  `membersCollection`, `joinRequestsCollection`, `pantryItemsCollection` e os
  status `statusHave`/`statusNeed`/`statusInCart` (valores `'have'`/`'need'`/
  `'in_cart'`). Nenhuma dessas constantes bate com o schema real observado em
  `docs/BACKEND.md` e nos repositórios (coleção é `casas`, membros é um mapa
  embutido — não uma coleção `members`/`join_requests` —, itens vivem em
  `casas/{id}/itens`, e os valores de status reais são `tem`/`nao_tem`/
  `no_carrinho`, definidos em `ItemStatus.firestoreValue`). Confirmado por
  grep que **nenhum símbolo de `AppConstants` é referenciado em lugar nenhum
  do resto de `lib/`** — a classe inteira parece resíduo de uma versão
  anterior do modelo de dados. Não é papel desta doc apagar código; só
  sinalizando para quem decidir se remove.
