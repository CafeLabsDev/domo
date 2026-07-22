# Domo — Identity refactor & core-screen UX spec ("Armário Aberto")

Status: approved direction, ready for implementation by the mobile specialist.
Scope owner: UX/UI design. Implementation owner: mobile (Flutter) specialist —
everything under `lib/core/theme/`, `pubspec.yaml`, and the screens listed in
§4 is theirs to touch. I did not edit any `.dart` file or `pubspec.yaml`.

This replaces the "Sage Home" identity (`#4A7C59` green + Nunito) — which was
built in a hurry alongside the sibling app **Dindin** and ended up reading as
"the same app, different logo" (both green, both Material-3-default-ish) —
with a fully own identity for Domo, rooted in the actual domain (shared
pantry/kitchen/home), not in Dindin's envelope/money metaphor. Same rigor bar
as `dindin/docs/DESIGN.md`: every color pair used for real text below has its
WCAG 2.1 contrast ratio computed (relative luminance → contrast ratio, via a
small script, not eyeballed) and stated next to it, so the mobile specialist
can trust it without re-deriving. AA requires ≥4.5:1 for text under ~18px
regular / ~14px bold, ≥3:1 for larger text and for purely graphical/non-text
objects (e.g. a solid icon or a decorative divider).

---

## 0. Concept: "Armário Aberto" (the open, shared cupboard)

**Metaphor:** Domo is the one cupboard/pantry the whole household can see
into and restock together — not a personal list, not a ledger. Where Dindin
("Envelope caloroso") is warm paper/money — soft pouches, ivory paper, a
serif that reads like a handwritten ledger — Domo is glazed ceramic and
wood: a blue ceramic jar on a shelf, a chalk/paper tag tied to its neck, a
wicker basket by the door. Concretely, this shows up as:

- **A cool "ceramic" canvas** (light gray-blue, not Dindin's warm ivory) —
  the shelf the jars sit on.
- **A cobalt/glaze-blue primary** (`#2C4A7C`, "Azul Louça") instead of any
  green — evokes glazed blue-and-white ceramic dishware/tile, a classic
  "kitchen" cue, and is unambiguously not Dindin's forest green nor its
  petrol-teal categorical accent (`#2E6B78`) — picked with enough hue
  distance from both to read as a different family, not a shifted shade.
- **A mustard/wood accent** (`#8A5F12`, "Mostarda") for the collective,
  standout action — grain, wicker, cabinet-wood tones — instead of Dindin's
  coral/terracotta.
- **Squarer, "label-tag" geometry** for the elements that repeat most often
  (status chips), instead of Dindin's soft full-pill everywhere — a tag
  clipped to a jar, not an envelope flap. Cards stay gently rounded but
  tighter than Dindin's pouch radius (10dp vs. 16dp).
- **A slab serif for headings (Bitter)** instead of Dindin's soft old-style
  serif (Fraunces) — a slab serif reads like a stamped/stencilled label on a
  ceramic jar or a chalkboard pantry sign; it is a different *class* of
  serif (mechanical/sturdy vs. warm/calligraphic), not just a different
  typeface in the same family, so the two apps don't rhyme even at a glance.
- **Member colors** on every avatar (§1.3) — a deliberate "this list belongs
  to the whole house, not to you" signal, and a hook the product spec asked
  for even though per-item attribution ("who marked this") doesn't exist
  yet: the color vocabulary is ready for it without promising it visually
  today (no per-item attribution UI is added in this pass).

**Update — quantity control shipped after this spec, reconciled here:** this
spec originally said the app would carry no quantity/stock-level visuals,
reasoning from a purely-ternary data model (Tem / Em falta / No carrinho).
That's no longer accurate: an **opt-in, per-item** quantity + minimum-stock
control now exists (`PantryItem.controlaEstoque`, default off — every item
that doesn't turn it on keeps looking exactly as this spec originally
describes). What still holds, and was the actual intent behind the original
caveat: **no expiry dates, no progress bars, no richer inventory model** —
this is strictly "a number and a minimum," not a stock-management app.

Concretely, the quantity control (`_QuantityZone`,
`pantry_item_card.dart`) replaces the status-toggle zone *only* on items
that opted in, and was built to slot into the existing visual language
rather than add a new one:
- It reuses the **same tonal container/on-container recipe** as the
  ordinary status chip (§1.1/§4.1 table — `statusTem`/`statusFalta`
  containers), keyed off the item's derived status, so an ON item's zone
  reads at the same visual weight as an OFF item's chip, just with a
  stepper (−, count, +) and a `mín N` caption instead of a status label. No
  new color tokens were introduced for this.
- Status itself is still exactly the same ternary the chip/dot vocabulary
  (§1.1, §4.1) was built for — it's now sometimes *derived* from
  `quantidade`/`estoqueMinimo` instead of always toggled manually, but the
  chip/dot component itself, and everywhere else in the app that reads
  `ItemStatus`, is unchanged.
- The add/edit item sheet (§4.5) gained a toggle + inline quantity/minimum
  fields for existing items — no new component family, same sheet chrome
  and validation-message pattern already specced there.

---

## 1. Color tokens

### 1.1 Light theme

| Token | Hex | Notes |
|---|---|---|
| `primary` | `#2C4A7C` | "Azul Louça" — cobalt ceramic-glaze blue. The identity color. |
| `onPrimary` | `#FFFFFF` | On `primary`: **8.83:1** |
| `primaryContainer` | `#D7E1F0` | Tonal fill (selected nav indicator, invite-code card, `FilledButton.tonal` when explicitly primary-styled) |
| `onPrimaryContainer` | `#16233D` | On `primaryContainer`: **11.86:1** |
| `secondary` | `#63584A` | "Grafite Quente" — warm graphite/taupe, evokes a wood shelf/slate tile. Low-emphasis actions. |
| `onSecondary` | `#FFFFFF` | On `secondary`: **6.94:1** |
| `secondaryContainer` | `#F0E4D0` | |
| `onSecondaryContainer` | `#4A3A22` | On `secondaryContainer`: **8.71:1** |
| `tertiary` (accent) | `#8A5F12` | "Mostarda" — golden/wood ochre. **Used sparingly**: the "No carrinho" status family and any future standout collective action — never blanket UI chrome. |
| `onTertiary` | `#FFFFFF` | On `tertiary`: **5.64:1** |
| `tertiaryContainer` | `#F4E7C8` | |
| `onTertiaryContainer` | `#3E2E10` | On `tertiaryContainer`: **10.67:1** |
| `error` | `#B83A2A` | Brick-red. Reused as `statusFalta` below. |
| `onError` | `#FFFFFF` | **5.71:1** |
| `errorContainer` | `#F9DCD6` | |
| `onErrorContainer` | `#5A2318` | **9.62:1** |
| `background` (scaffold canvas) | `#EEF1F1` | Cool "ceramic stone" gray — the shelf, not Dindin's warm ivory. |
| `surface` (cards, list rows) | `#FFFFFF` | Crisp white "glaze" |
| `surfaceElevated` (dialogs/sheets/menus) | `#FFFFFF` | Same as `surface`; distinguished by elevation, see §3 |
| `inkPrimary` | `#1B2024` | Cool near-black (opposite undertone from Dindin's warm `#211A12`). On `background`: **14.46:1** |
| `inkSecondary` | `#4F5A61` | On `background`: **6.23:1**, on `surface`/white: **7.08:1** |
| `inkSubtle` | `#5A6469` | On `background`: **5.34:1**, on `surface`/white: **6.07:1** — this is the tier used for 12px captions/dates, checked at 4.5:1 not just 3:1. (A lighter first draft, `#6B767C`, gave 4.10:1 on `background` — **fails** AA at caption size — so it was darkened to this value; flagging so the same near-miss isn't reintroduced.) |
| `border`/divider | `#1B2024` at 12% alpha (`0x1F1B2024`) | Decorative hairline only (row dividers, card outline) — same "purely cosmetic, not a meaningful UI boundary" reasoning as Dindin's spec: WCAG's 3:1 non-text rule is generally read as applying to meaningful component boundaries, not cosmetic dividers. |
| `outline` (solid, for real component outlines: default `OutlinedButton`/`TextField` border) | `#5C6B78` | On `background`: **4.83:1**, on `surface`/white: **5.48:1** — both clear 3:1 with margin to spare. |
| `statusTem` (have) | `#286B5C` | "Verde Jade" — a ceramic celadon/jade green, picked with a clearly bluer/cooler undertone than Dindin's yellow-leaning forest green (`#2E6F4D`) so the one unavoidable shared convention (green = "good/have", a near-universal status color both apps legitimately need) still doesn't read as the same swatch. On `surface`/white: **6.27:1** |
| `statusFalta` (need) | `#B83A2A` | Same as `error`. On `surface`/white: **5.71:1** |
| `statusCarrinho` (in cart) | `#8A5F12` | Same as `tertiary` — deliberate: "in the cart" is the one moment the whole household acts together, so it borrows the app's collective-action accent color instead of inventing a fourth hue. On `surface`/white: **5.64:1** |

**Status chip fill/text recipe (important — fixes a live accessibility bug in
today's implementation):** `pantry_item_card.dart`'s `_StatusChip` currently
renders the status color as text directly on top of that *same* color at
12–15% alpha (`color.withValues(alpha: 0.12)`). I checked this exact pattern
against its real backdrop (chip sits directly on `surface`/white, no
wrapping `Card`): the resulting pale tint plus the saturated color as text
lands at **3.6–4.4:1 depending on status** — below the 4.5:1 the label
actually needs at its ~12px size. This is the same failure mode flagged in
Dindin's spec (tinted-alpha container + same-hue text), and it's backdrop-
dependent to boot (breaks differently again in dark mode). Fix, applied
consistently to all three statuses:

- **Dot / solid badge / icon:** use the saturated token directly
  (`statusTem`/`statusFalta`/`statusCarrinho` above) — these already clear
  5.6–6.3:1 with white, so a solid-fill badge with white text is always safe
  if ever needed (e.g. a notification-style count).
- **Everyday tonal chip** (the one used in every pantry-item row today —
  keep this, it's the right visual weight for something repeated dozens of
  times per screen, not solid saturated blocks): use a **dedicated, explicit
  pale container hex per status** (not an alpha blend) + a **dedicated dark
  `onXContainer` hex** — the same recipe as `primaryContainer`/
  `tertiaryContainer` above, not a re-derivation at render time:

| Status | Container fill | On-container text | Ratio |
|---|---|---|---|
| Tem | `#D9EDE7` | `#124338` | **9.13:1** |
| Em falta | `#F9DCD6` (=`errorContainer`) | `#5A2318` (=`onErrorContainer`) | **9.62:1** |
| No carrinho | `#F4E7C8` (=`tertiaryContainer`) | `#3E2E10` (=`onTertiaryContainer`) | **10.67:1** |

  All three land 9–11:1 — comfortable margin for a label that will
  frequently render at 12px. Component spec in §4.1.

### 1.2 Dark theme

| Token | Hex | Notes |
|---|---|---|
| `primary` | `#9BB8DE` | On `background`: **8.84:1** |
| `onPrimary` | `#16233D` | On `primary`: **7.68:1** |
| `primaryContainer` | `#223A61` | |
| `onPrimaryContainer` | `#C9D9F0` | On `primaryContainer`: **7.95:1** |
| `secondary` | `#C9BBA8` | On `background`: **9.58:1** |
| `onSecondary` | `#3A2F22` | On `secondary`: **6.93:1** |
| `secondaryContainer` | `#3F362B` | |
| `onSecondaryContainer` | `#E8DEC9` | On `secondaryContainer`: **8.86:1** |
| `tertiary` | `#E0B84A` | On `background`: **9.55:1** |
| `onTertiary` | `#3E2E10` | On `tertiary`: **6.94:1** |
| `tertiaryContainer` | `#4A3A14` | |
| `onTertiaryContainer` | `#F4E0A8` | On `tertiaryContainer`: **8.43:1** |
| `error` | `#E8897A` | On `background`: **7.12:1** |
| `onError` | `#4A160E` | On `error`: **5.87:1** |
| `errorContainer` | `#4A1B14` | |
| `onErrorContainer` | `#F7CFC5` | On `errorContainer`: **10.07:1** |
| `background` | `#12171C` | Cool near-black, blue-gray undertone (opposite of Dindin's warm brown-black `#16130F`) |
| `surface` (cards) | `#1B2128` | |
| `surfaceElevated` (dialogs/sheets/menus) | `#222932` | |
| `inkPrimary` | `#EDEFF1` | On `background`: **15.64:1** |
| `inkSecondary` | `#B9C1C7` | On `background`: **9.88:1** |
| `inkSubtle` | `#8F9AA1` | On `background`: **6.27:1**, on `surface`: **5.64:1** |
| `border`/divider | `#EDEFF1` at 12% alpha (`0x1FEDEFF1`) | |
| `outline` (solid) | `#8D9AA6` | On `background`: **6.27:1**, on `surface`: **5.64:1** |
| `statusTem` | `#6FC2AC` | On `background`: **8.57:1** |
| `statusFalta` | `#E8897A` | Same as `error`. **7.12:1** |
| `statusCarrinho` | `#E0B84A` | Same as `tertiary`. **9.55:1** |

Dark tonal-chip containers (same recipe as light, deeper fills + light text):

| Status | Container fill | On-container text | Ratio |
|---|---|---|---|
| Tem | `#163F35` | `#BEE8DD` | **8.78:1** |
| Em falta | `#4A1B14` (=`errorContainer`) | `#F7CFC5` (=`onErrorContainer`) | **10.07:1** |
| No carrinho | `#4A3A14` (=`tertiaryContainer`) | `#F4E0A8` (=`onTertiaryContainer`) | **8.43:1** |

### 1.3 Member colors (collectivity signal, avatar identity)

The product brief asked for a visual "this is the whole house's list, not
mine" signal even though per-item attribution isn't built yet. Rather than
invent that feature, this reserves a **member color** — a fixed hue per
household member, used today only as the avatar background (Casa's member
list, Profile's own avatar) when there's no photo, and **ready to extend**
later to a small colored dot on a pantry-item row ("marked by ○") without
inventing a second visual language when that day comes.

6 colors, tuned to the same "glazed ceramic + wood" family as the core
identity (extending `primary`/`tertiary`/`statusTem`/`secondary` rather than
reaching for arbitrary hues), each verified with **white** initials text at
≥5:1 (light) / dark initials text at ≥6:1 (dark) — avatar initials are real
text, not a decorative dot, so they get the same contrast bar as any label:

| # | Name | Light (bg) | On (light, white text) | Dark (bg) | On (dark, dark text) |
|---|---|---|---|---|---|
| 1 | Azul Louça (=`primary`) | `#2C4A7C` | `#FFFFFF` — **8.83:1** | `#9BB8DE` | `#16233D` — **7.68:1** |
| 2 | Mostarda (=`tertiary`) | `#8A5F12` | `#FFFFFF` — **5.64:1** | `#E0B84A` | `#3E2E10` — **6.94:1** |
| 3 | Verde Jade (=`statusTem`) | `#286B5C` | `#FFFFFF` — **6.27:1** | `#6FC2AC` | `#0B2C24` — **7.13:1** |
| 4 | Ameixa | `#6B4A73` | `#FFFFFF` — **7.36:1** | `#C9A0CE` | `#3A1B40` — **6.67:1** |
| 5 | Grafite Quente (=`secondary`) | `#63584A` | `#FFFFFF` — **6.94:1** | `#C9BBA8` | `#3A2F22` — **6.93:1** |
| 6 | Argila | `#A15A34` | `#FFFFFF` — **5.21:1** | `#DDA275` | `#4A2410` — **6.12:1** |

Assignment: deterministic, e.g. hash of `userId` modulo 6 — not user-pickable
in v1 (not asked for, adds a settings surface for no validated need yet).

Usage rule (non-negotiable, same reasoning as Dindin's categorical palette):
member color is **never the sole carrier of identity** — it always sits
behind the member's initial (avatar) or next to their name, which already
carries the actual meaning in `inkPrimary`/`inkSecondary`. 6 hues plus
varied lightness (Mostarda/Argila lighter, Azul Louça/Ameixa darker) helps
grayscale/CVD users too, but the initial/name is the real accessibility
floor here, not hue separation.

---

## 2. Typography

**Heading font: Bitter** (Google Fonts, SIL Open Font License 1.1 — free,
no attribution required). Source:
https://fonts.google.com/specimen/Bitter

**Body/UI font: Manrope** (Google Fonts, OFL 1.1). Source:
https://fonts.google.com/specimen/Manrope

Why this pairing: Bitter is a slab serif originally drawn for on-screen
reading at small sizes — sturdy, mechanical vertical stress, the typographic
equivalent of a stamped or stencilled label on a ceramic jar/chalkboard
pantry sign. That's a different *class* of serif from Dindin's Fraunces
(soft old-style/calligraphic), not just a different cut — the two apps'
headings won't rhyme even glanced at side by side. Manrope carries the
reading/UI load: geometric-humanist, crisp at small sizes, good tabular-
figure support for the 6-character invite code and any future counts;
distinctly more geometric/crisp than Work Sans's rounder humanist warmth,
which is exactly the differentiation this pass needs since both apps sit on
the same Material 3 bones.

**Font delivery — deliberately different from Dindin's approach, flagging
why:** Dindin bundles static `.ttf` weight files as app assets. Domo's
`pubspec.yaml` already depends on `google_fonts: ^6.2.1` and uses it
*dynamically* today (`GoogleFonts.nunitoTextTheme()`,
`app_theme.dart:14`) — no `fonts:` block, no bundled files, the package
fetches+caches the specific weights requested at runtime. I'm recommending
**keeping that existing mechanism** (swap `nunitoTextTheme()` for
`bitterTextTheme()`/`manropeTextTheme()`, and the ad-hoc
`GoogleFonts.nunito(...)` call sites for `GoogleFonts.bitter(...)`/
`GoogleFonts.manrope(...)`) rather than switching Domo to Dindin's
asset-bundling approach. Trade-off, so this is a conscious call and not a
default: bundling is more predictable offline (no first-launch network
fetch) but is genuinely more setup for a solo maintainer (download zips,
manage a `fonts:` block, keep font files in the repo); Domo already made the
opposite, simpler choice for Nunito and it's shipped fine — switching
mechanism *only because the identity changed* would be new maintenance cost
unrelated to this pass's actual goal. If offline-first-launch ever becomes a
real complaint, revisit then.

### Type scale → Flutter `TextTheme`

| Slot | Font | Weight | Size/line-height | Current use in app |
|---|---|---|---|---|
| `displayLarge` | Bitter | 400 | 57/64 | unused, defined for completeness |
| `displayMedium` | Bitter | 400 | 45/52 | unused |
| `displaySmall` | Bitter | 600 | 36/44 | unused; reserved if a future hero number wants more punch |
| `headlineLarge` | Bitter | 600 | 32/40 | unused |
| `headlineMedium` | Bitter | 600 | 28/36 | unused |
| `headlineSmall` | Bitter | 700 | 24/32 | `CasaGatePage` "Sua casa te espera!", `EntrarCasaPage`'s big invite-code input text |
| `titleLarge` | Bitter | 600 | 22/28 | **AppBar page titles** (`DomoPageTitle` — Dispensa/Lista de Compras/nome da casa/Perfil). Today hardcoded to `GoogleFonts.nunito(fontSize:18, w700)` in `appBarTheme.titleTextStyle` (`app_theme.dart:31`) — replace with this theme slot so every screen's header carries the new identity, and stop hardcoding the font/size at the theme-definition call site. |
| `titleMedium` | Manrope | 600 | 16/24 | dialog/section subtitles |
| `titleSmall` | Manrope | 600 | 14/20 | sheet titles ("Novo item"/"Editar item"), card section headers ("Na casa", "Aparência", "Conta") |
| `bodyLarge` | Manrope | 400 | 16/24 | pantry/mercado row item names |
| `bodyMedium` | Manrope | 400 | 14/20 | helper/description text, `EmptyState` body, `InfoTile` subtitle |
| `bodySmall` | Manrope | 400 | 12/16 | footer credit line, least-emphasis captions |
| `labelLarge` | Manrope | 600 | 14/20 | button labels |
| `labelMedium` | Manrope | 700 | 12/16 | status chip labels (apply `letterSpacing: 0.2`), member "Pendente" pill |
| `labelSmall` | Manrope | 700 | 11/16 | uppercase section headers ("LATICÍNIOS", "MEMBROS (3)") — apply `letterSpacing: 1.2` at the call site, same as today's pattern, just on the new font |

Bake the `w600`/`w700` weights directly into `titleLarge`/`titleSmall`/
`labelMedium`/`labelSmall` in the theme definition instead of every screen
doing `.copyWith(fontWeight: ...)` as today (`dispensa_page.dart:135`,
`profile_page.dart:282`, etc.) — purely additive cleanup, existing
`.copyWith()` calls become redundant, never wrong.

**Invite code display** (`casa_page.dart`'s big 6-character code,
`entrar_casa_page.dart`'s input): apply `FontFeature.tabularFigures()` in
addition to the existing `letterSpacing: 6`/`8` — the code mixes letters and
digits, and tabular figures keeps the digits' widths consistent with the
letters' so the fixed letter-spacing doesn't look uneven character-to-
character.

---

## 3. Shape, spacing, elevation

- **Card radius: 10dp** (down from today's 16dp `AppSpacing.radiusLg`) —
  crisper, tile-like, not Dindin's soft pouch. Trivial
  `RoundedRectangleBorder` value change.
- **Input radius: 8dp** (down from today's 12dp `AppSpacing.radiusMd`).
- **Status chip / tag radius: 6dp — NOT a full pill.** This is the single
  biggest tactile differentiator from Dindin (which keeps everything,
  including badges, as a full stadium shape) and it's the *repeated*
  element (every pantry-item row has one), so it's the cheapest, highest-
  payoff shape decision in this whole spec: a squared-off tag reads as a
  label clipped to a jar, not an envelope flap. Same low cost as the radius
  changes above (`_StatusChip`'s `BorderRadius.circular(20)` in
  `pantry_item_card.dart:141` → `BorderRadius.circular(6)`).
- **Buttons (`FilledButton`/`OutlinedButton`/`TextButton`): unchanged, keep
  Material 3's default pill/stadium shape.** Deliberately *not* squaring
  these off too — buttons are large, low-frequency, and already
  differentiated by color; spending the "bold" budget on the high-frequency
  chip shape instead of everywhere keeps this a stack-native, low-
  maintenance change rather than a wholesale custom shape system.
- **Spacing scale:** keep the existing `AppSpacing` steps (4/8/16/24/32/48 +
  radii) — already formalized as constants, no change needed to the scale
  itself, only to the specific radius *values* above.
- **Elevation — decision:** move from today's flat `elevation: 0` (card
  distinguished from background only by an `outlineVariant` hairline, per
  `app_theme.dart:37-44`) to **elevation 1 + hairline border, both at
  once**, `surfaceTintColor: Colors.transparent` explicit on `CardThemeData`
  and on dialog/sheet/menu themes — same reasoning as Dindin's spec: a
  hairline-only card can look flat/generic, a pure shadow with no border can
  look "floaty"; both together read as "a jar resting on a shelf," and it's
  still a native `Card`, no custom `BoxShadow` to hand-roll and maintain.
  - *Why `surfaceTintColor: transparent`:* `app_theme.dart` already builds
    `ColorScheme` explicitly via its constructor (not `.fromSeed`), so it's
    already fully hand-tuned — M3's default auto-tint-toward-primary at
    higher elevations would otherwise quietly shift these exact tokens.
    Turning it off keeps `surface`/`surfaceElevated` exactly as specified
    regardless of elevation. (This constructor choice was already correct
    in the existing code — no change needed there, just adding the
    transparent-tint override alongside the new elevation.)
  - Dialogs/bottom sheets/menus: elevation 3, same override, background =
    `surfaceElevated`.
- **`background`/`surface` role mapping — a correction to make while this
  file is being touched anyway:** today, `scaffoldBackgroundColor` points at
  `colorScheme.surface` and `CardThemeData.color` points at
  `colorScheme.surfaceContainerLowest` (`app_theme.dart:24,38`) — i.e. the
  *card* currently sits in the "recessed/lowest" container slot and the
  *scaffold* sits in the plain "surface" slot. That's backwards relative to
  what those M3 role names are for (surface = "a raised thing," the lowest
  container = "the recessed canvas behind it") and it's what this spec's
  `background`/`surface` tokens assume. Concretely: point
  `scaffoldBackgroundColor` at `colorScheme.surfaceContainerLowest` (→
  `background` token, §1) and `CardThemeData.color`/`inputDecorationTheme
  .fillColor` at `colorScheme.surface` for cards / stay on
  `surfaceContainerLowest` for the input's "recessed slot" look (a text
  field filled with the `background` tone inside a white card reads as a
  cut-in slot, same recipe Dindin uses) — i.e. swap which slot the two
  currently read from, don't invent new roles.

---

## 4. Component specs

### 4.1 Status chip / dot (`PantryItemCard._StatusDot` / `_StatusChip`,
`pantry_item_card.dart`)

- **Dot** (10dp circle, unchanged size): solid `statusTem`/`statusFalta`/
  `statusCarrinho` fill, no border needed (already ≥3:1 non-text against
  both `background` and `surface`).
- **Chip:** `BorderRadius.circular(6)` (was 20 — see §3), fill = the
  status's dedicated container hex (§1.1/§1.2 table, **not** an alpha
  blend of the dot color — this is the accessibility fix), text = the
  matching `onXContainer`, `12px`/`labelMedium`/w700, no border needed (the
  container fill already has enough value-contrast against `surface`/
  `background` to read as a distinct chip without an outline; if a design
  QA pass later wants one anyway, use `border` token at 12% alpha, not a
  solid color, to avoid reintroducing a second saturated ring around an
  already-colored chip).
- Row layout unchanged: dot → 12px gap → name (flex) → 8px gap → chip.

### 4.2 Pantry item row / `PantryItemCard`

- Unchanged interaction model (tap row → edit sheet, swipe-to-delete with
  confirm dialog) — this is already a sound, conventional pattern
  (recognition over recall, error prevention via the confirm step); no
  redesign needed, only the recolor/reshape above.
- "Tem" (have) items: today rendered at 45% opacity + strikethrough. Keep
  that treatment — it's the right "already handled, lower priority" signal
  for a kitchen-glance use case (someone scanning for what to buy shouldn't
  have their eye caught by what they already have).

### 4.3 Mercado (`MercadoPage`)

- Checkbox-circle pattern (`_MercadoItemTile`) unchanged structurally; recolor
  the checked state fill from `AppColors.statusInCart` to `statusCarrinho`
  (same value, new token name) — this is the one place `tertiary`/
  `statusCarrinho` is doing real interactive work (the moment someone
  commits to buying something), which is why the accent color was chosen to
  double as this status: it's rare enough elsewhere to still read as an
  accent, and it lands exactly on the "collective action" moment.
- **Footer CTA button** (`_RodapeBotao`): unchanged structure (full-width
  `FilledButton.icon`, disabled state when `quantidadeNoCarrinho == 0`).
  Recolor is automatic once `ColorScheme` is rebuilt — no direct hex
  references to touch here beyond what's already `Theme.of(context)`-based.
- Section header/divider pattern: unchanged, recolor is automatic
  (`theme.colorScheme.primary` reference already in place).

### 4.4 Bottom navigation (`HomeShell`, 4 destinations)

- Keep native `NavigationBar` — no custom shape/indicator override needed.
  M3's default selected-indicator pill resolves to `secondaryContainer`
  automatically once `ColorScheme` is rebuilt (§1) — no direct styling
  needed in `home_shell.dart`.
- Background = `surface` token (distinct "fixed chrome" panel, not part of
  the scrolling canvas) — matches the `background`/`surface` correction in
  §3 rather than blending into the scaffold.
- Icons/order/labels unchanged (Dispensa/Mercado/Casa/Perfil) — this is
  already the right structure (frequency-ordered: pantry-check and
  shopping are the two things opened constantly, Casa/Perfil rarely) and a
  standard bottom-tab convention; no reason to touch it.

### 4.5 Add/Edit item sheet (`AddEditItemSheet`)

- Structural pattern unchanged (bottom sheet, drag handle via
  `RoundedRectangleBorder` on `showModalBottomSheet`, name field + category
  `DropdownMenu`, primary Save button) — this is the right mobile-native
  affordance for a two-field form; no reason to switch to a dialog even on
  wide/web layouts, given the form is this short (unlike Dindin's longer
  transaction forms, which do need the wide/narrow split).
- **Fix a real gap while this file is being touched anyway (visibility of
  system status, currently missing):** `_save()` today silently `return`s
  when the name is empty (`add_edit_item_sheet.dart:46`) — a user who taps
  "Adicionar" on an empty field sees literally nothing happen. Add inline
  validation: a `_nomeError` message ("Digite um nome para o item.") shown
  under the field the same way Dindin's `_error` pattern works, and/or
  disable the Save button while the trimmed field is empty (`labelMedium`,
  `error` token color, 12px, 6px below the field — see mockup). Same fix
  for the `catch (_)` branch on save failure (line 72) — today it silently
  resets `_isLoading` with no message; add a one-line inline error
  ("Não foi possível salvar. Tente novamente.") in the same slot.
- Field/dropdown chrome recolors automatically via `inputDecorationTheme`
  once §1/§3 land — no direct styling needed in this file beyond the
  validation-message addition above.

### 4.6 Casa / membros (`CasaPage`)

- **Invite-code card:** unchanged structure (icon + label + big code in a
  tonal container) — recolor `primaryContainer`/`onPrimaryContainer`
  (already theme-referenced, `casa_page.dart:157-192`) is automatic. Apply
  the `titleLarge`→`headlineSmall`/Bitter upgrade + tabular figures from §2
  to the code text specifically (it's the one "hero" numeric-ish display in
  this screen, worth the extra visual weight).
- **Member tiles** (`_MembroTile`): give every `CircleAvatar` (this screen's
  member list *and* Profile's own avatar) a **member-color background**
  (§1.3) instead of today's unstyled default when there's no photo —
  deterministic per `userId`, initials in white/dark per §1.3's table. This
  is the concrete "the house sees each other, not just a name" moment the
  product brief asked for.
- **Pending section** ("Aguardando aprovação"): keep the existing
  approve/reject icon-button pair (`check_circle_rounded`/`cancel_rounded`,
  already `statusTem`-green/`error`-red via `colorScheme.primary`/`.error`)
  — this is already a clear, reversible, low-risk pattern (error prevention:
  reject isn't instantly destructive, just un-invites). Add a small
  "Pendente" label pill next to the name (`labelMedium`, outlined — `border`
  token outline, `inkSubtle` text, no fill) so the *admin-only* approve/
  reject icons aren't the only signal that a row is in a different state
  from an active member — a non-admin viewing the same list today sees a
  pending row with no icons and no other cue it's different (the
  admin-gating on the icons already exists, `casa_page.dart:342`, this pill
  is the "what does a non-admin see instead" answer).
- **Permission-gated actions** (delete casa / remove member: admin-only;
  leave casa: non-admin-only) are already correctly gated in code
  (`isAdmin` checks throughout) — no change needed, just recolor.

### 4.7 Empty / error / loading states — audit across Dispensa, Mercado, Casa

- **Empty states** (`Dispensa._EmptyState`, `Mercado._EmptyState`): already
  well-built — icon + title + explanatory body + (Dispensa only) a primary
  CTA. Keep structure, recolor via theme is automatic
  (`theme.colorScheme.primary.withValues(alpha:0.4)` icon tint, etc. — no
  direct hex references to touch). Mercado's empty state intentionally has
  no CTA (there's nothing to *do* from here, the list populates itself from
  Dispensa) — correct, don't add one.
- **Error states — currently a real gap, not cosmetic:** every screen's
  `.when(error: (e, _) => Center(child: Text('Erro: $e')))` (`dispensa_page
  .dart:24,67`, `mercado_page.dart:23,49`, `casa_page.dart:87`,
  `profile_page.dart:30`) surfaces a raw exception string with no icon, no
  friendly copy, no retry action — this fails "error prevention/recognition
  over recall" for the one moment (offline, permission error, etc.) where a
  first-time user most needs reassurance the app didn't just break. Spec: a
  shared `DomoErrorState` widget — warning-triangle icon (`error` token,
  44px), a **friendly, Portuguese, situation-specific title** (not the raw
  exception — e.g. "Não foi possível carregar sua dispensa."), a `bodyMedium`
  subtitle ("Verifique sua conexão com a internet e tente novamente."), and
  an `OutlinedButton.icon` "Tentar novamente" that calls
  `ref.invalidate(...)` on the relevant provider. Replace all four
  `Text('Erro: $e')` call sites with it. (Not asking for per-exception-type
  copy in this pass — one generic friendly message covers the realistic
  cause set for a personal-scale app; revisit only if a specific error class
  becomes common enough to need its own copy.)
- **Loading states:** keep the existing bare `CircularProgressIndicator()`
  pattern everywhere — it already auto-recolors to the new `primary`, and a
  shimmer/skeleton placeholder would be new visual polish with no validated
  need and a real maintenance cost (either a new dependency or hand-rolled
  animated placeholders) for a solo maintainer; not worth it for a v1
  identity pass. Flagging as a considered "no" rather than an oversight.
- **First-run / no-casa-yet** (`CasaGatePage`): already a clean, conventional
  two-path empty state ("Criar uma Casa" primary / "Tenho um código de
  convite" secondary) — recolor via theme is automatic
  (`theme.colorScheme.primary` icon, `headlineSmall`/`bodyLarge` text
  styles already theme-referenced). No structural change; the `headlineSmall`
  slot upgrade to Bitter (§2) is the only visible change here.
- **Join-house flow** (`EntrarCasaPage`): already has real inline validation
  (empty/wrong-length code) and a snackbar for server-side errors
  (invalid/expired code) — no gap here, only the recolor/font pass and the
  tabular-figures addition to the code field noted in §2.

---

## 5. Logo (flag, not a redesign ask)

`assets/icons/domo_icon.svg` is a green geometric house/roof mark in
`#4A7C59` + `#25402D` — both **from the palette this pass replaces**. Unlike
Dindin's logo note (where the old and new greens were merely different
shades of the same hue), this is a bigger mismatch: a green mark next to a
now-blue identity will read as unrelated, not "same brand, older asset."
Because the mark is pure flat-fill geometric shapes (no gradients/texture to
rebuild), recoloring it is a **two-value hex swap** in the existing SVG
(`#4A7C59`→`primary` `#2C4A7C`, `#25402D`→a darker shade of it, e.g.
`#16233D`/`onPrimaryContainer`) — not a redraw. I did not make this edit
(it's not a `.dart` file, but it's still an implementation change outside my
"spec only" boundary for this pass) — recommending the mobile specialist
apply it in the same PR as the theme change, since shipping the new blue
identity next to the old green app icon/logo would immediately undercut the
whole point of this pass.

---

## What I actually did vs. what's left for mobile

- **Wrote this spec** at `/home/felip/projetos/domo/docs/DESIGN.md`.
- **Did not touch** `lib/**`, `pubspec.yaml`, or `assets/icons/domo_icon.svg`
  — per the file-ownership boundary for this task (spec only).
- **Produced an interactive HTML mockup** (light + dark, all core screens:
  Dispensa populated/empty, Mercado populated/empty, Casa with invite code +
  pending + member colors, add-item sheet with the validation fix, the new
  error state, Profile, and a palette/type reference sheet) and rendered
  every screen via Playwright to check contrast and geometry before writing
  the hexes above — not just reasoned about from markup.

## Open questions / flags for the orchestrator

1. **Font delivery mechanism** (§2): kept Domo's existing dynamic
   `google_fonts` fetch instead of switching to Dindin's bundled-static-file
   approach — flagging as a deliberate divergence with a stated trade-off,
   not an oversight.
2. **Logo recolor** (§5): a cheap two-hex-value SVG edit, not a redesign —
   recommended to land in the same pass so the app icon doesn't contradict
   the new identity on day one, but it's outside my file-ownership boundary
   to make myself.
3. **`background`/`surface` role swap** (§3): a correction to which
   `ColorScheme` slot `scaffoldBackgroundColor`/`CardThemeData.color` point
   at, not a new concept — flagging clearly so it reads as "align the
   mapping to what these token names mean" rather than an unexplained
   diff during implementation review.
4. **Status chip contrast fix** (§1.1/§4.1), **silent empty-save / silent
   save-failure gap in the add-item sheet** (§4.5), and **raw exception text
   in error states** (§4.7): three real, pre-existing UX/accessibility gaps
   found while speccing the recolor, not new problems introduced by this
   pass — bundled into this same spec since the mobile specialist is
   already touching these exact files for the identity change, rather than
   filed as separate follow-up tickets.
