# Domo — guia para agentes de IA

Documentação completa (o quê, como rodar, arquitetura, backend, design,
deploy) vive em `README.md` e `docs/*.md` — comece por lá, não por aqui:

- `README.md` — visão geral, stack, pré-requisitos, como rodar/buildar.
- `docs/ARQUITETURA.md` — camadas, Riverpod, go_router, decisões técnicas.
- `docs/BACKEND.md` — modelo de dados Firestore, regras de segurança, gate de deploy.
- `docs/DESIGN.md` — identidade visual "Armário Aberto" (cores, tipografia).
- `docs/DEPLOY.md` — CI, deploy, rollback.

## Específico para trabalhar aqui com um agente

- **WSL2:** `flutter` pode entrar em loop de `git fetch`. Prefira `dart run
  build_runner build` / `dart run flutter_launcher_icons` diretamente em vez
  de invocar via `flutter`. Ver README para o fix de `git config` se o loop
  persistir mesmo assim.
- **Nunca rode `firebase deploy` direto.** Deploy é um passo manual gated —
  siga sempre `scripts/deploy.sh` (ver `docs/DEPLOY.md`), que exige
  confirmação de backup e, se `firestore.rules` mudou, do backfill de
  `codigos/{CODE}`. Pular esse script quebra o join-por-código em casas
  pré-existentes.
- **Codegen obrigatório após mexer em modelos/providers:** qualquer edição em
  `@freezed`, `@JsonSerializable` ou `@riverpod` exige rodar `dart run
  build_runner build --delete-conflicting-outputs` antes de considerar a
  mudança completa — os `.g.dart`/`.freezed.dart` ficam desatualizados
  silenciosamente, sem erro de análise.
- **Mudanças significativas futuras devem passar pelo Forge** (o time de
  agentes especializados do repo `forge`) em vez de serem feitas ad-hoc por um
  agente avulso — mantém a mesma qualidade/rigor de arquitetura, segurança e
  documentação que já foi aplicada neste projeto.
