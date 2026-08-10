**[Read in English](BACKEND.md)**

# Notas de backend / segurança (Domo)

Referência operacional para o backend Firestore do Domo. Leia isto antes de
qualquer deploy que toque em `firestore.rules` ou `firestore.indexes.json`.

Projeto: `domo-8b336` · Plano: **Spark (gratuito)** · Auth: Firebase Auth ·
DB: Cloud Firestore.

## Gate de deploy: BACKUP PRIMEIRO, e o deploy é um passo humano deliberado

Fazer deploy das regras em `domo-8b336` **NÃO é automático**. É uma ação
manual e revisada. Antes de rodar qualquer
`firebase deploy --only firestore:rules`:

1. **Faça backup de produção primeiro.** No Spark não há backup agendado do
   Firestore (isso precisa de um plano pago). Faça um export manual antes de
   qualquer mudança de regras: `gcloud firestore export gs://<bucket>` se um
   bucket estiver disponível, OU, na escala de MVP, copie manualmente os docs
   atuais de `casas` a partir do console do Firebase. Este é o único
   rollback para dados de usuário.
2. **Confirme que a co-mudança de cliente entrou no ar — as TRÊS edições
   (ver "Join-por-código" abaixo).** Estas regras quebram deliberadamente o
   fluxo *atual* de join-por-código. Fazer deploy das regras SEM a mudança
   de cliente vai fazer o join na casa falhar. Regras + as três edições de
   cliente vão no MESMO deploy. O gate precisa verificar as três juntas —
   uma mudança parcial de cliente (ex.: `criarCasa` escrevendo `codigos` mas
   `entrarNaCasa` ainda consultando `casas` por `codigo`) é tão quebrada
   quanto nenhuma mudança. As três edições:
   - `criarCasa` escreve `codigos/{CODE} = {casaId, nome}` depois do doc da
     casa.
   - `entrarNaCasa` faz `get codigos/{CODE}` → `casaId` (sem mais query em
     `casas`).
   - `deletarCasa` apaga `codigos/{CODE}` junto com a casa.
3. **Faça o backfill de `codigos/{CODE}` para casas PRÉ-EXISTENTES
   PRIMEIRO.** Casas criadas antes desta mudança têm um campo `codigo` mas
   nenhum doc de lookup `codigos/{CODE}`, então assim que as novas regras
   entrarem no ar, o `get codigos/{CODE}` de `entrarNaCasa` retorna null para
   elas e **o join-por-código quebra para toda casa existente** (os membros
   continuam dentro; os convites quebram). Antes do deploy das regras, crie
   `codigos/{codigo} = {casaId, nome}` para toda casa existente —
   manualmente no console para o punhado de casas de um piloto, ou via o
   script idempotente `scripts/backfill/` se houver casas demais (esse
   script precisa de uma chave de service account — uma credencial que o
   Domo, de outra forma, não tem; trade-off citado no "Backfill" de
   `docs/DEPLOY.pt-br.md`). Ordem do gate: **backup → backfill → deploy das
   regras + cliente → smoke test.** O passo 3 do `scripts/deploy.sh` bloqueia
   o deploy das regras até o backfill ser confirmado.
4. **Guarde o id do ruleset anterior.** O `firebase deploy` imprime/armazena
   ele; as regras fazem rollback com um `firebase deploy` do
   `firestore.rules` anterior. As regras são versionadas no git aqui, então
   o artefato de rollback é só o commit anterior.
5. O deploy é gated pela revisão de `security` neste ciclo — não faça deploy
   até esse sign-off existir.

**Nota sobre as adições deste ciclo (controle de quantidade de item +
ordem de categoria):** ambas entram no MESMO arquivo `firestore.rules` que a
mudança de join-por-código dos `codigos` acima, então o mesmo gate/checkpoints
se aplica — mas diferente de `codigos`, elas **não precisam de backfill**
(passo 3 acima). Os dois campos novos
(`controlaEstoque`/`quantidade`/`estoqueMinimo`/`noCarrinho` em itens,
`ordemCategorias` na casa) são opcionais e tratados como legalmente ausentes
pelas regras — todo documento pré-existente é válido como está com as novas
regras, sem necessidade de migração de dados pré-deploy. Não confunda as
duas: `codigos` precisou de backfill porque o fluxo de join ANTIGO fica
inutilizável sem ele; essas duas features não mudam o comportamento de
nenhum fluxo existente, elas só adicionam fluxos novos e opcionais.

## Status das regras: corrigido e implantado (resolvido no ciclo de refactor de 2026-07-18)

**Status: as novas regras abaixo ESTÃO implantadas em produção**
(`domo-8b336`), junto com as três co-mudanças de cliente descritas em
"Co-mudança de cliente obrigatória" abaixo — ver
`mind/projetos/produtos-cafelabs/domo.md`. Os parágrafos abaixo descrevem o
estado encontrado **no início daquele ciclo, antes do fix** — mantidos aqui
como o registro histórico de por que isso foi sinalizado como urgente, não
como o estado atual.

**Achado original (pré-fix): não foi possível ler o ruleset publicado em
produção** a partir do ambiente sandbox usado na auditoria: ele bloqueia
access tokens (`gcloud auth print-access-token`, `firebase login:ci`), e o
firebase-tools não tem nenhum comando first-party de "obter regras
publicadas", nenhum ruleset em cache em `.firebase/`, e nunca existiu um
bloco `firestore` em `firebase.json` — então nada neste repositório havia
feito deploy de regras até aquele ponto. O que quer que estivesse em
produção tinha sido configurado manualmente no console.

**O que o código do cliente provava que as regras em produção DEVIAM
permitir na época — e por que isso era quase certamente muito aberto:** o
`CasaRepositoryImpl.entrarNaCasa` pré-fix rodava
`casas.where('codigo', ==, X)` como um *não membro* e depois escrevia a si
mesmo no doc da casa. Para isso funcionar, as regras em produção precisavam
permitir que um usuário autenticado arbitrário **consultasse a coleção
`casas` inteira** e **escrevesse em uma casa da qual não fazia parte** — ou
seja, algo pelo menos tão permissivo quanto
`allow read, write: if request.auth != null`, possivelmente totalmente
aberto. É por isso que o ticket foi sinalizado como urgente, e por que as
regras + o fix de cliente abaixo foram priorizados e enviados juntos.

TODO: confirmar — este repositório também não tem como ler o id/timestamp do
ruleset ao vivo a partir deste sandbox (mesma limitação de access token
acima), então a data exata do deploy não é verificável de forma independente
a partir daqui; baseado apenas no registro do projeto em
`mind/projetos/produtos-cafelabs/domo.md`.

## Novo modelo de segurança (o que o `firestore.rules` daqui reforça)

Postura: **default-deny**. Só os paths casados são alcançáveis; todo outro
path e toda operação não permitida é negada.

A autorização é sempre lida a partir do **mapa `membros`** (a fonte da
verdade), nunca de `membrosAtivos` (um cache desnormalizado que a query do
cliente usa). Uma entrada forjada em `membrosAtivos` não consegue conceder
leitura/escrita, porque toda checagem lê `membros`.

Ponto chave que difere do briefing do ticket: **`cargo` é cosmético e não
concede nada.** O `isAdmin` do próprio app é `casa.criadoPor == uid` — então
a fronteira de gestão nas regras é **ownership (`criadoPor`), não `cargo`.**

| Path | Quem |
| --- | --- |
| `casas/{id}` get | membro daquela casa (ativo OU pendente) |
| `casas/{id}` list | só o stream `membrosAtivos array-contains <uid>` (as próprias casas) |
| `casas/{id}` create | usuário logado, como único dono `ativo` (`criadoPor == uid`) |
| `casas/{id}` update — join | um não membro adiciona SÓ a si mesmo como `pendente`; não pode se auto-aprovar, não pode entrar em `membrosAtivos`, não pode mexer em outros ou nos metadados da casa |
| `casas/{id}` update — manage | só o **owner**: aprova (`pendente`→`ativo` + `membrosAtivos`), remove/recusa, edita `cargo`, renomeia. `criadoPor`/`criadoEm`/`codigo` imutáveis |
| `casas/{id}` update — leave | um membro remove SÓ a si mesmo (mapa + `membrosAtivos`) |
| `casas/{id}` update — ordem de categoria | qualquer membro **ativo** define SÓ `ordemCategorias` (ver "Ordem de categoria por casa" abaixo) |
| `casas/{id}` delete | só o owner |
| `casas/{id}/itens/{itemId}` read/write | só membros **ativos** (pendente excluído); escrita validada por `itemWriteValid()` — status precisa ser `tem`/`nao_tem`/`no_carrinho`, mais os invariantes de controle de quantidade (ver "Controle opcional de quantidade de item" abaixo) |
| `codigos/{CODE}` get | qualquer usuário logado que saiba o código |
| `codigos/{CODE}` list | negado (sem enumeração) |

Formato dos dados (confirmado contra `lib/features/casa` +
`lib/features/dispensa`): itens são uma **subcoleção**
`casas/{casaId}/itens/{itemId}` (eles NÃO carregam um campo `casaId` — ele é
injetado a partir do path no lado do cliente), e o doc da casa carrega tanto
o mapa embutido `membros` quanto a lista desnormalizada `membrosAtivos`.
Nenhum índice composto é necessário (todas as queries são de campo único:
`membrosAtivos array-contains`, `codigo ==`, `itens orderBy nome`), daí o
`firestore.indexes.json` vazio.

Dois campos adicionados neste ciclo, ambos **opcionais e puramente
aditivos** — sem migração de schema, sem backfill, docs existentes são
válidos como estão porque a ausência é um valor legal para ambos:

- `casas/{id}.ordemCategorias` (`List<String>?`) — ver "Ordem de categoria
  por casa" abaixo.
- `casas/{casaId}/itens/{itemId}.controlaEstoque` / `.quantidade` /
  `.estoqueMinimo` / `.noCarrinho` — ver "Controle opcional de quantidade de
  item" abaixo.

## Superfície de integração: como o cliente lê/escreve neste backend

O Domo **não tem Cloud Functions** — `firebase.json` não tem um bloco
`functions` e não existe nenhum diretório `functions/` neste repositório. Toda
a superfície cliente-backend é leitura/escrita direta via **SDK do Firestore**
(`cloud_firestore`), governada pelas regras acima, mais chamadas do **SDK do
Firebase Auth** para identidade. Não há API REST ou GraphQL própria do Domo.

### Firebase Auth (`firebase_auth` + `google_sign_in`)

Tudo em `AuthRepositoryImpl`
(`lib/features/auth/data/repositories/auth_repository_impl.dart`) — chamadas
padrão do SDK do Firebase Auth, não governadas por `firestore.rules`:

| Método | Chama | Falha |
|---|---|---|
| `signInWithEmailAndPassword` | `FirebaseAuth.signInWithEmailAndPassword` | `FirebaseAuthException` (`wrong-password`, `user-not-found`, ...), propagada sem captura |
| `createUserWithEmailAndPassword` | `FirebaseAuth.createUserWithEmailAndPassword` | `FirebaseAuthException` (`email-already-in-use`, `weak-password`, ...) |
| `signInWithGoogle` | web: `signInWithPopup`; mobile: `google_sign_in` + `signInWithCredential`. Retorna silenciosamente (no-op) se o usuário cancelar o seletor nativo | `FirebaseAuthException` / `PlatformException` |
| `signOut` | `FirebaseAuth.signOut()` + `GoogleSignIn.signOut()` em paralelo | raramente falha, sem tratamento especial |
| `authStateChanges` | stream `FirebaseAuth.authStateChanges()`, observada por `authStateProvider`, direciona o redirect do router (`lib/core/router/app_router.dart`) | n/a (stream) |

### Cloud Firestore (SDK `cloud_firestore`) — caminhos de coleção/documento

Todo caminho abaixo só é alcançável pela regra casada na tabela de "Novo
modelo de segurança" acima — linke pra lá para **quem pode chamar** em vez de
repetir por linha. Dois repositórios são donos de toda leitura/escrita do app.

**`CasaRepositoryImpl`**
(`lib/features/casa/data/repositories/casa_repository_impl.dart`) —
`casas/{id}` e `codigos/{CODE}`:

| Método | Endereçado como | Entrada → saída | Falha | Também muda |
|---|---|---|---|---|
| `watchCasaDoUsuario(userId)` | query `casas` com `membrosAtivos array-contains userId`, `.limit(1)`, realtime | `userId` → `Stream<CasaModel?>` | uma query bem formada nunca é permission-denied — a regra limita estruturalmente os resultados às próprias casas do chamador; outros erros de stream aparecem via `AsyncValue`/`DomoErrorState` | só leitura |
| `criarCasa({nome, userId, nomeUsuario, fotoUrl})` | `casas.doc()` (id novo) **create**, depois `codigos.doc(codigo)` **create** — duas escritas sequenciais, deliberadamente **não** em batch (a regra de create de `codigos` faz `get()` no doc da casa, que só enxerga estado já commitado; um batch/transação avalia as regras pré-commit e sempre negaria) | args → `Future<CasaModel>` | se a escrita em `codigos` falhar, o método apaga o doc de `casas` recém-criado e relança — nunca deixa uma casa órfã e não-joinável. `FirebaseException` crua, sem wrapper próprio | cria 2 docs; dispara `logCasaCriada()` (fire-and-forget) |
| `entrarNaCasa({codigo, userId, nomeUsuario, fotoUrl})` | `get codigos/{codigo.toUpperCase()}` → `casaId`, depois `casas/{casaId}` **update** (`membros.$userId`) | args → `Future<void>` | lança um `Exception('Código inválido...')` simples (não `FirebaseException`) se o código não resolver — quem chama precisa capturar `Exception` genérica, não só erros Firebase | adiciona `membros.{userId}` como `pendente` — **não** toca `membrosAtivos`, então o stream `watchCasaDoUsuario` do próprio joiner continua vazio até um owner aprovar (ver o trace de join/aprovação em `docs/ARQUITETURA.pt-br.md`); dispara `logCasaEntrou()` |
| `watchMembros(casaId)` | snapshots do doc `casas/{casaId}`, realtime, mapeia o campo `membros` | `casaId` → `Stream<List<MembroModel>>` | o stream passa a falhar se o chamador deixar de ser membro no meio da sessão | só leitura |
| `aprovarMembro({casaId, userId})` | `casas/{casaId}` **update**: `membros.$userId.status='ativo'` + `arrayUnion` em `membrosAtivos` | args → `Future<void>` | permission-denied se o chamador não for o owner | vira a query `watchCasaDoUsuario` do usuário aprovado de vazia para casando — é isso que efetivamente admite ele na casa, ao vivo, no próprio device |
| `recusarMembro({casaId, userId})` | `casas/{casaId}` **update**: apaga `membros.$userId` | args → `Future<void>` | permission-denied se o chamador não for o owner | nenhuma (nunca esteve em `membrosAtivos`) |
| `atualizarCargo({casaId, userId, cargo})` | `casas/{casaId}` **update**: `membros.$userId.cargo` | args → `Future<void>` | permission-denied se o chamador não for o owner | só cosmético — `cargo` não concede nada nas regras (ver "Novo modelo de segurança") |
| `removerMembroAtivo({casaId, userId})` | `casas/{casaId}` **update**: apaga `membros.$userId` + `arrayRemove` de `membrosAtivos` | args → `Future<void>` | permission-denied se o chamador não for o owner | tira o usuário de todo stream chaveado em `membros`/`membrosAtivos` imediatamente; não muda retroativamente o `atualizadoPor` dos itens que ele tocou por último |
| `deletarCasa({casaId})` | lê o doc da casa pelo `codigo`, depois um **batch**: apaga `codigos/{codigo}` + apaga `casas/{casaId}` | `casaId` → `Future<void>` | batch é tudo-ou-nada; `FirebaseException` propaga se qualquer metade for negada | **a subcoleção `itens` não é apagada** — o Firestore não faz cascade-delete de subcoleções, e este batch nunca toca `casas/{casaId}/itens/*`, então esses docs viram órfãos permanentemente inalcançáveis (nenhum caminho de regra consegue lê-los depois que o doc pai `casas/{casaId}` some). Não há limpeza disso em lugar nenhum do código. TODO: confirmar se isso é um trade-off aceito na escala de piloto ou se precisa de um passo de limpeza antes de trazer mais casas |
| `atualizarOrdemCategorias({casaId, ordem})` | `casas/{casaId}` **update**: só `ordemCategorias` | args → `Future<void>` | permission-denied para pendente/não-membro; a regra também rejeita a escrita se qualquer outra chave for tocada (nunca acontece a partir deste método, que só envia esse campo) | dispara `logCasaOrdemCategoriasAlterada()` |

**`DispensaRepositoryImpl`**
(`lib/features/dispensa/data/repositories/dispensa_repository_impl.dart`) —
subcoleção `casas/{casaId}/itens/{itemId}`:

| Método | Endereçado como | Entrada → saída | Falha | Também muda |
|---|---|---|---|---|
| `watchItens(casaId)` | subcoleção `itens`, `orderBy('nome')`, realtime | `casaId` → `Stream<List<PantryItem>>` | o stream passa a falhar se o chamador for removido da casa no meio da sessão | só leitura |
| `adicionarItem({casaId, nome, categoria, userId})` | `itens.add()` (id automático) | args → `Future<void>` | permission-denied para pendente/não-membros | itens novos são sempre criados em modo OFF (`controlaEstoque` ausente) — não há como criar um item já pré-configurado em modo ON numa única chamada |
| `atualizarItem({casaId, itemId, nome, categoria})` | `itens/{itemId}` **update**: só `nome`/`categoria` | args → `Future<void>` | permission-denied se não for membro ativo | deliberadamente NÃO reescreve `atualizadoPor`/`atualizadoEm` — ver "Avisos adiados" acima, não repetido aqui |
| `atualizarStatus({casaId, itemId, statusAnterior, novoStatus, userId})` | `itens/{itemId}` **update**: `status`/`atualizadoEm`/`atualizadoPor` | args → `Future<void>` | rejeitado por `itemOnModeConsistent()` se chamado contra um item em modo ON com um `status` que discorde de sua própria `quantidade`/`estoqueMinimo` — na prática a UI só conecta isso a itens em modo OFF (`_StatusToggleZone` do `PantryItemCard`, renderizado só quando `!item.controlaEstoque`); itens em modo ON usam `atualizarQuantidade`/`marcarNoCarrinho` em vez disso | dispara `logItemStatusAlterado()` |
| `deletarItem({casaId, itemId})` | `itens/{itemId}` **delete** | args → `Future<void>` | permission-denied se não for membro ativo | nada além do próprio doc |
| `atualizarDispensaEmLote({casaId, itens, userId})` | **batch** de updates em `itens/{id}`, um por item passado | args → `Future<void>` | batch é tudo-ou-nada; qualquer item falhando na validação derruba a ação inteira de "fechar carrinho" | itens em modo ON: aumenta `quantidade` para `estoqueMinimo + 1` (não só vira o status) para o status derivado recalcular para `tem`, e limpa `noCarrinho`; itens em modo OFF: seta `status: tem` diretamente. Dispara `logCarrinhoFechado()` uma vez pro batch inteiro |
| `ativarControleEstoque({casaId, itemId, quantidade, estoqueMinimo, userId})` | `itens/{itemId}` **update**: liga o modo ON, seta `quantidade`/`estoqueMinimo`, deriva `status`, limpa `noCarrinho` | args → `Future<void>` | permission-denied se não for membro ativo; rejeitado se `quantidade`/`estoqueMinimo` forem negativos | troca o item do modelo manual de 3 status para o derivado |
| `desativarControleEstoque({casaId, itemId, statusCongelado, userId})` | `itens/{itemId}` **update**: desliga o modo ON, congela `status` em `statusCongelado`, limpa `noCarrinho` | args → `Future<void>` | permission-denied se não for membro ativo | `quantidade`/`estoqueMinimo` são mantidos no doc, não apagados, caso o item volte pro modo ON depois |
| `atualizarQuantidade({casaId, itemId, quantidade, estoqueMinimo, userId})` | `itens/{itemId}` **update**: `quantidade`/`estoqueMinimo`/`status` derivado | args → `Future<void>` | permission-denied se não for membro ativo; rejeitado no servidor se qualquer valor ficar negativo (também bloqueado no cliente — ver o trace ponta a ponta em `docs/ARQUITETURA.pt-br.md`) | dispara `logItemQuantidadeAtualizada()` — mas só a partir deste caminho de edição deliberada, nunca no bump automático de `atualizarDispensaEmLote` (ver o comentário de doc de `logItemQuantidadeAtualizada` em `analytics_service.dart`) |
| `marcarNoCarrinho({casaId, itemId, noCarrinho, userId})` | `itens/{itemId}` **update**: bool `noCarrinho` | args → `Future<void>` | permission-denied se não for membro ativo | equivalente em modo ON do valor de status `no_carrinho` do modo OFF — ver "Novo neste ciclo: controle opcional de quantidade de item" abaixo |

**Exposição de erro, nos dois repositórios:** todo controller
(`DispensaController`, `CasaController`) envolve as escritas em
`AsyncValue.guard(...)`, então uma `FirebaseException`/`Exception` lançada cai
no estado Riverpod do controller como `AsyncError`. Mas só 4 telas de fato
fazem `ref.listen` de um controller pra mostrar esse erro ao usuário
(`login_page.dart`, `register_page.dart`, `entrar_casa_page.dart`,
`criar_casa_page.dart` — confirmado por grep em `lib/features`). Todo outro
ponto de mutação (o stepper/toggle de status do item da dispensa,
aprovar/remover membro, reordenar categoria, ...) só chama métodos do
`.notifier` e nunca escuta o estado de erro resultante, então uma escrita
permission-denied nesses caminhos hoje falha silenciosamente do ponto de vista
do usuário — o valor simplesmente não muda, sem erro visível. TODO: confirmar
se isso é um trade-off aceito ou uma lacuna que vale fechar.

## Novo neste ciclo: controle opcional de quantidade de item

Controle de estoque por item, opt-in (`PantryItem.controlaEstoque`, padrão
`false`). Itens em modo OFF (o padrão, e todo item pré-existente — o campo
simplesmente está ausente neles) se comportam **exatamente como antes**:
`status` manual de 3 valores, carrinho rastreado pelo valor de status
`no_carrinho`. Itens em modo ON adicionam:

- `quantidade` / `estoqueMinimo` — inteiros não negativos.
- `status` é **derivado, não manual**: `quantidade <= estoqueMinimo` ⇒
  `nao_tem`, senão `tem`. As regras fixam o valor armazenado nessa
  derivação (`itemOnModeConsistent()` em `firestore.rules`) para que a
  desnormalização nunca possa divergir — um cliente não consegue escrever um
  item em modo ON com um `status` que discorde da sua própria
  `quantidade`/`estoqueMinimo`.
- `noCarrinho` (bool) carrega "no carrinho nesta compra" para itens em modo
  ON em vez do enum de status (`no_carrinho` como valor de `status` é
  rejeitado para itens em modo ON — `itemOnModeConsistent()` só permite
  `tem`/`nao_tem`). Itens em modo OFF rejeitam um `noCarrinho: true` perdido
  (`itemOffModeConsistent()`) para que o sinal de carrinho dos dois modos
  nunca se sobreponha.

`itemWriteValid()` (`firestore.rules`) é o único gate para os dois modos em
todo `create`/`update` de item: valida tipos/faixas para os quatro campos
novos independente do modo, depois se ramifica na checagem de consistência
de modo ON ou OFF acima. Ele se compõe com a checagem já existente de
`isActiveMemberOf(casaId)` — a mesma fronteira de membership de antes, isso
só adiciona validação de formato/consistência de campo por cima.

## Novo neste ciclo: ordem de categoria por casa

`casas/{id}.ordemCategorias` (`List<String>?`) — uma ordem de exibição por
casa para as 8 categorias hardcoded da dispensa (`kDispensaCategorias` em
`dispensa/domain/constants.dart`). Esta feature **não** adiciona CRUD de
categoria — as 8 categorias em si continuam hardcoded no cliente; só a sua
*ordem* é armazenada por casa. `null` (toda casa pré-existente) recai para a
ordem hardcoded no lado do cliente (`categoriasOrdenadas(...)`).

As regras adicionam um quarto fluxo de update de `casas/{id}`,
`editOrdemCategorias()`: qualquer membro **ativo** (checado a partir do mapa
`membros`, a mesma fonte da verdade de todo o resto deste arquivo) pode
atualizar o doc da casa **se e somente se** `ordemCategorias` for a *única*
chave no diff
(`next().diff(prev()).affectedKeys().hasOnly(['ordemCategorias'])`) — então
esse caminho não pode ser usado para contrabandear uma mudança em `membros`,
`membrosAtivos`, `criadoPor`/`criadoEm`/`codigo`, ou qualquer outra coisa. Os
três fluxos de update pré-existentes (`joinAsPending`, `selfLeave`) foram
adicionalmente reforçados para rejeitar explicitamente mexer em
`ordemCategorias` pelos *seus* próprios caminhos (um pendente entrando, ou
qualquer um saindo, não pode também esconder uma mudança de ordem de
categoria na mesma escrita) — fechando um buraco que existiria de outra
forma porque as checagens de `update` das regras do Firestore são avaliadas
como "pelo menos um predicado de fluxo casa com o diff inteiro", não campo a
campo.

A validação de formato é intencionalmente rasa: `ordemCategorias is list` e
`.size() <= 20`. As regras NÃO checam que a lista seja exatamente as 8
strings de categoria conhecidas sem duplicatas — isso é deliberadamente
deixado para o cliente, para evitar hardcodar as strings de nome de
categoria em `firestore.rules` (o que acoplaria o arquivo de regras a uma
lista de constantes do lado do cliente que pode mudar sem um deploy de
regras). `categoriasOrdenadas(...)` já é defensivo contra uma lista
malformada/desatualizada de qualquer forma (descarta strings desconhecidas,
anexa qualquer categoria conhecida que esteja faltando nela), então um bug
de regras ou um doc editado manualmente não conseguem esconder uma
categoria das views agrupadas mesmo sem dedup no servidor.

Alcançado no app via um ícone dedicado na `AppBar` de `CasaPage` (rota
`/casa/categorias`, `CategoriaOrdemPage`), deliberadamente *fora* do
`PopupMenuButton` administrativo/destrutivo, já que (diferente de
deletar-casa/remover-membro) isso está disponível para qualquer membro
ativo, não só o owner.

## Co-mudança de cliente obrigatória: join-por-código (lookup `codigos/{CODE}`)

**Status: implementado e implantado** — as três edições abaixo estão vivas em
`lib/features/casa/data/repositories/casa_repository_impl.dart` (verificado
lendo o arquivo: `criarCasa` escreve `codigos/{CODE}`, `entrarNaCasa` faz um
`get` por id, `deletarCasa` apaga o doc de lookup). Mantido aqui como a
explicação autoritativa de *por que* as regras e o cliente têm esse formato,
e como checklist para reverificar se `firestore.rules` em torno de `codigos`
for mexido de novo no futuro.

O fluxo de join antigo consultava a coleção `casas` inteira por `codigo`.
**Essa query não pode ser protegida** — as regras do Firestore não podem
forçar uma cláusula `where`, então permitir a query já deixa qualquer
usuário logado enumerar e ler *toda* casa. As regras aqui, portanto,
**negam** essa query de propósito.

A substituição segura são **três edições em `CasaRepositoryImpl`**, todas
obrigatórias, todas enviadas juntas:

1. **`criarCasa`**: escreve `codigos/{CODE} = { casaId, nome }`, DEPOIS do
   doc da casa existir (o `get()` de ownership da regra precisa ver a casa já
   commitada). `{CODE}` é o id do documento.
2. **`entrarNaCasa`**: resolve o código via `get codigos/{CODE}` → `casaId`
   (um get POR ID — você já precisa saber o código de 6 caracteres, sem
   enumeração), depois mantém o update existente de auto-adicionar-se
   como `pendente` em `casas/{casaId}`.
3. **`deletarCasa`**: apaga também `codigos/{CODE}` para os códigos não
   ficarem soltos.

Sem as três, o join-por-código falha sob essas regras — então, se as regras
ou o repositório de cliente forem modificados de novo no futuro, os dois
precisam andar juntos (ver passo 2 do gate de deploy). A suíte de testes de
regras cobre o lado servidor das três (create/delete de `codigos` só pelo
owner, resolução get-by-id, list negado).

## Smoke test pós-deploy (não há staging)

O Spark não tem um projeto de staging separado, então a única verificação
ponta a ponta é contra o próprio `domo-8b336`, logo depois do deploy, com
contas descartáveis. Faça isso antes de considerar o deploy concluído:

1. Duas contas de teste do Auth (A e B).
2. Como A: crie uma casa. Confirme que o doc da casa E um doc
   `codigos/{CODE}` aparecem (prova que a co-mudança de `criarCasa` escreveu
   o mapeamento).
3. Como B: entre por esse código. Confirme que B fica como `pendente` e
   consegue ler a casa mas não seus itens.
4. Como A: aprove B. Confirme que B agora aparece em `membrosAtivos`, o
   stream de B mostra a casa, e B consegue ler/escrever itens.
5. Como B: saia. Confirme que B sumiu tanto de `membros` quanto de
   `membrosAtivos`, e que A ainda está presente em `membrosAtivos` (o fix de
   integridade do self-leave).
6. Como A: apague a casa. Confirme que tanto o doc da casa quanto
   `codigos/{CODE}` sumiram. Limpe as contas de teste.

## Risco aceito: brute force do código de convite (escopo de piloto)

O código de convite tem 6 caracteres. No charset do app, isso é
aproximadamente **~29,7 bits** de entropia, e no Spark não há **nenhum
rate-limit no lado do servidor** no lookup `get codigos/{CODE}` (limitar a
taxa de uma leitura precisaria de um Cloud Function como gatekeeper, ou
seja, Blaze). Então um atacante determinado poderia, em princípio, fazer
script de tentativas contra o lookup. Na escala de piloto (um punhado de
casas em um espaço de 6 caracteres de ~1e9) um chute aleatório quase nunca
acerta um código ativo, e o raio de impacto de um acerto é a lista de
compras de uma casa — **aceito PARA O PILOTO.**

Antes de trazer usuários reais além do piloto:
- **Habilite o Firebase App Check (gratuito no Spark).** Ele bloqueia
  lookups vindos de clientes que não são o app genuíno, o que interrompe o
  brute force via script sem nenhum plano pago. Este é o próximo passo de
  hardening recomendado e não custa nada.
- Um rate-limit/bloqueio real do lado do servidor (throttling por IP ou por
  conta na resolução) exigiria mover a resolução do join para uma **Cloud
  Function**, que precisa do plano pay-as-you-go **Blaze**. Citado como um
  trade-off, não assumido — o App Check deveria ser tentado primeiro já que
  é gratuito.

## Avisos adiados (severidade BAIXA, registrados mas não corrigidos)

- **Self-leave do owner deixa a casa órfã.** As regras permitem que um owner
  use o caminho de self-leave (ele é um membro). Se fizer isso, ele sai de
  `membros` e `membrosAtivos` — perdendo `read`, já que as leituras são
  chaveadas por `membros` — mas `criadoPor` continua apontando para ele,
  então ele mantém os direitos de `delete`/`ownerManages` e ninguém mais é
  promovido a owner. A casa fica com membros mas sem um owner alcançável.
  Impacto baixo no MVP (a UI do app não oferece "sair" para o owner), então
  adiado para pós-MVP. Um fix adequado é bloquear o self-leave do owner nas
  regras ou transferir `criadoPor` na saída — ambos precisam de um fluxo de
  cliente, então pertencem à mesma leva de transferência de ownership.
- **Id do doc de `codigos` não validado contra `casa.codigo`.** Um owner
  poderia criar um mapeamento cujo id difere do campo `codigo` de sua casa.
  Inofensivo pós-migração: o join se resolve pelo id do mapeamento, então
  `casa.codigo` se torna decorativo e o id é o código real. Forçar
  igualdade custaria um segundo `get()` sem ganho de segurança. Anotado em
  `firestore.rules`; adiado.
- **Escritas em `itens` não fixam `atualizadoPor == uid()`.** Considerado
  como hardening mas NÃO aplicado: o `atualizarItem` do cliente (edição de
  nome/categoria, `dispensa_repository_impl.dart` ~L44-54) atualiza um item
  SEM reescrever `atualizadoPor`, então uma regra exigindo
  `next().atualizadoPor == uid()` em todo update rejeitaria esse fluxo
  legítimo (o campo mantém o uid de um usuário anterior). A escrita já é
  gated para membros `ativo` da casa, então o único gap é atribuição
  cosmética dentro de uma casa confiável. Adiado; revisitar só se o cliente
  for mudado para sempre carimbar `atualizadoPor`.

## Dados de usuário: export e exclusão (baseline de privacidade)

Os dados são compartilhados dentro de uma casa, então a pegada pessoal de um
usuário é sua entrada em `casas/{id}.membros[uid]` (`nome`, `cargo`,
`fotoUrl`) mais os itens que ele tocou por último
(`itens.*.atualizadoPor == uid`).

- **Exclusão (self-service, já no app):** `sairDaCasa` remove a própria
  entrada `membros[uid]` do usuário e o tira de `membrosAtivos` — o
  caminho de self-leave das regras permite exatamente isso. A exclusão
  completa da conta (o próprio usuário do Auth) é, neste estágio, um passo
  manual no console.
- **Export (manual, documentado — aceitável no MVP):** leia o doc
  `casas/{id}` do usuário (sua fatia de `membros[uid]`) e os `itens` da casa
  a partir do console do Firebase ou de um script admin. Ainda não há
  export no app; adicione um antes de trazer usuários reais além do
  piloto.

## Testes

`test/rules/` é um harness Node autônomo (com seu próprio `package.json`,
isolado de `pubspec.yaml`). Ele roda só contra o **emulador local, nunca
produção**. A partir da raiz do repositório:

```
firebase emulators:exec --only firestore --project domo-rules-test \
  "node --test test/rules/rules.test.mjs"
```

(o `node` dentro de `emulators:exec` resolve para o binário pkg embutido do
firebase, que NÃO suporta `--test`; passe um caminho absoluto para um Node
20+ de verdade como acima.)

**77 testes, todos passando.** Cobre: não membro bloqueado, pendente
limitado (lê a casa, bloqueado dos itens), membro ativo OK,
aprovação/remoção só do owner, invariantes de self-join-como-pendente (sem
auto-aprovação, sem inserção em `membrosAtivos`, sem mexer em outros, sem
adição de duas chaves, sem apagar a chave de outro), self-leave incluindo o
guard de integridade (um membro que sai NÃO CONSEGUE tirar outros uids de
`membrosAtivos`), imutabilidade do owner sobre
`criadoPor`/`criadoEm`/`codigo`, validação de status de item, `codigos`
só-get + create/delete só do owner + rejeição de campo extra +
update-negado, e escritas não autenticadas negadas em
`casas`/`itens`/`codigos`. O teste de griefing do self-leave é um guard de
regressão: ele só passa por causa do pin de três linhas
`next == prev \ {uid}` em `selfLeave()`; remover esse pin faz ele falhar
(verificado).

Também cobre o controle opcional de quantidade de item (status derivado em
modo ON fixado em `quantidade <= estoqueMinimo`, validação de int não
negativo, `no_carrinho` rejeitado como status derivado, modo OFF inalterado
incluindo `noCarrinho:true` perdido rejeitado) e `ordemCategorias` por casa
(edição só de membro ativo, pendente/não-membro negado, formato de lista
validado, e os fluxos de update de join/manage/leave provados intactos e
não contrabandeáveis pelo novo caminho).

## Nota de custo

Tudo acima roda no **tier gratuito do Spark** — enforcement só via regras,
sem Cloud Functions, sem backups pagos. Se backups agendados do Firestore ou
um caminho de join confiável no servidor (Cloud Function em vez do lookup
`codigos`) forem desejados algum dia, isso exige o plano pay-as-you-go
**Blaze** (uma conta de billing com cartão). Não necessário para este MVP;
citado aqui só para o trade-off ficar visível, não assumido.
