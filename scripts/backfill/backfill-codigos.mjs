// Backfill codigos/{CODE} lookup docs for pre-existing casas.
// =============================================================================
// WHY THIS EXISTS
//   This cycle moved join-by-code from `casas.where('codigo', ==, X)` to a
//   get on a dedicated lookup doc `codigos/{CODE} = { casaId, nome }` (see
//   docs/BACKEND.md "Join-by-code"). `criarCasa` now writes that lookup doc for
//   every NEW house. But houses that already exist in production carry a
//   `codigo` FIELD and have NO matching `codigos/{CODE}` doc. The moment the new
//   rules ship, `entrarNaCasa` does `get codigos/{CODE}` -> null for every such
//   house, so nobody can join a pre-existing house by code any more. This script
//   closes that gap: for each existing casa it creates the missing lookup doc.
//
// WHEN TO USE THIS INSTEAD OF THE MANUAL CONSOLE STEPS
//   For a pilot with a handful of houses, the MANUAL path in docs/DEPLOY.md
//   (create the docs by hand in the Firebase console) is the recommended one:
//   zero code, zero new credential. Use THIS script only if there are enough
//   houses that hand-entry is impractical. It requires the Admin SDK, i.e. a
//   service-account key — a credential surface Domo otherwise does NOT have
//   (docs/DEPLOY.md notes Domo needs no service-account). That is the trade-off.
//
// SAFETY / IDEMPOTENCY
//   - DRY-RUN BY DEFAULT. It writes nothing unless you pass `--commit`.
//   - It NEVER overwrites an existing codigos/{CODE} doc. If the doc already
//     exists it is left untouched (idempotent: re-running is a no-op).
//   - If an existing codigos/{CODE} points at a DIFFERENT casaId than the casa
//     that claims that code, it is reported as a CONFLICT and skipped — never
//     overwritten. Resolve conflicts by hand before deciding what is correct.
//   - Runs on the Spark free tier (Admin SDK reads/writes count against normal
//     Firestore quota; a handful of houses is trivially under it).
//
// USAGE
//   cd scripts/backfill && npm install
//   export GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/to/serviceAccountKey.json
//   node backfill-codigos.mjs            # DRY RUN: report what WOULD be written
//   node backfill-codigos.mjs --commit   # actually write the missing docs
//
//   The key path is passed via env var and read at runtime. Do NOT commit the
//   key file (scripts/backfill/.gitignore and the repo .gitignore both block
//   *serviceAccount*.json / *.key.json). A committed key is compromised forever.
// =============================================================================

import { readFileSync } from 'node:fs';
import { initializeApp, cert, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const PROJECT_ID = 'domo-8b336';
const COMMIT = process.argv.includes('--commit');

function initAdmin() {
  const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (keyPath) {
    // Explicit service-account key file (recommended for a one-shot migration).
    const key = JSON.parse(readFileSync(keyPath, 'utf8'));
    if (key.project_id && key.project_id !== PROJECT_ID) {
      throw new Error(
        `Service-account key is for project "${key.project_id}", expected "${PROJECT_ID}". Aborting so we never write to the wrong project.`,
      );
    }
    return initializeApp({ credential: cert(key), projectId: PROJECT_ID });
  }
  // Fall back to Application Default Credentials (e.g. `gcloud auth
  // application-default login`) if no key file is given.
  return initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
}

async function main() {
  console.log(
    `\nDomo codigos backfill — project ${PROJECT_ID} — mode: ${
      COMMIT ? 'COMMIT (will write)' : 'DRY RUN (no writes)'
    }\n`,
  );

  initAdmin();
  const db = getFirestore();

  const casasSnap = await db.collection('casas').get();
  console.log(`Found ${casasSnap.size} casa doc(s).\n`);

  let created = 0;
  let skippedExisting = 0;
  let missingCodigo = 0;
  const conflicts = [];

  for (const casaDoc of casasSnap.docs) {
    const casa = casaDoc.data();
    const casaId = casaDoc.id;
    const rawCodigo = casa.codigo;

    if (typeof rawCodigo !== 'string' || rawCodigo.length === 0) {
      console.warn(`  [skip] casa ${casaId} has no "codigo" field — nothing to map.`);
      missingCodigo += 1;
      continue;
    }

    // entrarNaCasa looks up codigo.toUpperCase(); codes are generated uppercase.
    // Normalize the doc id to uppercase so a legacy lowercase codigo still
    // resolves. The casa's own `codigo` field is decorative post-migration
    // (the lookup doc id is the real code — see firestore.rules).
    const code = rawCodigo.toUpperCase();
    const codeRef = db.collection('codigos').doc(code);
    const existing = await codeRef.get();

    if (existing.exists) {
      const existingCasaId = existing.data()?.casaId;
      if (existingCasaId !== casaId) {
        console.error(
          `  [CONFLICT] codigos/${code} already points at casaId "${existingCasaId}", but casa ${casaId} also claims code "${code}". Left untouched.`,
        );
        conflicts.push({ code, existingCasaId, casaId });
      } else {
        console.log(`  [skip] codigos/${code} already maps to ${casaId}.`);
        skippedExisting += 1;
      }
      continue;
    }

    const payload = { casaId, nome: typeof casa.nome === 'string' ? casa.nome : '' };
    if (COMMIT) {
      // create() throws if the doc appeared meanwhile — never an overwrite.
      await codeRef.create(payload);
      console.log(`  [created] codigos/${code} -> ${casaId}`);
    } else {
      console.log(`  [would create] codigos/${code} -> ${casaId} ${JSON.stringify(payload)}`);
    }
    created += 1;
  }

  console.log('\n--- summary ---');
  console.log(`  ${COMMIT ? 'created' : 'would create'} : ${created}`);
  console.log(`  already mapped   : ${skippedExisting}`);
  console.log(`  no codigo field  : ${missingCodigo}`);
  console.log(`  conflicts        : ${conflicts.length}`);
  if (conflicts.length > 0) {
    console.log(
      '\n  Resolve conflicts by hand before onboarding: two different houses claim the same code.',
    );
  }
  if (!COMMIT && created > 0) {
    console.log('\n  Dry run only. Re-run with --commit to write the missing docs.');
  }
  console.log('');
}

main().catch((err) => {
  console.error('\nBackfill failed:', err.message ?? err);
  process.exitCode = 1;
});
