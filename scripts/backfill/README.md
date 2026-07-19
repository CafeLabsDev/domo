# codigos backfill (one-shot migration)

Backfills the `codigos/{CODE} = { casaId, nome }` lookup docs for houses that
existed **before** this cycle's join-by-code change. New houses get the lookup
doc from `criarCasa`; pre-existing houses only have the `codigo` field on the
house doc, so under the new rules `entrarNaCasa` (a `get codigos/{CODE}`) would
return null for them and joining by code would break. This creates the missing
docs. Read `docs/BACKEND.md` (Join-by-code) and `docs/DEPLOY.md` (deploy gate)
for the full context — this is a step **inside** that gate, not a standalone.

## Recommended path is MANUAL, not this script

For a pilot with a handful of houses, create the docs by hand in the Firebase
console (exact steps in `docs/DEPLOY.md`, "Backfill"). Zero code, zero new
credential. Use this script **only** if there are enough houses that hand-entry
is impractical.

## Trade-off of using the script

The script needs the Admin SDK, which needs a **service-account key**. Domo
otherwise has **no** service-account (see `docs/DEPLOY.md` — deploy uses an
interactive `firebase login`). Introducing a key is a new credential surface to
manage and keep out of git. That cost is only worth it past a certain number of
houses. The key is Felipe's call; the manual path avoids it entirely.

## Run it

```bash
cd scripts/backfill
npm install

# Get a service-account key: Firebase console -> Project settings ->
# Service accounts -> Generate new private key. Save it OUTSIDE the repo (or
# with a name the .gitignore blocks). Never commit it.
export GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/to/serviceAccountKey.json

node backfill-codigos.mjs            # DRY RUN — reports what WOULD be written
node backfill-codigos.mjs --commit   # actually writes the missing docs
```

## Safety properties

- **Dry-run by default** — writes nothing without `--commit`.
- **Idempotent** — an existing `codigos/{CODE}` is never overwritten; re-running
  is a no-op. Safe to run twice.
- **Conflict-aware** — if a code already maps to a *different* casaId, it is
  reported and skipped, never overwritten. Resolve those by hand.
- **Project-pinned** — aborts if the key is for a project other than
  `domo-8b336`, so it can't write to the wrong project.
- **Spark-safe** — normal Firestore reads/writes, well under free-tier quota for
  a pilot.

After running (or doing the manual equivalent), verify in the console that every
house in `casas` has a matching `codigos/{codigo}` doc, then proceed with the
rules + client deploy per `docs/DEPLOY.md`.
