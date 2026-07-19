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

- **`flutter`** — `flutter pub get && flutter analyze && flutter test`.
- **`rules`** — spins up the Firestore emulator (`firebase-tools
  emulators:exec`) and runs `test/rules/rules.test.mjs` against it (50 tests
  covering the default-deny rules model described in `docs/BACKEND.md`:
  membership, ownership, pendente/ativo boundaries, `codigos` lookup, etc.).
  Uses the emulator only — never touches production, needs no project
  credentials.

CI does **not** deploy anything. It's a safety net for the code; shipping to
production is still the deliberate manual action below.

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
3. Runs `flutter analyze` + `flutter test`, then the rules emulator suite —
   aborts the deploy if either fails.
4. Final interactive confirmation showing exactly what will run.
5. `firebase deploy --only firestore:rules --project domo-8b336` (only if
   `firestore.rules` changed).
6. `flutter build web` + `firebase deploy --only hosting --project
   domo-8b336`.

Run it from the repo root:

```bash
scripts/deploy.sh
```

Requires the `firebase` CLI on `PATH`, logged in (`firebase login`) with
deploy access to `domo-8b336`. No service-account key is needed — unlike
Dindin, Domo has no Admin-SDK backfill script, so an interactive user login is
enough.

For a **pure hosting change** (no `firestore.rules` edit), the gate around
rules/co-change is unnecessary ceremony — answer "no rules change" at
checkpoint 2 and the script skips straight to build + hosting deploy. If you
want to skip the script entirely for something trivial, the equivalent manual
sequence is still safe:

```bash
flutter build web
firebase deploy --only hosting --project domo-8b336
```

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
