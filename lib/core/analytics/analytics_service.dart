import 'package:firebase_analytics/firebase_analytics.dart';

/// Thin, minimal wrapper around [FirebaseAnalytics].
///
/// Domo tracks only the handful of events that trace back to the refactor's
/// success metrics — not every tap. Each method below documents exactly what
/// triggers it and what counts as "true", so the events stay queryable
/// instead of turning into event soup. None of them carry PII (item names,
/// member names, or house join codes) — only enum/count parameters.
///
/// Kept as its own class (rather than calling [FirebaseAnalytics] directly
/// from repositories) so the event definitions live in one place and can be
/// swapped for a fake in tests.
class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  /// Enables analytics collection. Call once at app bootstrap, right after
  /// `Firebase.initializeApp`.
  Future<void> init() {
    return _analytics.setAnalyticsCollectionEnabled(true);
  }

  /// "Criar casa" — fires once a house is fully created: the `casas/{id}`
  /// doc AND its `codigos/{CODE}` lookup doc have both committed
  /// successfully (see `CasaRepositoryImpl.criarCasa`). No parameters: does
  /// not carry the house name or its join code.
  Future<void> logCasaCriada() {
    return _analytics.logEvent(name: 'casa_criada');
  }

  /// "Entrar em casa" — fires once a user submits a valid join code and
  /// their member record is written into that house's `membros` map
  /// (status starts as `pendente`, pending approval). No parameters: does
  /// not carry the join code or the joiner's name.
  Future<void> logCasaEntrou() {
    return _analytics.logEvent(name: 'casa_entrou');
  }

  /// "Mudança de status de item" — fires whenever a pantry item's status
  /// transitions between `tem` / `nao_tem` / `no_carrinho`, regardless of
  /// which screen (Dispensa or Mercado) triggered it. Carries only the
  /// enum transition, never the item's name.
  Future<void> logItemStatusAlterado({
    required String statusAnterior,
    required String statusNovo,
  }) {
    return _analytics.logEvent(
      name: 'item_status_alterado',
      parameters: {
        'status_anterior': statusAnterior,
        'status_novo': statusNovo,
      },
    );
  }

  /// "Fechamento de carrinho" — fires once per successful
  /// Mercado→Dispensa batch update, the moment items marked `no_carrinho`
  /// are moved back to `tem`. Carries the item count so Measure can see
  /// typical batch size, but never the item identities.
  Future<void> logCarrinhoFechado({required int quantidadeItens}) {
    return _analytics.logEvent(
      name: 'carrinho_fechado',
      parameters: {'quantidade_itens': quantidadeItens},
    );
  }

  /// "Quantidade atualizada" — fires on a *deliberate* user edit of an
  /// ON-mode item's `quantidade` (the pantry card's +/- stepper, or the
  /// edit-item form), i.e. `DispensaRepositoryImpl.atualizarQuantidade`.
  /// This is the one signal for whether households keep the number honest
  /// over time, so it must stay uncontaminated by automation: it does
  /// **not** fire for the cart-close default bump
  /// (`atualizarDispensaEmLote` setting `quantidade = estoqueMinimo + 1`),
  /// which is a system default standing in for a number nobody actually
  /// typed, not evidence of maintenance. Carries only the resulting derived
  /// status (`tem`/`nao_tem`), never the item name or the raw quantity.
  Future<void> logItemQuantidadeAtualizada({required String statusResultante}) {
    return _analytics.logEvent(
      name: 'item_quantidade_atualizada',
      parameters: {'status_resultante': statusResultante},
    );
  }

  /// "Ordem de categorias alterada" — fires once a house saves a reordered
  /// category list via `CasaRepositoryImpl.atualizarOrdemCategorias`.
  /// Carries only the category count, never the category names/order.
  Future<void> logCasaOrdemCategoriasAlterada({required int quantidadeCategorias}) {
    return _analytics.logEvent(
      name: 'casa_ordem_categorias_alterada',
      parameters: {'quantidade_categorias': quantidadeCategorias},
    );
  }
}
