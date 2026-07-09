// Firestore Security Rules tests for Domo (see ../../firestore.rules and
// ../../docs/BACKEND.md).
//
// WHY A SEPARATE NODE HARNESS: Security Rules can only be exercised by a real
// Firestore Security Rules evaluator, which the emulator provides. This harness
// is intentionally isolated from the Flutter app: its own package.json /
// node_modules live here in test/rules/, not wired into pubspec.yaml or
// `flutter test`. It talks to a LOCAL emulator only — never production.
//
// HOW TO RUN:
//   1. In one terminal, from the repo root:
//        firebase emulators:start --only firestore
//      (or, one-shot:  firebase emulators:exec --only firestore \
//                        "cd test/rules && npm install && npm test")
//   2. In another terminal:
//        cd test/rules && npm install && npm test
//
// Each test drives the EXACT write shape the app's repositories produce
// (casa_repository_impl.dart / dispensa_repository_impl.dart), so a passing
// suite is real evidence the rules accept the client's real patterns and reject
// everything else.

import { strict as assert } from 'node:assert';
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';
import { deleteField, arrayUnion, arrayRemove } from 'firebase/firestore';

const PROJECT_ID = 'domo-rules-test';
const RULES_PATH = new URL('../../firestore.rules', import.meta.url);

const OWNER = 'owner-uid';
const MEMBER = 'member-uid';
const PENDING = 'pending-uid';
const STRANGER = 'stranger-uid';
const CASA_ID = 'casa1';
const CODE = 'ABC234';

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(RULES_PATH, 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

// -- helpers -----------------------------------------------------------------

function db(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}
function anon() {
  return testEnv.unauthenticatedContext().firestore();
}

function membro(uid, status, cargo) {
  return { userId: uid, nome: uid, cargo, fotoUrl: null, status };
}

// Seed a casa with an owner (ativo), one ativo member, one pendente member.
async function seedCasa() {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const d = ctx.firestore();
    await setDoc(doc(d, 'casas', CASA_ID), {
      nome: 'Casa Teste',
      codigo: CODE,
      criadoPor: OWNER,
      criadoEm: new Date(),
      membrosAtivos: [OWNER, MEMBER],
      membros: {
        [OWNER]: membro(OWNER, 'ativo', 'Administrador'),
        [MEMBER]: membro(MEMBER, 'ativo', 'Membro'),
        [PENDING]: membro(PENDING, 'pendente', 'Membro'),
      },
    });
    await setDoc(doc(d, 'casas', CASA_ID, 'itens', 'item1'), {
      nome: 'Arroz',
      categoria: 'Grãos',
      status: 'tem',
      atualizadoEm: new Date(),
      atualizadoPor: OWNER,
    });
    await setDoc(doc(d, 'codigos', CODE), { casaId: CASA_ID, nome: 'Casa Teste' });
  });
}

const casaRef = (d) => doc(d, 'casas', CASA_ID);
const itemRef = (d, id = 'item1') => doc(d, 'casas', CASA_ID, 'itens', id);

// -- casa reads --------------------------------------------------------------

describe('casa reads', () => {
  test('non-member cannot read the casa', async () => {
    await seedCasa();
    await assertFails(getDoc(casaRef(db(STRANGER))));
  });

  test('unauthenticated cannot read the casa', async () => {
    await seedCasa();
    await assertFails(getDoc(casaRef(anon())));
  });

  test('active member can read the casa', async () => {
    await seedCasa();
    await assertSucceeds(getDoc(casaRef(db(MEMBER))));
  });

  test('pendente member can read the casa (to see approval status)', async () => {
    await seedCasa();
    await assertSucceeds(getDoc(casaRef(db(PENDING))));
  });

  test("member's arrayContains stream returns only their casas", async () => {
    await seedCasa();
    const d = db(MEMBER);
    const q = query(
      collection(d, 'casas'),
      where('membrosAtivos', 'array-contains', MEMBER),
    );
    await assertSucceeds(getDocs(q));
  });

  test('stranger cannot enumerate casas by membrosAtivos', async () => {
    await seedCasa();
    const d = db(STRANGER);
    const q = query(
      collection(d, 'casas'),
      where('membrosAtivos', 'array-contains', OWNER),
    );
    await assertFails(getDocs(q));
  });
});

// -- casa create -------------------------------------------------------------

describe('casa create', () => {
  test('owner creates a casa with themselves as sole ativo member', async () => {
    const d = db(OWNER);
    await assertSucceeds(
      setDoc(doc(d, 'casas', 'new1'), {
        nome: 'Nova',
        codigo: 'XYZ789',
        criadoPor: OWNER,
        criadoEm: new Date(),
        membrosAtivos: [OWNER],
        membros: { [OWNER]: membro(OWNER, 'ativo', 'Administrador') },
      }),
    );
  });

  test('cannot create a casa owned by someone else', async () => {
    const d = db(OWNER);
    await assertFails(
      setDoc(doc(d, 'casas', 'new2'), {
        nome: 'Nova',
        codigo: 'XYZ789',
        criadoPor: STRANGER,
        criadoEm: new Date(),
        membrosAtivos: [STRANGER],
        membros: { [STRANGER]: membro(STRANGER, 'ativo', 'Administrador') },
      }),
    );
  });

  test('cannot create a casa pre-seeded with extra members', async () => {
    const d = db(OWNER);
    await assertFails(
      setDoc(doc(d, 'casas', 'new3'), {
        nome: 'Nova',
        codigo: 'XYZ789',
        criadoPor: OWNER,
        criadoEm: new Date(),
        membrosAtivos: [OWNER, STRANGER],
        membros: {
          [OWNER]: membro(OWNER, 'ativo', 'Administrador'),
          [STRANGER]: membro(STRANGER, 'ativo', 'Membro'),
        },
      }),
    );
  });
});

// -- join by code ------------------------------------------------------------

describe('join by code', () => {
  test('signed-in user resolves a code via codigos/{CODE} get', async () => {
    await seedCasa();
    await assertSucceeds(getDoc(doc(db(STRANGER), 'codigos', CODE)));
  });

  test('codigos cannot be listed (no enumeration)', async () => {
    await seedCasa();
    await assertFails(getDocs(collection(db(STRANGER), 'codigos')));
  });

  test('non-member adds only themselves as pendente', async () => {
    await seedCasa();
    await assertSucceeds(
      updateDoc(casaRef(db(STRANGER)), {
        [`membros.${STRANGER}`]: membro(STRANGER, 'pendente', 'Membro'),
      }),
    );
  });

  test('joiner cannot self-approve (status ativo)', async () => {
    await seedCasa();
    await assertFails(
      updateDoc(casaRef(db(STRANGER)), {
        [`membros.${STRANGER}`]: membro(STRANGER, 'ativo', 'Membro'),
      }),
    );
  });

  test('joiner cannot slip into membrosAtivos', async () => {
    await seedCasa();
    await assertFails(
      updateDoc(casaRef(db(STRANGER)), {
        [`membros.${STRANGER}`]: membro(STRANGER, 'pendente', 'Membro'),
        membrosAtivos: arrayUnion(STRANGER),
      }),
    );
  });

  test('joiner cannot modify another member while joining', async () => {
    await seedCasa();
    await assertFails(
      updateDoc(casaRef(db(STRANGER)), {
        [`membros.${STRANGER}`]: membro(STRANGER, 'pendente', 'Membro'),
        [`membros.${MEMBER}.cargo`]: 'Hacked',
      }),
    );
  });

  test('joiner cannot rename the casa while joining', async () => {
    await seedCasa();
    await assertFails(
      updateDoc(casaRef(db(STRANGER)), {
        [`membros.${STRANGER}`]: membro(STRANGER, 'pendente', 'Membro'),
        nome: 'Roubada',
      }),
    );
  });
});

// -- member management (owner only) ------------------------------------------

describe('member management', () => {
  test('owner approves a pendente member (-> ativo + membrosAtivos)', async () => {
    await seedCasa();
    await assertSucceeds(
      updateDoc(casaRef(db(OWNER)), {
        [`membros.${PENDING}.status`]: 'ativo',
        membrosAtivos: arrayUnion(PENDING),
      }),
    );
  });

  test('a non-owner member cannot approve a pendente', async () => {
    await seedCasa();
    await assertFails(
      updateDoc(casaRef(db(MEMBER)), {
        [`membros.${PENDING}.status`]: 'ativo',
        membrosAtivos: arrayUnion(PENDING),
      }),
    );
  });

  test('a pendente cannot approve themselves via the map', async () => {
    await seedCasa();
    await assertFails(
      updateDoc(casaRef(db(PENDING)), {
        [`membros.${PENDING}.status`]: 'ativo',
        membrosAtivos: arrayUnion(PENDING),
      }),
    );
  });

  test('owner removes a member', async () => {
    await seedCasa();
    await assertSucceeds(
      updateDoc(casaRef(db(OWNER)), {
        [`membros.${MEMBER}`]: deleteField(),
        membrosAtivos: arrayRemove(MEMBER),
      }),
    );
  });

  test('owner changes a member cargo', async () => {
    await seedCasa();
    await assertSucceeds(
      updateDoc(casaRef(db(OWNER)), {
        [`membros.${MEMBER}.cargo`]: 'Administrador',
      }),
    );
  });

  test('owner cannot change the join code', async () => {
    await seedCasa();
    await assertFails(
      updateDoc(casaRef(db(OWNER)), { codigo: 'HACKED' }),
    );
  });

  test('non-owner cannot delete the casa', async () => {
    await seedCasa();
    await assertFails(deleteDoc(casaRef(db(MEMBER))));
  });

  test('owner deletes the casa', async () => {
    await seedCasa();
    await assertSucceeds(deleteDoc(casaRef(db(OWNER))));
  });
});

// -- self leave --------------------------------------------------------------

describe('self leave', () => {
  test('active member removes only themselves', async () => {
    await seedCasa();
    await assertSucceeds(
      updateDoc(casaRef(db(MEMBER)), {
        [`membros.${MEMBER}`]: deleteField(),
        membrosAtivos: arrayRemove(MEMBER),
      }),
    );
  });

  test('member cannot remove someone else under the guise of leaving', async () => {
    await seedCasa();
    await assertFails(
      updateDoc(casaRef(db(MEMBER)), {
        [`membros.${OWNER}`]: deleteField(),
        membrosAtivos: arrayRemove(OWNER),
      }),
    );
  });
});

// -- itens (pantry) ----------------------------------------------------------

describe('itens', () => {
  test('active member reads items', async () => {
    await seedCasa();
    await assertSucceeds(getDoc(itemRef(db(MEMBER))));
  });

  test('pendente member cannot read items', async () => {
    await seedCasa();
    await assertFails(getDoc(itemRef(db(PENDING))));
  });

  test('non-member cannot read items', async () => {
    await seedCasa();
    await assertFails(getDoc(itemRef(db(STRANGER))));
  });

  test('active member creates an item', async () => {
    await seedCasa();
    await assertSucceeds(
      setDoc(itemRef(db(MEMBER), 'item2'), {
        nome: 'Feijão',
        categoria: 'Grãos',
        status: 'nao_tem',
        atualizadoEm: new Date(),
        atualizadoPor: MEMBER,
      }),
    );
  });

  test('item with an invalid status is rejected', async () => {
    await seedCasa();
    await assertFails(
      setDoc(itemRef(db(MEMBER), 'item3'), {
        nome: 'X',
        categoria: 'Y',
        status: 'bogus',
        atualizadoEm: new Date(),
        atualizadoPor: MEMBER,
      }),
    );
  });

  test('active member updates item status', async () => {
    await seedCasa();
    await assertSucceeds(
      updateDoc(itemRef(db(MEMBER)), {
        status: 'no_carrinho',
        atualizadoEm: new Date(),
        atualizadoPor: MEMBER,
      }),
    );
  });

  test('pendente member cannot write items', async () => {
    await seedCasa();
    await assertFails(
      updateDoc(itemRef(db(PENDING)), { status: 'no_carrinho' }),
    );
  });

  test('non-member cannot write items', async () => {
    await seedCasa();
    await assertFails(
      updateDoc(itemRef(db(STRANGER)), { status: 'no_carrinho' }),
    );
  });

  test('active member deletes an item', async () => {
    await seedCasa();
    await assertSucceeds(deleteDoc(itemRef(db(MEMBER))));
  });
});
