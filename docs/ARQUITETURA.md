**[Leia em Português](ARQUITETURA.pt-br.md)**

# Architecture (Domo)

An overview of how the app is put together internally. For the data model and
Firestore security rules, see `docs/BACKEND.md`. For the visual design tokens
("Armário Aberto"), see `docs/DESIGN.md`. For the pipeline/deploy, see
`docs/DEPLOY.md`.

## Layers

**Feature-first + Clean Architecture**: each feature under `lib/features/`
has its own `data` / `domain` / `presentation` layers, and each layer only
knows the layer below it through an abstract interface:

```
lib/
├── core/
│   ├── analytics/        # AnalyticsService (thin wrapper over Firebase Analytics) + provider
│   ├── constants/        # app_constants.dart — see note below
│   ├── providers/        # theme_provider.dart (global ThemeMode)
│   ├── router/           # app_router.dart (go_router, see "Routing" section)
│   └── theme/             # app_colors, app_spacing, app_theme — "Armário Aberto" tokens
├── features/
│   ├── auth/          data/repositories → domain/repositories → presentation/pages,providers
│   ├── casa/          + domain/models (CasaModel, MembroModel via freezed)
│   ├── dispensa/      + domain/models (PantryItem, ItemStatus) and domain/constants.dart (categories)
│   ├── mercado/       presentation/ only — a view derived from the pantry, no repository of its own
│   └── profile/       presentation/ only — reads auth/casa, no state of its own
└── shared/
    └── widgets/        # HomeShell (nav bar), DomoErrorState, DomoLeadingLogo
```

- `domain/repositories/*.dart` — abstract contract (interface).
- `data/repositories/*_impl.dart` — concrete implementation against Firestore
  (e.g. `CasaRepositoryImpl`, `DispensaRepositoryImpl`).
- `presentation/providers/` — Riverpod: a provider that exposes the
  repository (`@riverpod` function), stream providers for reactive data, and
  a `Controller` (`@riverpod class extends _$X`) for actions that mutate
  state (`FutureOr<void> build() {}` + methods that do
  `AsyncValue.guard(...)`).
- `presentation/pages/` and `presentation/widgets/` — pure UI, reads
  providers via `ref.watch`/`ref.read`.

`mercado` and `profile` don't have their own `data`/`domain` because they
don't have their own data model: Mercado is a filtered read of the same
Dispensa stream (items with `status == noCarrinho`), and Perfil only reads
`auth`/`casa`.

## State management — Riverpod (code-gen)

Every provider is generated via `@riverpod` (annotation) + `build_runner`
(`*.g.dart`), never a manual `Provider`/`StateNotifierProvider` — a single
convention across the project, with no mixing of styles.

Patterns used:

- **Stream provider** for data that comes from Firestore in real time (e.g.
  `casaDoUsuario`, `membros`, pantry items) — the UI reacts directly to
  `AsyncValue.when(data:, loading:, error:)`.
- **Controller** (`@riverpod class ... extends _$X`, state `FutureOr<void>`)
  for actions (`criarCasa`, `entrarNaCasa`, `atualizarItem`...) — the
  controller's state only carries the result of the last action
  (loading/error for that call), not the data itself (which lives in the
  corresponding stream provider).
- **Plain `StateProvider`** only for `themeModeProvider` (doesn't need
  code-gen — it's a single local value, no async logic).

**Recorded decision — auto-dispose providers in sheets/dialogs:** `@riverpod`
providers are auto-dispose by default. Inside a `BottomSheet` or
`AlertDialog`, always use `ref.read(repositoryProvider)` directly when firing
an action — never await a `Future` that depends on a provider that may be
disposed while the widget is open (the sheet/dialog can close and unmount
before the `Future` resolves, killing the provider reference mid-flight).

**Buttons in `AlertDialog`** — the global theme sets `minimumSize:
Size(double.infinity, 52)` (`FilledButtonThemeData`/`OutlinedButtonThemeData`
in `app_theme.dart`), which causes overflow in an `AlertDialog`'s
`OverflowBar`. Always override locally in those dialogs:
`FilledButton.styleFrom(minimumSize: const Size(88, 44))` (e.g.
`casa_page.dart:555`).

**Error colors** — always use `Theme.of(context).colorScheme.error` on
interactive/destructive elements (logout, remove member, delete house,
"Em falta" status), never a fixed hex — it automatically resolves to the
correct `error`/`onError` pair of the "Armário Aberto" theme in light and
dark (see `docs/DESIGN.md` §1).

## Routing — go_router

`app_router.dart` defines a single `GoRouter` (provider `@riverpod`) with:

- **Central redirect** (`_RouterNotifier`, listens to `authStateProvider` +
  `casaDoUsuarioProvider`): not logged in → `/auth/login`; logged in without
  a house → `/casa/gate`; logged in with a house but on an `/auth/*` route or
  on the gate → home. The logic lives entirely in the `GoRouter`'s
  `redirect:` — no page decides on its own where to navigate at boot.
- **`StatefulShellRoute.indexedStack`** for the 4 routes with a nav bar
  (`/dispensa`, `/mercado`, `/casa`, `/perfil`), preserving each branch's
  state when switching tabs (`HomeShell` in `shared/widgets/`).
- Routes outside the shell (no nav bar): `/auth/login`, `/auth/register`,
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

`/casa/categorias` (`categoria_ordem_page.dart`) is a `ReorderableListView`
for the display order of the pantry categories in that house
(`CasaModel.ordemCategorias`, optional — `null` falls back to the hardcoded
`kDispensaCategorias`). Reached via a dedicated icon in `CasaPage`'s
`AppBar`, outside the administrative/destructive `PopupMenuButton`, because
any active member can reorder (it isn't a house-owner action). Dispensa and
Mercado render categories in the house's order via the
`categoriasOrdenadas(...)` helper in `dispensa/domain/constants.dart`.

## Theme and visual identity

`core/theme/` implements the tokens of the **"Armário Aberto"** identity
(`docs/DESIGN.md`): `AppColors` holds the raw hex values (light/dark palette,
Tem/Em falta/No carrinho status, member colors), `AppTheme` builds the
complete Material 3 `ColorScheme` and `ThemeData` (Bitter/Manrope typography
via `google_fonts`, radii, elevation). Widgets always read
`Theme.of(context).colorScheme`/`textTheme` — `AppColors` is only accessed
directly for tokens that have no slot in `ColorScheme` (status, `inkSubtle`,
member colors).

## Error handling — `DomoErrorState`

Every `.when(error: ...)` in the 4 main pages (Dispensa, Mercado, Casa,
Perfil) uses the shared `shared/widgets/domo_error_state.dart` widget — icon
+ friendly title in Portuguese + a "Tentar novamente" ("Try again") button
that invalidates the corresponding provider — instead of exposing the raw
exception. It replaced the old `Text('Erro: $e')` pattern across the
codebase (`docs/DESIGN.md` §4.7).

## Analytics

`core/analytics/analytics_service.dart` is a thin wrapper over
`FirebaseAnalytics`, initialized in `main.dart` without blocking boot
(`unawaited(...).catchError((_) {})` — analytics is optional and a failure in
it must never freeze the app on a white startup screen; see commit
`dc9442e`, which fixed exactly that case). It instruments only 6 events that
track the refactor's success metrics and the two most recent features
(`casa_criada`, `casa_entrou`, `item_status_alterado`, `carrinho_fechado`,
`item_quantidade_atualizada`, `casa_ordem_categorias_alterada`) — none of
them carry PII (name, photo, invite code, item/category name), only
enums/counts. `item_quantidade_atualizada` only fires on a deliberate user
edit (`DispensaRepositoryImpl.atualizarQuantidade`), never on the automatic
bump from closing the cart (`atualizarDispensaEmLote`) — see the method's doc
comment in `analytics_service.dart` for why that distinction exists.

## Backend

Auth (Firebase Auth) and data (Cloud Firestore) — the data model, security
rules, and the join-by-code flow are documented in depth in
`docs/BACKEND.md`. One-line summary: `casas/{id}` with an embedded `membros`
map (source of truth for authorization) + `itens/{itemId}` as a subcollection,
and a `codigos/{CODE}` collection as a secure invite lookup.

## TODO: confirmar

- `lib/core/constants/app_constants.dart` defines `usersCollection`,
  `membersCollection`, `joinRequestsCollection`, `pantryItemsCollection`, and
  the statuses `statusHave`/`statusNeed`/`statusInCart` (values `'have'`/
  `'need'`/`'in_cart'`). None of these constants match the real schema
  observed in `docs/BACKEND.md` and in the repositories (the collection is
  `casas`, members are an embedded map — not a `members`/`join_requests`
  collection —, items live in `casas/{id}/itens`, and the real status values
  are `tem`/`nao_tem`/`no_carrinho`, defined in `ItemStatus.firestoreValue`).
  Confirmed by grep that **no `AppConstants` symbol is referenced anywhere
  else in `lib/`** — the whole class looks like a leftover from an earlier
  version of the data model. It isn't this doc's role to delete code; just
  flagging it for whoever decides whether to remove it.
