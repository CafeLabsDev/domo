# Deploy, CI, and rollback

Operational guide for a solo maintainer running/debugging Domo's deploy
without rebuilding context. Read `docs/BACKEND.md` first for *why* the deploy
gate exists (backup-first, and the rules + three-part client co-change that
must ship together for join-by-code) — this file is the *how*, plus CI and
rollback.

Project: `domo-8b336` · Plan: **Spark (free)** · Hosting:
`app.domo.cafelabs.net` (Firebase Hosting). There is no separate
staging project — Spark's single project doubles as the only environment,
which is why the post-deploy smoke test in `docs/BACKEND.md` runs against
production itself, right after deploy.

## CI (`.github/workflows/ci.yml`)

Runs on every push to `master`. Two independent jobs, both on GitHub Actions'
free tier (public/private repo, this volume of pushes — nowhere near the
2,000 free minutes/month):

- **`flutter`** — `flutter pub get && flutter analyze && flutter test` (57
  tests).
- **`rules`** — spins up the Firestore emulator (`firebase-tools
  emulators:exec`) and runs `test/rules/rules.test.mjs` against it (77 tests
  covering the default-deny rules model described in `docs/BACKEND.md`:
  membership, ownership, pendente/ativo boundaries, `codigos` lookup, item
  quantity control, per-house category order, etc.). Uses the emulator only
  — never touches production, needs no project credentials.

CI does **not** deploy anything. It's a safety net for the code; shipping to
production is still the deliberate manual action below.

**Known testability gap (not a bug, recorded so it isn't rediscovered):**
`DispensaRepositoryImpl`'s constructor only takes an optional `analytics` —
unlike `CasaRepositoryImpl` (which also accepts an injectable `firestore`
client), it always resolves `FirebaseFirestore.instance` internally. That
means its write methods (`atualizarItem`, `atualizarQuantidade`,
`atualizarDispensaEmLote`, etc.) can't be driven against
`fake_cloud_firestore` the way `CasaRepositoryImpl`'s writes are — the 57
Dart tests cover the dispensa domain/presentation layers and widget behavior,
but not `DispensaRepositoryImpl`'s Firestore writes directly (those paths are
only exercised indirectly, end-to-end, via the rules emulator suite and
manual/production use). Worth constructor-injecting `firestore` there too as
a follow-up, mirroring the pattern `casa` already uses.

To debug a CI failure locally, run the same commands: `flutter analyze`,
`flutter test`, or

```bash
npx --yes firebase-tools emulators:exec --only firestore --project domo-rules-test \
  "npm test --prefix test/rules"
```

(See `docs/BACKEND.md`'s Testing section for the two-terminal manual variant
and a note on a `node --test` quirk with locally-installed firebase-tools
binaries — CI sidesteps it by running everything through the Node 20 that
`actions/setup-node` puts on `PATH`.)

## Deploying (`scripts/deploy.sh`)

Encodes the release gate from `docs/BACKEND.md` ("Deploy gate: BACKUP FIRST")
as a script with hard checkpoints, so a step can't be skipped by accident:

1. Interactive confirmation that production data was backed up (manual
   export/console copy per `docs/BACKEND.md` — Spark has no scheduled
   Firestore backup). Aborts if not confirmed.
2. Interactive confirmation that **all three** client co-changes for
   join-by-code (`criarCasa`, `entrarNaCasa`, `deletarCasa` — see
   `docs/BACKEND.md`'s "Required client co-change" section) are included in
   this deploy, if `firestore.rules` is part of it. Aborts if not confirmed.
   Skip this checkpoint (answer accordingly) for a hosting-only change that
   doesn't touch rules.
3. Interactive confirmation that the **`codigos` backfill for pre-existing
   houses is already done** (see "Backfill" below), if `firestore.rules` is
   part of this deploy. Aborts if not confirmed. Skipped for a hosting-only
   change. This is the step that stops the new rules from breaking
   join-by-code for every house that predates this change.
4. Runs `flutter analyze` + `flutter test`, then the rules emulator suite —
   aborts the deploy if either fails.
5. Final interactive confirmation showing exactly what will run.
6. `firebase deploy --only firestore:rules --project domo-8b336` (only if
   `firestore.rules` changed).
7. `flutter build web` + `firebase deploy --only hosting --project
   domo-8b336`.

The gate order is deliberate: **backup → backfill → deploy rules + client →
smoke test.** The backfill must land *before* the rules, because the rules are
what make the missing `codigos/{CODE}` docs fatal.

Run it from the repo root:

```bash
scripts/deploy.sh
```

Requires the `firebase` CLI on `PATH`, logged in (`firebase login`) with
deploy access to `domo-8b336`. The deploy itself needs **no service-account
key** — an interactive user login is enough. The *optional* `codigos` backfill
script (`scripts/backfill/`, "Backfill" below) is the one thing that would need
a service-account key, and only if you pick the script over the manual console
path — so the "Domo has no service-account" property holds unless you
deliberately choose the script. The deploy gate only asks whether the backfill
was *done*; it never runs it.

For a **pure hosting change** (no `firestore.rules` edit), the gate around
rules/co-change is unnecessary ceremony — answer "no rules change" at
checkpoint 2 and the script skips straight to build + hosting deploy. If you
want to skip the script entirely for something trivial, the equivalent manual
sequence is still safe:

```bash
flutter build web
firebase deploy --only hosting --project domo-8b336
```

## Backfill — `codigos/{CODE}` for pre-existing houses (MANDATORY before the rules deploy)

**Why this exists.** This cycle moved join-by-code from a `casas.where('codigo',
==, X)` query to a `get` on a dedicated lookup doc `codigos/{CODE} = { casaId,
nome }`. New houses get that lookup doc from `criarCasa`. But houses created
**before** this change carry only the `codigo` field on the house doc and have
**no** matching `codigos/{CODE}` doc. The moment the new rules ship,
`entrarNaCasa` does `get codigos/{CODE}` → `null` for every such house, so
**nobody can join a pre-existing house by code any more** — current members stay
in, but invites break. Backfilling the missing lookup docs closes that gap, and
it must happen **before** (or in the same maintenance window as, but ordered
before) the rules deploy.

Where this sits in the gate: **backup (step 1) → backfill (this) → deploy rules
+ client (steps 6–7) → smoke test.** `scripts/deploy.sh` step 3 will not let you
proceed with a rules deploy until you confirm the backfill is done.

Two ways to do it — pick based on how many houses exist:

### Option A — MANUAL in the Firebase console (recommended for a pilot)

For a handful of houses this is the right call: zero code, zero new credential,
and it keeps Domo's "no service-account key" property intact. Steps:

1. Firebase console → Firestore → `casas`. For **each** house doc, note its
   **document id** (that's the `casaId`) and read its `codigo` and `nome` fields.
2. Still in Firestore, open (or create) the **`codigos`** collection. For each
   house, create a document whose **id is the `codigo`** (upper-case, exactly as
   stored — codes are generated upper-case) with two string fields:
   - `casaId` = the house's document id from step 1
   - `nome` = the house's `nome`
3. If a `codigos/{CODE}` doc **already exists** (e.g. a house created after the
   `criarCasa` co-change shipped), leave it as-is — do not overwrite it.
4. When every house in `casas` has a matching `codigos/{codigo}` doc, the
   backfill is done. Answer "yes" at `scripts/deploy.sh` step 3.

### Option B — SCRIPT (`scripts/backfill/`, only if there are too many to hand-enter)

An idempotent Node/`firebase-admin` migration that scans `casas` and writes the
missing `codigos` docs. Dry-run by default; only writes with `--commit`; never
overwrites an existing lookup doc; reports (and skips) any code that already
maps to a different house. See `scripts/backfill/README.md` for the exact run
steps.

**Trade-off to decide before choosing B:** the script needs the **Admin SDK**,
which needs a **service-account key** — a credential Domo otherwise does not
have or manage (the deploy uses an interactive `firebase login`, not a key).
Introducing a key is a new secret surface to keep out of git (the repo and
`scripts/backfill/.gitignore` block the common key filenames, and the script
reads the key path from `GOOGLE_APPLICATION_CREDENTIALS` at runtime — never
commit the file). It's still Spark/free to run. For a pilot's handful of houses,
Option A avoids all of this; Option B earns its keep only once hand-entry stops
being practical. This is Felipe's call, not a default.

Whichever path you use, **verify in the console** that every `casas` doc has a
matching `codigos/{codigo}` doc before deploying the rules.

## Rollback

### Firestore rules

The previous rules file lives in git history — this is the whole rollback
path, no separate backup needed:

```bash
git log --oneline -- firestore.rules        # find the last-good commit
git show <good-commit>:firestore.rules > firestore.rules
firebase deploy --only firestore:rules --project domo-8b336
git checkout -- firestore.rules              # restore the working tree after
```

Rolling back rules alone, without also reverting the three client co-changes,
re-breaks join-by-code exactly as deploying the new rules without the
co-changes would (see `docs/BACKEND.md`). Roll back rules and the client
together, not one at a time.

### Hosting (web client)

Firebase Hosting keeps prior releases automatically. To roll back without a
rebuild:

- Firebase console -> Hosting -> your site -> "Release history" -> pick the
  previous release -> **Rollback**. A few clicks, no CLI needed, and the
  fastest path back to a known-good client.
- Or from the CLI: `firebase hosting:clone <site>:<previous-release-id>
  <site>:live --project domo-8b336`.

### User data

There is no automated backup on Spark (no scheduled Firestore export). The
manual export/console copy taken during the deploy-gate backup step
(`scripts/deploy.sh` step 1 / `docs/BACKEND.md`) is the only rollback for user
data — restoring means manually re-entering or re-importing whatever was
captured in that export. If usage grows enough that this stops being an
acceptable bar, revisit a scheduled export (Blaze-tier `gcloud firestore
export` to Cloud Storage) — named in `docs/BACKEND.md`'s cost note, out of
scope for this MVP cycle.

## Monitoring — current gap, recommended next step (not set up in this cycle)

This cycle's scope was CI + rules tests + the deploy gate/rollback docs.
Flagging explicitly: **there is currently no uptime or error-rate visibility
on the live app** — an outage, or a spike in rejected writes from a rules
regression, would only be discovered from a user report. That gap should not
stay open once real users beyond the pilot depend on the app. Cheapest
options, in order of effort:

- **Uptime**: a free external monitor (e.g. UptimeRobot free tier — 50
  monitors, 5-minute interval, email/webhook alert) pointed at
  `https://app.domo.cafelabs.net`. About 5 minutes to set up, no code change;
  left for the owner to create the account rather than done silently here.
- **Errors**: Firebase Crashlytics (free, first-party Firebase product, not
  yet wired into `pubspec.yaml`) for client-side errors, or watching the
  Firebase console's Firestore "Rules" usage/denials panel right after a
  rules deploy to catch a spike in rejected writes (the post-deploy smoke
  test in `docs/BACKEND.md` covers the functional side; this covers the
  "did something break for someone I didn't test" side).
- **Usage/cost**: Spark is hard-capped (no billing account attached, so no
  surprise bill), but it still has daily quotas (reads/writes/deletes,
  egress) that can be exhausted by a viral spike, taking the app down for
  everyone until the quota resets. Set a usage alert in the Firebase console
  (Usage and billing -> Details & settings) so quota pressure is visible
  before users notice a hard outage.
