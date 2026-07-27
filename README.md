**[Leia em Português](README.pt-br.md)**

# Domo

A [Café Labs](https://cafelabs.net) product.

Household management app for families and groups — Android and Web.

## Features

- **Authentication** — email/password and Google Sign-In
- **Household** — create a household, join via a 6-character code, manage members (approve, reject, remove, set role), leave or delete the household; any active member can reorder the pantry categories for the household (`/casa/categorias`)
- **Pantry** — items registered by category with 3 statuses: *Have*, *Out*, *In cart*; optionally, per item, quantity + minimum stock tracking (status is then computed automatically from those numbers instead of being toggled manually)
- **Shopping List** — filtered view of the pantry; mark items as in cart and batch-update the pantry
- **Profile** — Google photo, household role, theme toggle (System / Light / Dark), language selector (System / Português / English), logout

---

## Stack

| Layer | Package |
|---|---|
| State Management | `flutter_riverpod ^2.6.1` + `riverpod_generator` |
| Navigation | `go_router ^14.8.1` |
| Backend | Firebase Auth + Cloud Firestore |
| Social auth | `google_sign_in ^6.2.0` |
| Models | `freezed ^3.0.0` + `json_serializable` |
| Analytics | `firebase_analytics ^11.4.4` (6 minimal events, no PII — see `docs/ARQUITETURA.md`) |
| Images | `cached_network_image ^3.4.1` |
| SVG | `flutter_svg ^2.0.10` |
| Font | Google Fonts — Bitter (headings) + Manrope (body/UI), fetched dynamically at runtime |
| i18n | `flutter_localizations` + ARB (PT template, EN) |

---

## Prerequisites

- Flutter with Dart SDK `^3.11.4` (per `pubspec.yaml`) — developed and tested
  with Flutter `3.44.4` / Dart `3.12.2`, installed at `/home/<user>/flutter/bin/`
- Node.js (for the `firebase` CLI, optional)
- Firebase account with a configured project

> **WSL2:** Flutter can get stuck in a `git fetch` loop. Use `dart` directly for
> `build_runner` and `flutter_launcher_icons` (e.g. `dart run build_runner build`).
> If the loop persists, run:
> ```bash
> git config --global url."https://".insteadOf git://
> ```

---

## Running

```bash
# 1. Dependencies
flutter pub get

# 2. Codegen (freezed + riverpod + json_serializable)
dart run build_runner build --delete-conflicting-outputs

# 3. Android
flutter run -d android

# 4. Web
flutter run -d chrome
```

---

## Production build

```bash
# Android (APK)
flutter build apk --release

# Android (AAB — Play Store)
flutter build appbundle --release

# Web
flutter build web --release
```

---

## App icon

Configured via `flutter_launcher_icons`. To regenerate after changing assets:

```bash
dart run flutter_launcher_icons
```

Assets in `assets/icons/`:
- `icon.png` — 1024×1024, `#EEF1F1` background (web + legacy Android, the "ceramic stone" tone from the Armário Aberto identity)
- `icon_foreground.png` — 1024×1024, transparent background (Android adaptive)
- `domo_icon.svg` — SVG logo (AppBar + web favicon), already recolored for the Azul Louça palette (`docs/DESIGN.md` §5)

---

## Architecture

**Feature-first + Clean Architecture** — each feature under `lib/features/` has
its own `data` / `domain` / `presentation` layers; state via Riverpod
(code-gen), navigation via `go_router`.

```
lib/
├── core/          # analytics, constants, providers (theme), router, theme
├── features/      # auth, casa (household), dispensa (pantry), mercado (shopping), profile
└── shared/        # widgets shared across features (HomeShell, DomoErrorState...)
```

Deeper dive (layers, provider patterns, routing, technical decisions):
**`docs/ARQUITETURA.md`**.

---

## Design and visual identity

**"Armário Aberto"** ("Open Cabinet") identity — Azul Louça (ceramic blue) palette, Bitter
(headings) + Manrope (body) typography, Material Design 3 with native Light and
Dark mode support via `AppTheme.light` / `AppTheme.dark`. Full tokens, WCAG
contrast, and the rationale behind each decision: **`docs/DESIGN.md`**.

---

## Backend and data

Firebase Auth + Cloud Firestore. Data model, security rules, and the
invite-by-code flow: **`docs/BACKEND.md`**.

---

## Deploy

Firebase Hosting (`app.domo.cafelabs.net`), CI on GitHub Actions, gated manual
deploy via `scripts/deploy.sh`: **`docs/DEPLOY.md`**.
