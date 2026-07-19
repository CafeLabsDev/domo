#!/usr/bin/env bash
# Domo — gated production deploy.
#
# Encodes the release gate from docs/BACKEND.md ("Deploy gate: BACKUP FIRST")
# as a script with hard checkpoints, so a step can't be skipped by accident.
# Mirrors the 6 steps documented in docs/DEPLOY.md's "Deploying" section:
#
#   1. Human confirms production data was backed up (manual export/console
#      copy — Spark has no scheduled Firestore backup). This is the only
#      rollback for user data.
#   2. If this deploy touches firestore.rules: human confirms all THREE
#      client co-changes for join-by-code (criarCasa/entrarNaCasa/
#      deletarCasa — see docs/BACKEND.md's "Required client co-change") are
#      included. Skipped entirely for a hosting-only change.
#   3. flutter analyze + flutter test, then the rules emulator suite —
#      aborts the deploy if either fails.
#   4. Final human confirmation showing exactly what will run.
#   5. Deploy firestore.rules (only if step 2 said rules are part of this
#      deploy).
#   6. Build the web client and deploy hosting.
#
# This script is meant to be run interactively, by hand, by whoever is doing
# the release. It is NOT run by CI — CI (.github/workflows/ci.yml) only
# analyzes/tests; shipping to production stays a deliberate manual action.
#
# Requires:
#   - `firebase` CLI on PATH, logged in (`firebase login`) with deploy access
#     to domo-8b336. No service-account key needed — unlike Dindin, Domo has
#     no Admin-SDK backfill script, so an interactive user login is enough.
#
# Usage: scripts/deploy.sh
#
# Rollback: see the "Rollback" section in docs/DEPLOY.md (git-restore
# firestore.rules + redeploy for rules, Firebase console "Release history" ->
# Rollback for hosting). This script does not automate rollback — it's a
# handful of commands/clicks documented there, not worth scripting.

set -euo pipefail

PROJECT_ID="domo-8b336"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log()  { printf '\n\033[1;34m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$1"; }
die()  { printf '\n\033[1;31mABORTED:\033[0m %s\n' "$1" >&2; exit 1; }

confirm() {
  # $1 = prompt text. Returns 0 only on an explicit "s"/"y".
  local reply
  read -r -p "$1 [s/N] " reply || true
  case "$reply" in
    [sSyY]) return 0 ;;
    *) return 1 ;;
  esac
}

# --- sanity checks -----------------------------------------------------------

command -v firebase >/dev/null 2>&1 || die "firebase CLI not found on PATH. Install firebase-tools first (npm install -g firebase-tools) and run 'firebase login'."

cd "$REPO_ROOT"

# --- 1. human backup gate ----------------------------------------------------

log "Step 1/6 — manual data backup"
echo "Spark has no scheduled Firestore backup. Before touching production, take"
echo "a manual export (gcloud firestore export gs://<bucket> if a bucket is"
echo "available, OR manually copy the current 'casas' docs from the Firebase"
echo "console). This export is the ONLY rollback for user data (docs/BACKEND.md)."
confirm "Have you already backed up production data?" \
  || die "Backup not confirmed. Take the export first, then re-run this script."

# --- 2. rules co-change gate (only if this deploy touches firestore.rules) --

log "Step 2/6 — firestore.rules / join-by-code co-change gate"
RULES_CHANGED="no"
if confirm "Does this deploy include a change to firestore.rules?"; then
  RULES_CHANGED="yes"
  echo
  echo "The new rules deny the old 'casas.where(codigo==X)' join query on"
  echo "purpose. Deploying rules WITHOUT the client co-change breaks joining a"
  echo "house. All THREE client edits must ship in THIS SAME deploy"
  echo "(docs/BACKEND.md's 'Required client co-change'):"
  echo "  1) criarCasa    writes codigos/{CODE} = {casaId, nome} after the house doc"
  echo "  2) entrarNaCasa does get codigos/{CODE} -> casaId (no more casas query)"
  echo "  3) deletarCasa  deletes codigos/{CODE} alongside the house"
  confirm "Are all three client co-changes included in this deploy?" \
    || die "Co-change not confirmed. Do not deploy rules alone — finish the three client edits first."
else
  log "No rules change in this deploy — skipping the co-change gate."
fi

# --- 3. tests: flutter analyze/test + rules emulator suite ------------------

log "Step 3/6 — flutter analyze + flutter test"
flutter analyze || die "flutter analyze failed. Fix the reported issues before deploying."
flutter test || die "flutter test failed. Fix the failing tests before deploying."

log "Step 3/6 — firestore rules test suite (emulator, never touches production)"
if [ ! -d "$REPO_ROOT/test/rules/node_modules" ]; then
  log "Installing test/rules dependencies..."
  (cd "$REPO_ROOT/test/rules" && npm install)
fi
npx --yes firebase-tools emulators:exec --only firestore --project domo-rules-test \
  "npm test --prefix test/rules" \
  || die "Rules test suite failed. Fix the failing rule(s) before deploying — production rules are unaffected so far."

# --- 4. final confirmation ---------------------------------------------------

log "Step 4/6 — final confirmation"
echo "About to, in order, against project '$PROJECT_ID':"
if [ "$RULES_CHANGED" = "yes" ]; then
  echo "  a) firebase deploy --only firestore:rules --project $PROJECT_ID"
  echo "  b) flutter build web"
  echo "  c) firebase deploy --only hosting --project $PROJECT_ID"
else
  echo "  (no rules deploy — hosting-only change)"
  echo "  a) flutter build web"
  echo "  b) firebase deploy --only hosting --project $PROJECT_ID"
fi
confirm "Proceed?" || die "Cancelled by user."

# --- 5. deploy rules (only if this deploy includes a rules change) ----------

if [ "$RULES_CHANGED" = "yes" ]; then
  log "Step 5/6 — deploying firestore.rules"
  firebase deploy --only firestore:rules --project "$PROJECT_ID"
else
  log "Step 5/6 — skipped (no rules change in this deploy)"
fi

# --- 6. build + deploy hosting ------------------------------------------------

log "Step 6/6 — building web client"
flutter build web

log "Step 6/6 — deploying hosting"
firebase deploy --only hosting --project "$PROJECT_ID"

log "Deploy complete."
echo "Next: run the post-deploy smoke test from docs/BACKEND.md (two throwaway"
echo "accounts, create/join/approve/leave/delete) before considering this done —"
echo "there is no staging, so this is the only end-to-end check against prod."
echo "If anything looks wrong, see the Rollback section in docs/DEPLOY.md."
