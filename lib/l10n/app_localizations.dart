import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('pt'),
    Locale('en'),
  ];

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @add.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Deletar'**
  String get delete;

  /// No description provided for @remove.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get remove;

  /// No description provided for @defaultUserName.
  ///
  /// In pt, this message translates to:
  /// **'Usuário'**
  String get defaultUserName;

  /// No description provided for @errorNetwork.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão. Verifique sua internet.'**
  String get errorNetwork;

  /// No description provided for @errorUnexpected.
  ///
  /// In pt, this message translates to:
  /// **'Erro inesperado. Tente novamente.'**
  String get errorUnexpected;

  /// No description provided for @genericLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar. Tente novamente.'**
  String get genericLoadError;

  /// No description provided for @genericLoadErrorMessage.
  ///
  /// In pt, this message translates to:
  /// **'Verifique sua conexão com a internet e tente novamente.'**
  String get genericLoadErrorMessage;

  /// No description provided for @loginTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo ao Domo'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Gerencie sua casa com sua família.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @emailRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe seu e-mail.'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In pt, this message translates to:
  /// **'E-mail inválido.'**
  String get emailInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get passwordLabel;

  /// No description provided for @passwordRequiredLogin.
  ///
  /// In pt, this message translates to:
  /// **'Informe sua senha.'**
  String get passwordRequiredLogin;

  /// No description provided for @loginButton.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginButton;

  /// No description provided for @orDivider.
  ///
  /// In pt, this message translates to:
  /// **'ou'**
  String get orDivider;

  /// No description provided for @googleButton.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com Google'**
  String get googleButton;

  /// No description provided for @noAccountPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Não tem conta? '**
  String get noAccountPrompt;

  /// No description provided for @createAccountLink.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get createAccountLink;

  /// No description provided for @loginErrorInvalidCredential.
  ///
  /// In pt, this message translates to:
  /// **'E-mail ou senha incorretos.'**
  String get loginErrorInvalidCredential;

  /// No description provided for @loginErrorTooManyRequests.
  ///
  /// In pt, this message translates to:
  /// **'Muitas tentativas. Tente mais tarde.'**
  String get loginErrorTooManyRequests;

  /// No description provided for @loginErrorUserDisabled.
  ///
  /// In pt, this message translates to:
  /// **'Esta conta foi desativada.'**
  String get loginErrorUserDisabled;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao entrar. Tente novamente.'**
  String get loginErrorGeneric;

  /// No description provided for @registerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar Conta'**
  String get registerTitle;

  /// No description provided for @registerIntro.
  ///
  /// In pt, this message translates to:
  /// **'Preencha os dados abaixo\npara começar.'**
  String get registerIntro;

  /// No description provided for @passwordRequiredRegister.
  ///
  /// In pt, this message translates to:
  /// **'Informe uma senha.'**
  String get passwordRequiredRegister;

  /// No description provided for @passwordTooShort.
  ///
  /// In pt, this message translates to:
  /// **'A senha deve ter pelo menos 6 caracteres.'**
  String get passwordTooShort;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar senha'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In pt, this message translates to:
  /// **'Confirme sua senha.'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In pt, this message translates to:
  /// **'As senhas não coincidem.'**
  String get passwordsDontMatch;

  /// No description provided for @haveAccountPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Já tem conta? '**
  String get haveAccountPrompt;

  /// No description provided for @registerErrorEmailInUse.
  ///
  /// In pt, this message translates to:
  /// **'Este e-mail já está em uso.'**
  String get registerErrorEmailInUse;

  /// No description provided for @registerErrorGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao criar conta. Tente novamente.'**
  String get registerErrorGeneric;

  /// No description provided for @casaGateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sua casa te espera!'**
  String get casaGateTitle;

  /// No description provided for @casaGateSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Crie uma nova casa ou entre em uma existente usando o código do convite.'**
  String get casaGateSubtitle;

  /// No description provided for @createHouseButton.
  ///
  /// In pt, this message translates to:
  /// **'Criar uma Casa'**
  String get createHouseButton;

  /// No description provided for @haveInviteCodeButton.
  ///
  /// In pt, this message translates to:
  /// **'Tenho um código de convite'**
  String get haveInviteCodeButton;

  /// No description provided for @codeCopied.
  ///
  /// In pt, this message translates to:
  /// **'Código copiado!'**
  String get codeCopied;

  /// No description provided for @leaveHouseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair da casa'**
  String get leaveHouseTitle;

  /// No description provided for @leaveHouseConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Você vai perder o acesso a esta casa. Para voltar, precisará do código de convite.'**
  String get leaveHouseConfirm;

  /// No description provided for @leave.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get leave;

  /// No description provided for @deleteHouseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Deletar casa'**
  String get deleteHouseTitle;

  /// No description provided for @copyCodeTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Copiar código'**
  String get copyCodeTooltip;

  /// No description provided for @reorderCategoriesTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Reordenar categorias'**
  String get reorderCategoriesTooltip;

  /// No description provided for @inviteCode.
  ///
  /// In pt, this message translates to:
  /// **'Código de convite'**
  String get inviteCode;

  /// No description provided for @couldNotLoadHouse.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar sua casa.'**
  String get couldNotLoadHouse;

  /// No description provided for @couldNotLoadMembers.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os membros da casa.'**
  String get couldNotLoadMembers;

  /// No description provided for @pendingApproval.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando aprovação ({count})'**
  String pendingApproval(int count);

  /// No description provided for @membersCount.
  ///
  /// In pt, this message translates to:
  /// **'Membros ({count})'**
  String membersCount(int count);

  /// No description provided for @removeMemberTitle.
  ///
  /// In pt, this message translates to:
  /// **'Remover membro'**
  String get removeMemberTitle;

  /// No description provided for @removeMemberConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Deseja remover {name} da casa? Eles perderão o acesso imediatamente.'**
  String removeMemberConfirm(String name);

  /// No description provided for @approveTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Aprovar'**
  String get approveTooltip;

  /// No description provided for @rejectTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Recusar'**
  String get rejectTooltip;

  /// No description provided for @pendingChip.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get pendingChip;

  /// No description provided for @deleteHouseConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'Esta ação é permanente e não pode ser desfeita. Todos os membros perderão o acesso.'**
  String get deleteHouseConfirmBody;

  /// No description provided for @houseNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome da casa'**
  String get houseNameLabel;

  /// No description provided for @houseNameHelper.
  ///
  /// In pt, this message translates to:
  /// **'Digite exatamente: {name}'**
  String houseNameHelper(String name);

  /// No description provided for @yourPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Sua senha'**
  String get yourPasswordLabel;

  /// No description provided for @wrongPasswordError.
  ///
  /// In pt, this message translates to:
  /// **'Senha incorreta. Verifique e tente novamente.'**
  String get wrongPasswordError;

  /// No description provided for @categoryOrderTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ordem das categorias'**
  String get categoryOrderTitle;

  /// No description provided for @categoryOrderInstructions.
  ///
  /// In pt, this message translates to:
  /// **'Arraste para escolher a ordem em que as categorias aparecem na Dispensa e na Lista de Compras.'**
  String get categoryOrderInstructions;

  /// No description provided for @saveOrderFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar. Tente novamente.'**
  String get saveOrderFailed;

  /// No description provided for @orderSaved.
  ///
  /// In pt, this message translates to:
  /// **'Ordem salva!'**
  String get orderSaved;

  /// No description provided for @saveOrderButton.
  ///
  /// In pt, this message translates to:
  /// **'Salvar ordem'**
  String get saveOrderButton;

  /// No description provided for @newHouseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova Casa'**
  String get newHouseTitle;

  /// No description provided for @houseNameQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Como sua casa se chama?'**
  String get houseNameQuestion;

  /// No description provided for @houseNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Família Silva'**
  String get houseNameHint;

  /// No description provided for @houseNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o nome da casa.'**
  String get houseNameRequired;

  /// No description provided for @houseNameTooShort.
  ///
  /// In pt, this message translates to:
  /// **'O nome deve ter pelo menos 3 caracteres.'**
  String get houseNameTooShort;

  /// No description provided for @createHouseSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Criar Casa'**
  String get createHouseSubmit;

  /// No description provided for @joinHouseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar em uma Casa'**
  String get joinHouseTitle;

  /// No description provided for @joinHouseInstructions.
  ///
  /// In pt, this message translates to:
  /// **'Digite o código de 6 caracteres compartilhado pelo administrador da casa.'**
  String get joinHouseInstructions;

  /// No description provided for @inviteCodeHint.
  ///
  /// In pt, this message translates to:
  /// **'ABC123'**
  String get inviteCodeHint;

  /// No description provided for @inviteCodeRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o código.'**
  String get inviteCodeRequired;

  /// No description provided for @inviteCodeWrongLength.
  ///
  /// In pt, this message translates to:
  /// **'O código deve ter 6 caracteres.'**
  String get inviteCodeWrongLength;

  /// No description provided for @requestJoinButton.
  ///
  /// In pt, this message translates to:
  /// **'Solicitar Entrada'**
  String get requestJoinButton;

  /// No description provided for @joinRequestSent.
  ///
  /// In pt, this message translates to:
  /// **'Solicitação enviada! Aguarde a aprovação.'**
  String get joinRequestSent;

  /// No description provided for @pantryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Dispensa'**
  String get pantryTitle;

  /// No description provided for @couldNotLoadPantry.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar sua dispensa.'**
  String get couldNotLoadPantry;

  /// No description provided for @pantryEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sua dispensa está vazia'**
  String get pantryEmptyTitle;

  /// No description provided for @pantryEmptySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Adicione itens para controlar o que você tem em casa.'**
  String get pantryEmptySubtitle;

  /// No description provided for @addItemButton.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar item'**
  String get addItemButton;

  /// No description provided for @removeItemTitle.
  ///
  /// In pt, this message translates to:
  /// **'Remover item'**
  String get removeItemTitle;

  /// No description provided for @removeItemConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Deseja remover \"{name}\" da dispensa?'**
  String removeItemConfirm(String name);

  /// No description provided for @minStockPrefix.
  ///
  /// In pt, this message translates to:
  /// **'mín {count}'**
  String minStockPrefix(int count);

  /// No description provided for @editItemTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar item'**
  String get editItemTitle;

  /// No description provided for @newItemTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo item'**
  String get newItemTitle;

  /// No description provided for @itemNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome do item'**
  String get itemNameLabel;

  /// No description provided for @itemNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Leite integral'**
  String get itemNameHint;

  /// No description provided for @itemNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Digite um nome para o item.'**
  String get itemNameRequired;

  /// No description provided for @categoryLabel.
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get categoryLabel;

  /// No description provided for @controlQuantitySwitch.
  ///
  /// In pt, this message translates to:
  /// **'Controlar quantidade'**
  String get controlQuantitySwitch;

  /// No description provided for @controlQuantityDescription.
  ///
  /// In pt, this message translates to:
  /// **'Acompanhe a quantidade e um estoque mínimo deste item.'**
  String get controlQuantityDescription;

  /// No description provided for @quantityLabel.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade'**
  String get quantityLabel;

  /// No description provided for @minStockLabel.
  ///
  /// In pt, this message translates to:
  /// **'Estoque mínimo'**
  String get minStockLabel;

  /// No description provided for @quantityValidationError.
  ///
  /// In pt, this message translates to:
  /// **'Informe quantidade e estoque mínimo (0 ou mais).'**
  String get quantityValidationError;

  /// No description provided for @saveItemFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar. Tente novamente.'**
  String get saveItemFailed;

  /// No description provided for @shoppingListTitle.
  ///
  /// In pt, this message translates to:
  /// **'Lista de Compras'**
  String get shoppingListTitle;

  /// No description provided for @couldNotLoadShoppingList.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar sua lista de compras.'**
  String get couldNotLoadShoppingList;

  /// No description provided for @inCartLabel.
  ///
  /// In pt, this message translates to:
  /// **'No carrinho'**
  String get inCartLabel;

  /// No description provided for @updatePantryItems.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, one {Atualizar dispensa (1 item)} other {Atualizar dispensa ({count} itens)}}'**
  String updatePantryItems(int count);

  /// No description provided for @selectItemsToShop.
  ///
  /// In pt, this message translates to:
  /// **'Selecione itens para comprar'**
  String get selectItemsToShop;

  /// No description provided for @shoppingEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nada para comprar'**
  String get shoppingEmptyTitle;

  /// No description provided for @shoppingEmptySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Quando um item da dispensa estiver \"Em falta\", ele aparecerá aqui para você marcar na lista.'**
  String get shoppingEmptySubtitle;

  /// No description provided for @profileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @inHouseSection.
  ///
  /// In pt, this message translates to:
  /// **'Na casa'**
  String get inHouseSection;

  /// No description provided for @houseNameField.
  ///
  /// In pt, this message translates to:
  /// **'Nome da casa'**
  String get houseNameField;

  /// No description provided for @roleField.
  ///
  /// In pt, this message translates to:
  /// **'Cargo'**
  String get roleField;

  /// No description provided for @appearanceSection.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get appearanceSection;

  /// No description provided for @systemTheme.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get darkTheme;

  /// No description provided for @accountSection.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get accountSection;

  /// No description provided for @signOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get signOut;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja sair da sua conta?'**
  String get signOutConfirmBody;

  /// No description provided for @footerBrand.
  ///
  /// In pt, this message translates to:
  /// **'Domo — um produto Café Labs'**
  String get footerBrand;

  /// No description provided for @navPantry.
  ///
  /// In pt, this message translates to:
  /// **'Dispensa'**
  String get navPantry;

  /// No description provided for @navMarket.
  ///
  /// In pt, this message translates to:
  /// **'Mercado'**
  String get navMarket;

  /// No description provided for @navHouse.
  ///
  /// In pt, this message translates to:
  /// **'Casa'**
  String get navHouse;

  /// No description provided for @navProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @statusHave.
  ///
  /// In pt, this message translates to:
  /// **'Temos'**
  String get statusHave;

  /// No description provided for @statusMissing.
  ///
  /// In pt, this message translates to:
  /// **'Falta'**
  String get statusMissing;

  /// No description provided for @categoryFrutasVerduras.
  ///
  /// In pt, this message translates to:
  /// **'Frutas e Verduras'**
  String get categoryFrutasVerduras;

  /// No description provided for @categoryLaticinios.
  ///
  /// In pt, this message translates to:
  /// **'Laticínios'**
  String get categoryLaticinios;

  /// No description provided for @categoryCarnesPeixes.
  ///
  /// In pt, this message translates to:
  /// **'Carnes e Peixes'**
  String get categoryCarnesPeixes;

  /// No description provided for @categoryPadaria.
  ///
  /// In pt, this message translates to:
  /// **'Padaria'**
  String get categoryPadaria;

  /// No description provided for @categoryBebidas.
  ///
  /// In pt, this message translates to:
  /// **'Bebidas'**
  String get categoryBebidas;

  /// No description provided for @categoryLimpeza.
  ///
  /// In pt, this message translates to:
  /// **'Limpeza'**
  String get categoryLimpeza;

  /// No description provided for @categoryHigieneCuidados.
  ///
  /// In pt, this message translates to:
  /// **'Higiene e Cuidados'**
  String get categoryHigieneCuidados;

  /// No description provided for @categoryOutros.
  ///
  /// In pt, this message translates to:
  /// **'Outros'**
  String get categoryOutros;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
