# Domo

Um produto [Café Labs](https://cafelabs.net).

App de gestão doméstica para famílias e grupos — Android e Web.

## Funcionalidades

- **Autenticação** — e-mail/senha e Google Sign-In
- **Casa** — criar casa, entrar por código de 6 caracteres, gerenciar membros (aprovar, recusar, remover, definir cargo), sair ou deletar a casa
- **Dispensa** — cadastro de itens por categoria com 3 status: *Tem*, *Em falta*, *No carrinho*
- **Lista de Compras** — view filtrada da dispensa; marcar itens no carrinho e atualizar a dispensa em lote
- **Perfil** — foto Google, cargo na casa, toggle de tema (Sistema / Claro / Escuro), logout

---

## Stack

| Camada | Pacote |
|---|---|
| State Management | `flutter_riverpod ^2.6.1` + `riverpod_generator` |
| Navegação | `go_router ^14.8.1` |
| Backend | Firebase Auth + Cloud Firestore |
| Auth social | `google_sign_in ^6.2.0` |
| Modelos | `freezed ^3.0.0` + `json_serializable` |
| Imagens | `cached_network_image ^3.4.1` |
| SVG | `flutter_svg ^2.0.10` |
| Fonte | Google Fonts — Nunito |

---

## Pré-requisitos

- Flutter `^3.27` / Dart `^3.6` instalado em `/home/<user>/flutter/bin/`
- Node.js (para `firebase` CLI, opcional)
- Conta Firebase com projeto configurado

> **WSL2:** Flutter pode travar em loop de `git fetch`. Use `dart` diretamente para
> `build_runner` e `flutter_launcher_icons` (ex: `dart run build_runner build`).
> Se o loop persistir, rode:
> ```bash
> git config --global url."https://".insteadOf git://
> ```

---

## Como rodar

```bash
# 1. Dependências
flutter pub get

# 2. Codegen (freezed + riverpod + json_serializable)
dart run build_runner build --delete-conflicting-outputs

# 3. Android
flutter run -d android

# 4. Web
flutter run -d chrome
```

---

## Build de produção

```bash
# Android (APK)
flutter build apk --release

# Android (AAB — Play Store)
flutter build appbundle --release

# Web
flutter build web --release
```

---

## Ícone do app

Configurado via `flutter_launcher_icons`. Para regenerar após trocar os assets:

```bash
dart run flutter_launcher_icons
```

Assets em `assets/icons/`:
- `icon.png` — 1024×1024, fundo `#F8F5EF` (web + legacy Android)
- `icon_foreground.png` — 1024×1024, fundo transparente (Android adaptive)
- `domo_icon.svg` — logo SVG (AppBar + favicon web)

---

## Arquitetura

**Feature-first + Clean Architecture** — cada feature possui suas próprias camadas de `data`, `domain` e `presentation`.

```
lib/
├── core/
│   ├── constants/
│   ├── providers/          # theme_provider.dart
│   ├── router/             # app_router.dart (go_router)
│   └── theme/              # app_colors, app_spacing, app_theme (light + dark)
├── features/
│   ├── auth/
│   │   ├── data/repositories/
│   │   ├── domain/repositories/
│   │   └── presentation/pages/, providers/
│   ├── casa/
│   │   ├── data/repositories/
│   │   ├── domain/models/, repositories/
│   │   └── presentation/pages/, providers/
│   ├── dispensa/
│   │   ├── data/repositories/
│   │   ├── domain/constants.dart, models/, repositories/
│   │   └── presentation/pages/, providers/, widgets/
│   ├── mercado/
│   │   └── presentation/pages/
│   └── profile/
│       └── presentation/pages/
└── shared/
    └── widgets/            # home_shell.dart, domo_leading_logo.dart
```

---

## Design System — Sage Home

| Token | Valor |
|---|---|
| Primary | `#4A7C59` Verde Sálvia |
| Secondary | `#7D5BA6` Lavanda |
| Tertiary | `#E8A87C` Pêssego |
| Background Light | `#F8F5EF` Creme |
| Background Dark | `#1A1C1E` |
| Surface Light | `#FFFFFF` |
| Surface Dark | `#2B2D30` |

Material Design 3 com suporte nativo a Light e Dark mode via `AppTheme.light` / `AppTheme.dark`.

---

## Modelo de dados (Firestore)

```
casas/{casaId}
  nome, codigo, criadoPor, criadoEm, membrosAtivos[]
  └── membros/{userId}   nome, cargo, fotoUrl, status
  └── itens/{itemId}     nome, categoria, status, atualizadoEm, casaId
```

**Status de item:** `tem` | `nao_tem` | `no_carrinho`

---

## Decisões técnicas

**Providers em sheets/dialogs** — providers com `@riverpod` são auto-dispose. Em `BottomSheet` ou `AlertDialog`, sempre usar `ref.read(repositoryProvider)` diretamente; nunca aguardar um `Future` que dependa de um provider que pode ser descartado enquanto o widget está aberto.

**Botões em `AlertDialog`** — o tema global define `minimumSize: Size(double.infinity, 52)`, o que causa overflow no `OverflowBar`. Sempre sobrescrever em dialogs: `FilledButton.styleFrom(minimumSize: const Size(88, 44))`.

**Cores de erro** — usar sempre `Theme.of(context).colorScheme.error` em elementos interativos (retorna `#BA1A1A` no light e `#FFB4AB` no dark automaticamente).

---

## Roteamento

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

Redirect: não logado → `/auth/login` · logado sem casa → `/casa/gate` · logado com casa em `/auth/*` → `/dispensa`
