import '../models/casa_model.dart';
import '../models/membro_model.dart';

abstract class CasaRepository {
  Stream<CasaModel?> watchCasaDoUsuario(String userId);

  Future<CasaModel> criarCasa({
    required String nome,
    required String userId,
    required String nomeUsuario,
    String? fotoUrl,
  });

  Future<void> entrarNaCasa({
    required String codigo,
    required String userId,
    required String nomeUsuario,
    String? fotoUrl,
  });

  Stream<List<MembroModel>> watchMembros(String casaId);

  Future<void> aprovarMembro({
    required String casaId,
    required String userId,
  });

  Future<void> recusarMembro({
    required String casaId,
    required String userId,
  });

  Future<void> atualizarCargo({
    required String casaId,
    required String userId,
    required String cargo,
  });
}
