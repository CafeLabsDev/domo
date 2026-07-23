// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get cancel => 'Cancelar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get save => 'Salvar';

  @override
  String get add => 'Adicionar';

  @override
  String get delete => 'Deletar';

  @override
  String get remove => 'Remover';

  @override
  String get defaultUserName => 'Usuário';

  @override
  String get errorNetwork => 'Sem conexão. Verifique sua internet.';

  @override
  String get errorUnexpected => 'Erro inesperado. Tente novamente.';

  @override
  String get genericLoadError => 'Não foi possível carregar. Tente novamente.';

  @override
  String get genericLoadErrorMessage =>
      'Verifique sua conexão com a internet e tente novamente.';

  @override
  String get loginTitle => 'Bem-vindo ao Domo';

  @override
  String get loginSubtitle => 'Gerencie sua casa com sua família.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailRequired => 'Informe seu e-mail.';

  @override
  String get emailInvalid => 'E-mail inválido.';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get passwordRequiredLogin => 'Informe sua senha.';

  @override
  String get loginButton => 'Entrar';

  @override
  String get orDivider => 'ou';

  @override
  String get googleButton => 'Continuar com Google';

  @override
  String get noAccountPrompt => 'Não tem conta? ';

  @override
  String get createAccountLink => 'Criar conta';

  @override
  String get loginErrorInvalidCredential => 'E-mail ou senha incorretos.';

  @override
  String get loginErrorTooManyRequests =>
      'Muitas tentativas. Tente mais tarde.';

  @override
  String get loginErrorUserDisabled => 'Esta conta foi desativada.';

  @override
  String get loginErrorGeneric => 'Erro ao entrar. Tente novamente.';

  @override
  String get registerTitle => 'Criar Conta';

  @override
  String get registerIntro => 'Preencha os dados abaixo\npara começar.';

  @override
  String get passwordRequiredRegister => 'Informe uma senha.';

  @override
  String get passwordTooShort => 'A senha deve ter pelo menos 6 caracteres.';

  @override
  String get confirmPasswordLabel => 'Confirmar senha';

  @override
  String get confirmPasswordRequired => 'Confirme sua senha.';

  @override
  String get passwordsDontMatch => 'As senhas não coincidem.';

  @override
  String get haveAccountPrompt => 'Já tem conta? ';

  @override
  String get registerErrorEmailInUse => 'Este e-mail já está em uso.';

  @override
  String get registerErrorGeneric => 'Erro ao criar conta. Tente novamente.';

  @override
  String get casaGateTitle => 'Sua casa te espera!';

  @override
  String get casaGateSubtitle =>
      'Crie uma nova casa ou entre em uma existente usando o código do convite.';

  @override
  String get createHouseButton => 'Criar uma Casa';

  @override
  String get haveInviteCodeButton => 'Tenho um código de convite';

  @override
  String get codeCopied => 'Código copiado!';

  @override
  String get leaveHouseTitle => 'Sair da casa';

  @override
  String get leaveHouseConfirm =>
      'Você vai perder o acesso a esta casa. Para voltar, precisará do código de convite.';

  @override
  String get leave => 'Sair';

  @override
  String get deleteHouseTitle => 'Deletar casa';

  @override
  String get copyCodeTooltip => 'Copiar código';

  @override
  String get reorderCategoriesTooltip => 'Reordenar categorias';

  @override
  String get inviteCode => 'Código de convite';

  @override
  String get couldNotLoadHouse => 'Não foi possível carregar sua casa.';

  @override
  String get couldNotLoadMembers =>
      'Não foi possível carregar os membros da casa.';

  @override
  String pendingApproval(int count) {
    return 'Aguardando aprovação ($count)';
  }

  @override
  String membersCount(int count) {
    return 'Membros ($count)';
  }

  @override
  String get removeMemberTitle => 'Remover membro';

  @override
  String removeMemberConfirm(String name) {
    return 'Deseja remover $name da casa? Eles perderão o acesso imediatamente.';
  }

  @override
  String get approveTooltip => 'Aprovar';

  @override
  String get rejectTooltip => 'Recusar';

  @override
  String get pendingChip => 'Pendente';

  @override
  String get deleteHouseConfirmBody =>
      'Esta ação é permanente e não pode ser desfeita. Todos os membros perderão o acesso.';

  @override
  String get houseNameLabel => 'Nome da casa';

  @override
  String houseNameHelper(String name) {
    return 'Digite exatamente: $name';
  }

  @override
  String get yourPasswordLabel => 'Sua senha';

  @override
  String get wrongPasswordError =>
      'Senha incorreta. Verifique e tente novamente.';

  @override
  String get categoryOrderTitle => 'Ordem das categorias';

  @override
  String get categoryOrderInstructions =>
      'Arraste para escolher a ordem em que as categorias aparecem na Dispensa e na Lista de Compras.';

  @override
  String get saveOrderFailed => 'Não foi possível salvar. Tente novamente.';

  @override
  String get orderSaved => 'Ordem salva!';

  @override
  String get saveOrderButton => 'Salvar ordem';

  @override
  String get newHouseTitle => 'Nova Casa';

  @override
  String get houseNameQuestion => 'Como sua casa se chama?';

  @override
  String get houseNameHint => 'Ex: Família Silva';

  @override
  String get houseNameRequired => 'Informe o nome da casa.';

  @override
  String get houseNameTooShort => 'O nome deve ter pelo menos 3 caracteres.';

  @override
  String get createHouseSubmit => 'Criar Casa';

  @override
  String get joinHouseTitle => 'Entrar em uma Casa';

  @override
  String get joinHouseInstructions =>
      'Digite o código de 6 caracteres compartilhado pelo administrador da casa.';

  @override
  String get inviteCodeHint => 'ABC123';

  @override
  String get inviteCodeRequired => 'Informe o código.';

  @override
  String get inviteCodeWrongLength => 'O código deve ter 6 caracteres.';

  @override
  String get requestJoinButton => 'Solicitar Entrada';

  @override
  String get joinRequestSent => 'Solicitação enviada! Aguarde a aprovação.';

  @override
  String get pantryTitle => 'Dispensa';

  @override
  String get couldNotLoadPantry => 'Não foi possível carregar sua dispensa.';

  @override
  String get pantryEmptyTitle => 'Sua dispensa está vazia';

  @override
  String get pantryEmptySubtitle =>
      'Adicione itens para controlar o que você tem em casa.';

  @override
  String get addItemButton => 'Adicionar item';

  @override
  String get removeItemTitle => 'Remover item';

  @override
  String removeItemConfirm(String name) {
    return 'Deseja remover \"$name\" da dispensa?';
  }

  @override
  String minStockPrefix(int count) {
    return 'mín $count';
  }

  @override
  String get editItemTitle => 'Editar item';

  @override
  String get newItemTitle => 'Novo item';

  @override
  String get itemNameLabel => 'Nome do item';

  @override
  String get itemNameHint => 'Ex: Leite integral';

  @override
  String get itemNameRequired => 'Digite um nome para o item.';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get controlQuantitySwitch => 'Controlar quantidade';

  @override
  String get controlQuantityDescription =>
      'Acompanhe a quantidade e um estoque mínimo deste item.';

  @override
  String get quantityLabel => 'Quantidade';

  @override
  String get minStockLabel => 'Estoque mínimo';

  @override
  String get quantityValidationError =>
      'Informe quantidade e estoque mínimo (0 ou mais).';

  @override
  String get saveItemFailed => 'Não foi possível salvar. Tente novamente.';

  @override
  String get shoppingListTitle => 'Lista de Compras';

  @override
  String get couldNotLoadShoppingList =>
      'Não foi possível carregar sua lista de compras.';

  @override
  String get inCartLabel => 'No carrinho';

  @override
  String updatePantryItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Atualizar dispensa ($count itens)',
      one: 'Atualizar dispensa (1 item)',
    );
    return '$_temp0';
  }

  @override
  String get selectItemsToShop => 'Selecione itens para comprar';

  @override
  String get shoppingEmptyTitle => 'Nada para comprar';

  @override
  String get shoppingEmptySubtitle =>
      'Quando um item da dispensa estiver \"Em falta\", ele aparecerá aqui para você marcar na lista.';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get inHouseSection => 'Na casa';

  @override
  String get houseNameField => 'Nome da casa';

  @override
  String get roleField => 'Cargo';

  @override
  String get appearanceSection => 'Aparência';

  @override
  String get systemTheme => 'Sistema';

  @override
  String get lightTheme => 'Claro';

  @override
  String get languageSection => 'Idioma';

  @override
  String get languageSystemOption => 'Sistema';

  @override
  String get darkTheme => 'Escuro';

  @override
  String get accountSection => 'Conta';

  @override
  String get signOut => 'Sair';

  @override
  String get signOutConfirmTitle => 'Sair';

  @override
  String get signOutConfirmBody => 'Tem certeza que deseja sair da sua conta?';

  @override
  String get footerBrand => 'Domo — um produto Café Labs';

  @override
  String get navPantry => 'Dispensa';

  @override
  String get navMarket => 'Mercado';

  @override
  String get navHouse => 'Casa';

  @override
  String get navProfile => 'Perfil';

  @override
  String get statusHave => 'Temos';

  @override
  String get statusMissing => 'Falta';

  @override
  String get categoryFrutasVerduras => 'Frutas e Verduras';

  @override
  String get categoryLaticinios => 'Laticínios';

  @override
  String get categoryCarnesPeixes => 'Carnes e Peixes';

  @override
  String get categoryPadaria => 'Padaria';

  @override
  String get categoryBebidas => 'Bebidas';

  @override
  String get categoryLimpeza => 'Limpeza';

  @override
  String get categoryHigieneCuidados => 'Higiene e Cuidados';

  @override
  String get categoryOutros => 'Outros';
}
