**[Read in English](DEPLOY.md)**

# Deploy, CI e rollback

Guia operacional para um mantenedor solo rodar/depurar o deploy do Domo sem
precisar reconstruir o contexto do zero. Leia `docs/BACKEND.pt-br.md` primeiro
para entender *por que* o gate de deploy existe (backup-first, e a co-mudança
de três partes no cliente que precisa ir junto para o join-por-código) — este
arquivo é o *como*, além de CI e rollback.

Projeto: `domo-8b336` · Plano: **Spark (gratuito)** · Hosting:
`app.domo.cafelabs.net` (Firebase Hosting). Não existe um projeto de staging
separado — o único projeto do Spark faz o papel do único ambiente que existe,
e é por isso que o smoke test pós-deploy em `docs/BACKEND.pt-br.md` roda
contra a própria produção, logo depois do deploy.

## CI (`.github/workflows/ci.yml`)

Roda em todo push para `master`. Dois jobs independentes, ambos no tier
gratuito do GitHub Actions (repositório público/privado, neste volume de
pushes — bem longe dos 2.000 minutos grátis/mês):

- **`flutter`** — `flutter pub get && flutter analyze && flutter test` (60
  testes).
- **`rules`** — sobe o emulador do Firestore (`firebase-tools
  emulators:exec`) e roda `test/rules/rules.test.mjs` contra ele (77 testes
  cobrindo o modelo de regras default-deny descrito em
  `docs/BACKEND.pt-br.md`: membership, ownership, fronteiras
  pendente/ativo, lookup de `codigos`, controle de quantidade de item, ordem
  de categoria por casa, etc.). Usa só o emulador — nunca toca em produção,
  não precisa de credenciais de projeto.

O CI **não** faz deploy de nada. É uma rede de segurança para o código; o
envio para produção continua sendo a ação manual e deliberada abaixo.

**Gap de testabilidade conhecido (não é bug, registrado para não ser
redescoberto):** o construtor de `DispensaRepositoryImpl` só aceita um
`analytics` opcional — diferente de `CasaRepositoryImpl` (que também aceita um
client `firestore` injetável), ele sempre resolve `FirebaseFirestore.instance`
internamente. Isso significa que seus métodos de escrita (`atualizarItem`,
`atualizarQuantidade`, `atualizarDispensaEmLote`, etc.) não podem ser
exercitados contra `fake_cloud_firestore` da mesma forma que as escritas de
`CasaRepositoryImpl` são — os 60 testes Dart cobrem as camadas de
domain/presentation e o comportamento de widget da dispensa, mas não as
escritas de `DispensaRepositoryImpl` no Firestore diretamente (esses
caminhos só são exercitados indiretamente, ponta a ponta, via a suíte do
emulador de regras e uso manual/em produção). Vale a pena injetar
`firestore` no construtor ali também como follow-up, espelhando o padrão que
`casa` já usa.

Para depurar uma falha de CI localmente, rode os mesmos comandos:
`flutter analyze`, `flutter test`, ou

```bash
npx --yes firebase-tools emulators:exec --only firestore --project domo-rules-test \
  "npm test --prefix test/rules"
```

(Veja a seção de Testes em `docs/BACKEND.pt-br.md` para a variante manual de
dois terminais e uma nota sobre uma peculiaridade do `node --test` com
binários do firebase-tools instalados localmente — o CI contorna isso
rodando tudo através do Node 20 que o `actions/setup-node` coloca no `PATH`.)

## Fazendo o deploy (`scripts/deploy.sh`)

Codifica o gate de release de `docs/BACKEND.pt-br.md` ("Deploy gate: BACKUP
FIRST") como um script com checkpoints obrigatórios, para que um passo não
possa ser pulado por acidente:

1. Confirmação interativa de que os dados de produção foram salvos em backup
   (export manual/cópia via console, conforme `docs/BACKEND.pt-br.md` — o
   Spark não tem backup agendado do Firestore). Aborta se não confirmado.
2. Confirmação interativa de que **as três** co-mudanças de cliente para o
   join-por-código (`criarCasa`, `entrarNaCasa`, `deletarCasa` — ver a seção
   "Co-mudança obrigatória de cliente" de `docs/BACKEND.pt-br.md`) estão
   incluídas neste deploy, se `firestore.rules` fizer parte dele. Aborta se
   não confirmado. Pule este checkpoint (responda de acordo) para uma
   mudança só de hosting que não toca nas regras.
3. Confirmação interativa de que o **backfill de `codigos` para casas
   pré-existentes já foi feito** (ver "Backfill" abaixo), se
   `firestore.rules` fizer parte deste deploy. Aborta se não confirmado.
   Pulado para uma mudança só de hosting. Este é o passo que impede as novas
   regras de quebrarem o join-por-código para toda casa anterior a esta
   mudança.
4. Roda `flutter analyze` + `flutter test`, depois a suíte do emulador de
   regras — aborta o deploy se qualquer um falhar.
5. Confirmação interativa final mostrando exatamente o que vai rodar.
6. `firebase deploy --only firestore:rules --project domo-8b336` (só se
   `firestore.rules` mudou).
7. `flutter build web` + `firebase deploy --only hosting --project
   domo-8b336`.

A ordem do gate é deliberada: **backup → backfill → deploy das regras +
cliente → smoke test.** O backfill precisa entrar *antes* das regras, porque
as regras são o que torna os docs `codigos/{CODE}` faltantes fatais.

Rode a partir da raiz do repositório:

```bash
scripts/deploy.sh
```

Requer o CLI do `firebase` no `PATH`, logado (`firebase login`) com acesso
de deploy a `domo-8b336`. O deploy em si não precisa de **nenhuma chave de
service account** — um login interativo de usuário já basta. O script
*opcional* de backfill de `codigos` (`scripts/backfill/`, "Backfill" abaixo)
é a única coisa que precisaria de uma chave de service account, e só se você
escolher o script em vez do caminho manual pelo console — então a
propriedade "Domo não tem service account" se mantém a menos que você
escolha deliberadamente o script. O gate de deploy só pergunta se o backfill
foi *feito*; ele nunca o executa.

Para uma **mudança pura de hosting** (sem edição em `firestore.rules`), o
gate em torno das regras/co-mudança é cerimônia desnecessária — responda "não
mudou regra" no checkpoint 2 e o script pula direto para build + deploy de
hosting. Se você quiser pular o script inteiramente para algo trivial, a
sequência manual equivalente ainda é segura:

```bash
flutter build web
firebase deploy --only hosting --project domo-8b336
```

## Backfill — `codigos/{CODE}` para casas pré-existentes (OBRIGATÓRIO antes do deploy das regras)

**Por que isso existe.** Este ciclo moveu o join-por-código de uma query
`casas.where('codigo', ==, X)` para um `get` em um doc de lookup dedicado
`codigos/{CODE} = { casaId, nome }`. Casas novas ganham esse doc de lookup a
partir de `criarCasa`. Mas casas criadas **antes** dessa mudança carregam só
o campo `codigo` no doc da casa e **não** têm um doc `codigos/{CODE}`
correspondente. No momento em que as novas regras entram no ar,
`entrarNaCasa` faz `get codigos/{CODE}` → `null` para toda casa nessas
condições, então **ninguém consegue mais entrar em uma casa pré-existente
por código** — os membros atuais continuam dentro, mas os convites quebram.
Fazer o backfill dos docs de lookup faltantes fecha essa lacuna, e precisa
acontecer **antes** (ou na mesma janela de manutenção, mas ordenado antes) do
deploy das regras.

Onde isso entra no gate: **backup (passo 1) → backfill (este) → deploy das
regras + cliente (passos 6–7) → smoke test.** O passo 3 do
`scripts/deploy.sh` não deixa você seguir com um deploy de regras até você
confirmar que o backfill está feito.

Duas formas de fazer — escolha com base em quantas casas existem:

### Opção A — MANUAL no console do Firebase (recomendada para um piloto)

Para um punhado de casas essa é a decisão certa: zero código, zero
credencial nova, e mantém intacta a propriedade "Domo não tem chave de
service account". Passos:

1. Console do Firebase → Firestore → `casas`. Para **cada** doc de casa,
   anote seu **id do documento** (esse é o `casaId`) e leia seus campos
   `codigo` e `nome`.
2. Ainda no Firestore, abra (ou crie) a coleção **`codigos`**. Para cada
   casa, crie um documento cujo **id seja o `codigo`** (maiúsculo, exatamente
   como armazenado — códigos são gerados em maiúsculo) com dois campos
   string:
   - `casaId` = o id do documento da casa do passo 1
   - `nome` = o `nome` da casa
3. Se um doc `codigos/{CODE}` **já existir** (ex.: uma casa criada depois da
   co-mudança de `criarCasa` entrar no ar), deixe como está — não sobrescreva.
4. Quando toda casa em `casas` tiver um doc `codigos/{codigo}`
   correspondente, o backfill está feito. Responda "sim" no passo 3 do
   `scripts/deploy.sh`.

### Opção B — SCRIPT (`scripts/backfill/`, só se houver casas demais para inserir à mão)

Uma migração idempotente em Node/`firebase-admin` que varre `casas` e
escreve os docs `codigos` faltantes. Dry-run por padrão; só escreve com
`--commit`; nunca sobrescreve um doc de lookup existente; reporta (e pula)
qualquer código que já mapeie para uma casa diferente. Veja
`scripts/backfill/README.md` para os passos exatos de execução.

**Trade-off a decidir antes de escolher a B:** o script precisa do **Admin
SDK**, que precisa de uma **chave de service account** — uma credencial que
o Domo, de outra forma, não tem/gerencia (o deploy usa um `firebase login`
interativo, não uma chave). Introduzir uma chave é uma nova superfície de
segredo a manter fora do git (o repositório e o
`scripts/backfill/.gitignore` bloqueiam os nomes de arquivo de chave mais
comuns, e o script lê o caminho da chave de `GOOGLE_APPLICATION_CREDENTIALS`
em tempo de execução — nunca faça commit do arquivo). Ainda roda no
Spark/gratuito. Para o punhado de casas de um piloto, a Opção A evita tudo
isso; a Opção B só se justifica quando a inserção manual deixar de ser
prática. Essa é uma decisão do Felipe, não um padrão.

Seja qual for o caminho usado, **verifique no console** que todo doc de
`casas` tem um doc `codigos/{codigo}` correspondente antes de fazer o deploy
das regras.

## Rollback

### Regras do Firestore

O arquivo de regras anterior vive no histórico do git — esse é o caminho
inteiro de rollback, sem necessidade de backup separado:

```bash
git log --oneline -- firestore.rules        # encontre o último commit bom
git show <commit-bom>:firestore.rules > firestore.rules
firebase deploy --only firestore:rules --project domo-8b336
git checkout -- firestore.rules              # restaura a working tree depois
```

Fazer rollback só das regras, sem também reverter as três co-mudanças de
cliente, quebra o join-por-código de novo exatamente como fazer deploy das
novas regras sem as co-mudanças quebraria (ver `docs/BACKEND.pt-br.md`). Faça
o rollback das regras e do cliente juntos, não um de cada vez.

### Hosting (cliente web)

O Firebase Hosting mantém releases anteriores automaticamente. Para fazer
rollback sem um rebuild:

- Console do Firebase -> Hosting -> seu site -> "Histórico de releases" ->
  escolha a release anterior -> **Rollback**. Alguns cliques, sem precisar de
  CLI, e o caminho mais rápido de volta para um cliente conhecido como bom.
- Ou pelo CLI: `firebase hosting:clone <site>:<id-da-release-anterior>
  <site>:live --project domo-8b336`.

### Dados de usuário

Não há backup automático no Spark (sem export agendado do Firestore). O
export manual/cópia via console feito durante o passo de backup do gate de
deploy (`scripts/deploy.sh` passo 1 / `docs/BACKEND.pt-br.md`) é o único
rollback para dados de usuário — restaurar significa reinserir ou
reimportar manualmente o que foi capturado naquele export. Se o uso crescer
o suficiente para que isso deixe de ser um patamar aceitável, revisite um
export agendado (`gcloud firestore export` para o Cloud Storage, tier
Blaze) — citado na nota de custo de `docs/BACKEND.pt-br.md`, fora do escopo
deste ciclo de MVP.

## Monitoramento — gap atual, próximo passo recomendado (não configurado neste ciclo)

O escopo deste ciclo foi CI + testes de regras + os docs de gate/rollback de
deploy. Sinalizando explicitamente: **atualmente não há visibilidade de
uptime ou taxa de erro no app em produção** — uma queda, ou um pico de
escritas rejeitadas por uma regressão nas regras, só seria descoberto por um
relato de usuário. Esse gap não deveria continuar aberto assim que usuários
reais além do piloto passarem a depender do app. Opções mais baratas, em
ordem de esforço:

- **Uptime**: um monitor externo gratuito (ex.: UptimeRobot tier gratuito —
  50 monitores, intervalo de 5 minutos, alerta por e-mail/webhook) apontado
  para `https://app.domo.cafelabs.net`. Cerca de 5 minutos para configurar,
  sem mudança de código; deixado para o dono criar a conta em vez de feito
  silenciosamente aqui.
- **Erros**: Firebase Crashlytics (gratuito, produto first-party do
  Firebase, ainda não conectado em `pubspec.yaml`) para erros no cliente, ou
  acompanhar o painel de uso/negações de "Rules" do Firestore no console do
  Firebase logo depois de um deploy de regras para pegar um pico de escritas
  rejeitadas (o smoke test pós-deploy em `docs/BACKEND.pt-br.md` cobre o
  lado funcional; isto cobre o lado "quebrou algo para alguém que eu não
  testei").
- **Uso/custo**: o Spark tem um teto rígido (sem conta de billing anexada,
  então sem cobrança surpresa), mas ainda tem cotas diárias (leituras,
  escritas, exclusões, egress) que podem se esgotar com um pico viral,
  derrubando o app para todo mundo até a cota resetar. Configure um alerta
  de uso no console do Firebase (Uso e faturamento -> Detalhes e
  configurações) para que a pressão de cota fique visível antes dos
  usuários notarem uma queda hard.
