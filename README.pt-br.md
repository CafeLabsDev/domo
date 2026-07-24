**[Read in English](README.md)**

# Domo

Um produto [Café Labs](https://cafelabs.net).

App de gestão doméstica para famílias e grupos — Android e Web.

## Funcionalidades

- **Autenticação** — e-mail/senha e Google Sign-In
- **Casa** — criar casa, entrar por código de 6 caracteres, gerenciar membros (aprovar, recusar, remover, definir cargo), sair ou deletar a casa; qualquer membro ativo pode reordenar as categorias da dispensa da casa (`/casa/categorias`)
- **Dispensa** — cadastro de itens por categoria com 3 status: *Tem*, *Em falta*, *No carrinho*; opcionalmente, por item, controle de quantidade + estoque mínimo (o status passa a ser calculado automaticamente a partir desses números, em vez de alternado manualmente)
- **Lista de Compras** — view filtrada da dispensa; marcar itens no carrinho e atualizar a dispensa em lote
- **Perfil** — foto Google, cargo na casa, toggle de tema (Sistema / Claro / Escuro), seletor de idioma (Sistema / Português / English), logout

---

## Stack

| Camada | Pacote |
|---|---|
| State Management | `flutter_riverpod ^2.6.1` + `riverpod_generator` |
| Navegação | `go_router ^14.8.1` |
| Backend | Firebase Auth + Cloud Firestore |
| Auth social | `google_sign_in ^6.2.0` |
| Modelos | `freezed ^3.0.0` + `json_serializable` |
| Analytics | `firebase_analytics ^11.4.4` (6 eventos mínimos, sem PII — ver `docs/ARQUITETURA.pt-br.md`) |
| Imagens | `cached_network_image ^3.4.1` |
| SVG | `flutter_svg ^2.0.10` |
| Fonte | Google Fonts — Bitter (headings) + Manrope (corpo/UI), buscadas dinamicamente em runtime |
| i18n | `flutter_localizations` + ARB (PT template, EN) |

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
- `icon.png` — 1024×1024, fundo `#EEF1F1` (web + legacy Android, tom "ceramic stone" da identidade Armário Aberto)
- `icon_foreground.png` — 1024×1024, fundo transparente (Android adaptive)
- `domo_icon.svg` — logo SVG (AppBar + favicon web), já recolorido para a paleta Azul Louça (`docs/DESIGN.pt-br.md` §5)

---

## Arquitetura

**Feature-first + Clean Architecture** — cada feature em `lib/features/` tem
suas próprias camadas `data` / `domain` / `presentation`; estado via Riverpod
(code-gen), navegação via `go_router`.

```
lib/
├── core/          # analytics, constants, providers (tema), router, theme
├── features/      # auth, casa, dispensa, mercado, profile
└── shared/        # widgets reutilizados entre features (HomeShell, DomoErrorState...)
```

Aprofundamento (camadas, padrões de provider, roteamento, decisões técnicas):
**`docs/ARQUITETURA.pt-br.md`**.

---

## Design e identidade visual

Identidade **"Armário Aberto"** — paleta Azul Louça, tipografia Bitter
(headings) + Manrope (corpo), Material Design 3 com suporte nativo a Light e
Dark mode via `AppTheme.light` / `AppTheme.dark`. Tokens completos, contraste
WCAG e rationale de cada decisão: **`docs/DESIGN.pt-br.md`**.

---

## Backend e dados

Firebase Auth + Cloud Firestore. Modelo de dados, regras de segurança e o
fluxo de convite por código: **`docs/BACKEND.pt-br.md`**.

---

## Deploy

Firebase Hosting (`app.domo.cafelabs.net`), CI no GitHub Actions, deploy
manual gated via `scripts/deploy.sh`: **`docs/DEPLOY.pt-br.md`**.
