**[Leia em Português](BACKEND.pt-br.md)**

# Backend / security notes (Domo)

Operational reference for Domo's Firestore backend. Read this before any deploy
that touches `firestore.rules` or `firestore.indexes.json`.

Project: `domo-8b336` · Plan: **Spark (free)** · Auth: Firebase Auth ·
DB: Cloud Firestore.

## Deploy gate: BACKUP FIRST, and deploy is a deliberate human step

Deploying rules to `domo-8b336` is **NOT automatic**. It is a manual,
reviewed action. Before running any `firebase deploy --only firestore:rules`:

1. **Back up production first.** On Spark there is no scheduled Firestore
   backup (that needs a paid plan). Do a manual export before any rules change:
   `gcloud firestore export gs://<bucket>` if a bucket is available, OR, at MVP
   scale, manually copy the current `casas` docs from the Firebase console.
   This is the only rollback for user data.
2. **Confirm the client co-change shipped — all THREE edits (see "Join-by-code"
   below).** These rules intentionally break the *current* join-by-code flow.
   Deploying the rules WITHOUT the client change will make joining a house fail.
   Rules + all three client edits ship in the SAME deploy. The gate must verify
   the three together — a partial client change (e.g. `criarCasa` writing
   `codigos` but `entrarNaCasa` still querying `casas` by `codigo`) is as broken
   as no change at all. The three edits:
   - `criarCasa` writes `codigos/{CODE} = {casaId, nome}` after the house doc.
   - `entrarNaCasa` does `get codigos/{CODE}` → `casaId` (no more `casas` query).
   - `deletarCasa` deletes `codigos/{CODE}` alongside the house.
3. **Backfill `codigos/{CODE}` for PRE-EXISTING houses FIRST.** Houses created
   before this change have a `codigo` field but no `codigos/{CODE}` lookup doc,
   so once the new rules ship, `entrarNaCasa`'s `get codigos/{CODE}` returns
   null for them and **join-by-code breaks for every existing house** (members
   stay in; invites break). Before the rules deploy, create
   `codigos/{codigo} = {casaId, nome}` for every existing house — manually in
   the console for a pilot's handful of houses, or via the idempotent
   `scripts/backfill/` script if there are too many (that script needs a
   service-account key — a credential Domo otherwise lacks; trade-off named in
   `docs/DEPLOY.md`'s "Backfill"). Gate order: **backup → backfill → deploy
   rules + client → smoke test.** `scripts/deploy.sh` step 3 blocks the rules
   deploy until the backfill is confirmed.
4. **Keep the previous ruleset id.** `firebase deploy` prints/stores it; rules
   roll back with `firebase deploy` of the prior `firestore.rules`. Rules are
   versioned in git here, so the rollback artifact is just the previous commit.
5. Deploy is gated behind the `security` review in this cycle — do not deploy
   until that sign-off exists.

**Note on this cycle's additions (item quantity control + category order):**
both land in the SAME `firestore.rules` file as the `codigos` join-by-code
change above, so the same gate/checkpoints apply — but unlike `codigos`, they
need **no backfill** (step 3 above). Both new fields
(`controlaEstoque`/`quantidade`/`estoqueMinimo`/`noCarrinho` on items,
`ordemCategorias` on the house) are optional and treated as legally absent by
the rules — every pre-existing document is valid as-is with the new rules,
no pre-deploy data migration required. Do not conflate the two: `codigos`
needed a backfill because the OLD join flow becomes unusable without it; these
two features don't change any existing flow's behavior, they only add new
opt-in ones.

## Current state of rules found in production (as of this change)

**Could not read the live published ruleset** from this environment: the
sandbox blocks access tokens (`gcloud auth print-access-token`,
`firebase login:ci`), and firebase-tools has no first-party "get published
rules" command, no cached ruleset in `.firebase/`, and there was never a
`firestore` block in `firebase.json` — so nothing in this repo has ever
deployed rules. Whatever is live was set by hand in the console.

**What the client code proves the live rules MUST currently allow — and why
that is almost certainly wide open:** `CasaRepositoryImpl.entrarNaCasa` runs
`casas.where('codigo', ==, X)` as a *non-member* and then writes itself into
the house doc. For that to work today, the live rules must permit an arbitrary
authenticated user to **query the whole `casas` collection** and **write to a
house they don't belong to**. In practice that means the project is running on
something at least as permissive as `allow read, write: if request.auth != null`
(any signed-in user can read/write any house), possibly fully open. Treat
production as effectively unprotected until the rules in this repo are reviewed
and deployed. This is the reason the ticket was flagged urgent.

## New security model (what `firestore.rules` here enforces)

Posture: **default-deny**. Only the matched paths are reachable; every other
path and every non-allowed operation is denied.

Authorization is always read off the **`membros` map** (the source of truth),
never off `membrosAtivos` (a denormalized cache the client query uses). A
forged `membrosAtivos` entry cannot grant read/write, because every check reads
`membros`.

Key point that differs from the ticket brief: **`cargo` is cosmetic and grants
nothing.** The app's own `isAdmin` is `casa.criadoPor == uid` — so the
management boundary in the rules is **ownership (`criadoPor`), not `cargo`.**

| Path | Who |
| --- | --- |
| `casas/{id}` get | member of that house (ativo OR pendente) |
| `casas/{id}` list | only the `membrosAtivos array-contains <uid>` stream (own houses) |
| `casas/{id}` create | signed-in user, as the sole `ativo` owner (`criadoPor == uid`) |
| `casas/{id}` update — join | a non-member adds ONLY themselves as `pendente`; cannot self-approve, cannot enter `membrosAtivos`, cannot touch others or house metadata |
| `casas/{id}` update — manage | the **owner** only: approve (`pendente`→`ativo` + `membrosAtivos`), remove/refuse, edit `cargo`, rename. `criadoPor`/`criadoEm`/`codigo` immutable |
| `casas/{id}` update — leave | a member removes ONLY themselves (map + `membrosAtivos`) |
| `casas/{id}` update — category order | any **ativo** member sets ONLY `ordemCategorias` (see "Per-house category order" below) |
| `casas/{id}` delete | owner only |
| `casas/{id}/itens/{itemId}` read/write | **ativo** members only (pendente excluded); write validated by `itemWriteValid()` — status must be `tem`/`nao_tem`/`no_carrinho`, plus the quantity-control invariants (see "Optional item quantity control" below) |
| `codigos/{CODE}` get | any signed-in user who knows the code |
| `codigos/{CODE}` list | denied (no enumeration) |

Data shape (confirmed against `lib/features/casa` + `lib/features/dispensa`):
items are a **subcollection** `casas/{casaId}/itens/{itemId}` (they do NOT carry
a `casaId` field — it's injected from the path client-side), and the house doc
carries both the embedded `membros` map and the denormalized `membrosAtivos`
list. No composite indexes are needed (all queries are single-field:
`membrosAtivos array-contains`, `codigo ==`, `itens orderBy nome`), hence the
empty `firestore.indexes.json`.

Two fields added this cycle, both **optional and purely additive** — no schema
migration, no backfill, existing docs are valid as-is because absence is a
legal value for both:

- `casas/{id}.ordemCategorias` (`List<String>?`) — see "Per-house category
  order" below.
- `casas/{casaId}/itens/{itemId}.controlaEstoque` / `.quantidade` /
  `.estoqueMinimo` / `.noCarrinho` — see "Optional item quantity control"
  below.

## New in this cycle: optional item quantity control

Per-item, opt-in stock control (`PantryItem.controlaEstoque`, default
`false`). OFF-mode items (the default, and every pre-existing item — the
field is simply absent on them) behave **exactly as before**: manual 3-value
`status`, cart tracked by the `no_carrinho` status value. ON-mode items add:

- `quantidade` / `estoqueMinimo` — non-negative ints.
- `status` is **derived, not manual**: `quantidade <= estoqueMinimo` ⇒
  `nao_tem`, else `tem`. The rules pin the stored value to that derivation
  (`itemOnModeConsistent()` in `firestore.rules`) so the denormalization can
  never drift — a client can't write an ON-mode item with a `status` that
  disagrees with its own `quantidade`/`estoqueMinimo`.
- `noCarrinho` (bool) carries "in the cart this trip" for ON-mode items
  instead of the status enum (`no_carrinho` as a `status` value is rejected
  for ON-mode items — `itemOnModeConsistent()` only allows `tem`/`nao_tem`).
  OFF-mode items reject a stray `noCarrinho: true` (`itemOffModeConsistent()`)
  so the two modes' cart signal never overlaps.

`itemWriteValid()` (`firestore.rules`) is the single gate for both modes on
every item `create`/`update`: validates types/ranges for the four new fields
regardless of mode, then branches into the ON- or OFF-mode consistency check
above. It composes with the existing `isActiveMemberOf(casaId)` check — same
membership boundary as before, this only adds field-shape/consistency
validation on top.

## New in this cycle: per-house category order

`casas/{id}.ordemCategorias` (`List<String>?`) — a per-house display order for
the 8 hardcoded dispensa categories (`kDispensaCategorias` in
`dispensa/domain/constants.dart`). This feature does **not** add category
CRUD — the 8 categories themselves stay hardcoded in the client; only their
*order* is stored per house. `null` (every pre-existing house) falls back to
the hardcoded order client-side (`categoriasOrdenadas(...)`).

Rules add a fourth `casas/{id}` update flow, `editOrdemCategorias()`: any
**ativo** member (checked off the `membros` map, same source of truth as
everywhere else in this file) may update the house doc **if and only if**
`ordemCategorias` is the *only* key in the diff
(`next().diff(prev()).affectedKeys().hasOnly(['ordemCategorias'])`) — so this
path cannot be used to smuggle a change to `membros`, `membrosAtivos`,
`criadoPor`/`criadoEm`/`codigo`, or anything else. The three pre-existing
update flows (`joinAsPending`, `selfLeave`) were additionally hardened to
explicitly reject touching `ordemCategorias` through *their* paths (a pendente
joining, or anyone leaving, cannot also sneak in a category-order change in
the same write) — closing a hole that would otherwise exist because Firestore
rules `update` checks are evaluated as "does at least one flow's predicate
match the whole diff," not per-field.

Shape validation is intentionally shallow: `ordemCategorias is list` and
`.size() <= 20`. Rules do **not** check that the list is exactly the 8 known
category strings with no duplicates — that's deliberately left to the client,
to avoid hardcoding the category name strings into `firestore.rules` (which
would couple the rules file to a client-side constant list that can change
without a rules deploy). `categoriasOrdenadas(...)` is defensive against a
malformed/stale list anyway (drops unknown strings, appends any known category
missing from it), so a rules bug or a manually-edited doc can't hide a
category from the grouped views even without server-side dedup.

Reached in the app via a dedicated `AppBar` icon on `CasaPage` (route
`/casa/categorias`, `CategoriaOrdemPage`) — deliberately *not* inside the
admin/destructive `PopupMenuButton`, since (unlike delete-casa/remove-member)
this is available to any active member, not just the owner.

## Required client co-change: join-by-code (`codigos/{CODE}` lookup)

The current join flow queries the whole `casas` collection by `codigo`. **That
query cannot be secured** — Firestore rules cannot force a `where` clause, so
allowing the query at all lets any signed-in user enumerate and read *every*
house. The rules here therefore **deny** that query on purpose.

The secure replacement (rules for it are already in `firestore.rules`) is
**three edits to `CasaRepositoryImpl`**, all required, all shipped together:

1. **`criarCasa`** (currently `casa_repository_impl.dart` ~L56-63): today it
   writes ONLY `casas/{id}` and never touches `codigos`. Add a second write:
   `codigos/{CODE} = { casaId, nome }`, AFTER the house doc exists (the rule's
   ownership `get()` must see the committed house). `{CODE}` is the doc id.
2. **`entrarNaCasa`** (currently ~L81-84, `casas.where('codigo', ==, X)`):
   replace the collection query with `get codigos/{CODE}` → `casaId` (a get BY
   ID — you must already know the 6-char code, no enumeration), then keep the
   existing self-add-as-`pendente` update on `casas/{casaId}`.
3. **`deletarCasa`** (currently ~L160-162, deletes only the house): also delete
   `codigos/{CODE}` so codes don't dangle.

Until all three land, join-by-code fails under the new rules — so rules + these
three edits deploy together (see deploy gate step 2). The rules test suite
covers the server side of all three (`codigos` create/delete owner-only,
get-by-id resolve, list denied).

## Post-deploy smoke test (there is no staging)

Spark has no separate staging project, so the only end-to-end verification is
against `domo-8b336` itself, right after deploy, with throwaway accounts. Do
this before considering the deploy done:

1. Two test Auth accounts (A and B).
2. As A: create a house. Confirm the house doc AND a `codigos/{CODE}` doc both
   appear (proves the `criarCasa` co-change wrote the mapping).
3. As B: join by that code. Confirm B lands as `pendente` and can read the
   house but not its items.
4. As A: approve B. Confirm B now appears in `membrosAtivos`, B's stream shows
   the house, and B can read/write items.
5. As B: leave. Confirm B is gone from both `membros` and `membrosAtivos`, and
   A is still present in `membrosAtivos` (the self-leave integrity fix).
6. As A: delete the house. Confirm both the house doc and `codigos/{CODE}` are
   gone. Clean up the test accounts.

## Accepted risk: join-code brute force (pilot-scoped)

The join code is 6 chars. At the app's charset it is roughly **~29.7 bits** of
entropy, and on Spark there is **no server-side rate limit** on the
`get codigos/{CODE}` lookup (rate limiting a read would need a Cloud Function
gatekeeper, i.e. Blaze). So a determined attacker could, in principle, script
guesses against the lookup. At pilot scale (a handful of houses among a 6-char
space of ~1e9) a random guess almost never hits a live code, and the blast
radius of one hit is one house's grocery list — **accepted FOR THE PILOT.**

Before onboarding real users beyond the pilot:
- **Enable Firebase App Check (free on Spark).** It blocks lookups from clients
  that aren't the genuine app, which shuts down scripted brute force without any
  paid plan. This is the recommended next hardening step and costs nothing.
- A true server-side rate limit / lockout (per-IP or per-account throttling on
  the resolve) would require moving the join resolve into a **Cloud Function**,
  which needs the **Blaze** pay-as-you-go plan. Named as a trade-off, not
  assumed — App Check should be tried first since it's free.

## Deferred advisories (LOW severity, recorded not fixed)

- **Owner self-leave orphans the house.** The rules let an owner take the
  self-leave path (they are a member). If they do, they drop out of `membros`
  and `membrosAtivos` — losing `read`, since reads are keyed off `membros` — but
  `criadoPor` still points at them, so they keep `delete`/`ownerManages` rights
  and no one else is promoted to owner. The house is left with members but no
  reachable owner. Low impact at MVP (the app's UI doesn't offer "leave" to the
  owner), so deferred post-MVP. A proper fix is either blocking owner self-leave
  in the rules or transferring `criadoPor` on leave — both need a client flow,
  so they belong to the same wave as ownership transfer.
- **`codigos` doc id not validated against `casa.codigo`.** An owner could
  create a mapping whose id differs from their house's `codigo` field. Harmless
  post-migration: joining resolves via the mapping's id, so `casa.codigo`
  becomes decorative and the id is the real code. Enforcing equality would cost
  a second `get()` for no security gain. Noted in `firestore.rules`; deferred.
- **`itens` writes don't pin `atualizadoPor == uid()`.** Considered as
  hardening but NOT applied: the client's `atualizarItem` (name/category edit,
  `dispensa_repository_impl.dart` ~L44-54) updates an item WITHOUT rewriting
  `atualizadoPor`, so a rule requiring `next().atualizadoPor == uid()` on every
  update would reject that legitimate flow (the field keeps a prior user's uid).
  The write is already gated to `ativo` members of the house, so the only gap is
  cosmetic attribution within a trusted household. Deferred; revisit only if the
  client is changed to always stamp `atualizadoPor`.

## User data: export & deletion (privacy baseline)

Data is shared inside a house, so a user's personal footprint is their entry in
`casas/{id}.membros[uid]` (`nome`, `cargo`, `fotoUrl`) plus the items they last
touched (`itens.*.atualizadoPor == uid`).

- **Deletion (self-service, already in the app):** `sairDaCasa` removes the
  user's own `membros[uid]` entry and pulls them from `membrosAtivos` — the
  rules' self-leave path allows exactly this. Full account deletion (the Auth
  user itself) is a manual console step at this stage.
- **Export (manual, documented — acceptable at MVP):** read the user's
  `casas/{id}` doc (their `membros[uid]` slice) and the house's `itens` from the
  Firebase console or an admin script. There is no in-app export yet; add one
  before onboarding real users beyond the pilot.

## Testing

`test/rules/` is a standalone Node harness (its own `package.json`, isolated
from `pubspec.yaml`). It runs against the **local emulator only, never
production**. From the repo root:

```
firebase emulators:exec --only firestore --project domo-rules-test \
  "node --test test/rules/rules.test.mjs"
```

(`node` inside `emulators:exec` resolves to firebase's bundled pkg binary, which
does NOT support `--test`; pass an absolute path to a real Node 20+ as above.)

**77 tests, all passing.** Covers: non-member blocked, pendente limited (reads
house, blocked from items), ativo member OK, owner-only approval/removal,
self-join-as-pendente invariants (no self-approve, no `membrosAtivos` insert, no
touching others, no two-key add, no deleting another's key), self-leave
including the integrity guard (a leaver CANNOT strip other uids from
`membrosAtivos`), owner-immutability of `criadoPor`/`criadoEm`/`codigo`, item
status validation, `codigos` get-only + owner-only create/delete + extra-field
rejection + update-denied, and unauthenticated writes denied on
`casas`/`itens`/`codigos`. The self-leave griefing test is a regression guard:
it passes only because of the three-line `next == prev \ {uid}` pin in
`selfLeave()`; removing that pin makes it fail (verified).

Also covers the optional item quantity control (ON-mode derived-status pinned
to `quantidade <= estoqueMinimo`, non-negative-int validation, `no_carrinho`
rejected as a derived status, OFF-mode unchanged incl. stray `noCarrinho:true`
rejected) and per-house `ordemCategorias` (active-member-only edit, pendente/
non-member denied, list-shape validated, and the join/manage/leave update flows
proven intact and un-smuggleable through the new path).

## Cost note

Everything above runs on the **Spark free tier** — rules-only enforcement, no
Cloud Functions, no paid backups. If scheduled Firestore backups or a
server-trusted join path (Cloud Function instead of the `codigos` lookup) are
ever wanted, that requires the **Blaze** pay-as-you-go plan (a billing account
with a card). Not needed for this MVP; named here only so the trade-off is
visible, not assumed.
