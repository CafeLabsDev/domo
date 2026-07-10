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
2. **Confirm the client co-change shipped (see "Join-by-code" below).** These
   rules intentionally break the *current* join-by-code flow. Deploying the
   rules WITHOUT the client change will make joining a house fail. They must
   deploy together.
3. **Keep the previous ruleset id.** `firebase deploy` prints/stores it; rules
   roll back with `firebase deploy` of the prior `firestore.rules`. Rules are
   versioned in git here, so the rollback artifact is just the previous commit.
4. Deploy is gated behind the `security` review in this cycle — do not deploy
   until that sign-off exists.

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
| `casas/{id}` delete | owner only |
| `casas/{id}/itens/{itemId}` read/write | **ativo** members only (pendente excluded); status must be `tem`/`nao_tem`/`no_carrinho` |
| `codigos/{CODE}` get | any signed-in user who knows the code |
| `codigos/{CODE}` list | denied (no enumeration) |

Data shape (confirmed against `lib/features/casa` + `lib/features/dispensa`):
items are a **subcollection** `casas/{casaId}/itens/{itemId}` (they do NOT carry
a `casaId` field — it's injected from the path client-side), and the house doc
carries both the embedded `membros` map and the denormalized `membrosAtivos`
list. No composite indexes are needed (all queries are single-field:
`membrosAtivos array-contains`, `codigo ==`, `itens orderBy nome`), hence the
empty `firestore.indexes.json`.

## Required client co-change: join-by-code (`codigos/{CODE}` lookup)

The current join flow queries the whole `casas` collection by `codigo`. **That
query cannot be secured** — Firestore rules cannot force a `where` clause, so
allowing the query at all lets any signed-in user enumerate and read *every*
house. The rules here therefore **deny** that query on purpose.

The secure replacement (rules for it are already in `firestore.rules`):

1. On **create house**: after writing `casas/{id}`, write `codigos/{CODE}` =
   `{ casaId, nome }` (second write, so the ownership `get()` in the rule sees
   the committed house).
2. On **join**: `get codigos/{CODE}` → `casaId` (a get BY ID — you must know the
   6-char code, no enumeration), then the existing self-add-as-`pendente`
   update on `casas/{casaId}`.
3. On **delete house**: also delete `codigos/{CODE}`.

Until `CasaRepositoryImpl` is changed this way, join-by-code will fail under the
new rules — so rules + this client change deploy together (see deploy gate).

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

(If `node` resolves to firebase's bundled binary inside `emulators:exec`, use an
absolute path to a real Node 20+.) Covers: non-member blocked, pendente limited
(reads house, blocked from items), ativo member OK, owner-only approval/removal,
self-join-as-pendente invariants (no self-approve, no `membrosAtivos` insert, no
touching others), self-leave, item status validation, and `codigos` get-only.

## Cost note

Everything above runs on the **Spark free tier** — rules-only enforcement, no
Cloud Functions, no paid backups. If scheduled Firestore backups or a
server-trusted join path (Cloud Function instead of the `codigos` lookup) are
ever wanted, that requires the **Blaze** pay-as-you-go plan (a billing account
with a card). Not needed for this MVP; named here only so the trade-off is
visible, not assumed.
