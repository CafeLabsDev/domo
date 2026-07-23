// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Try again';

  @override
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get remove => 'Remove';

  @override
  String get defaultUserName => 'User';

  @override
  String get errorNetwork => 'No connection. Check your internet.';

  @override
  String get errorUnexpected => 'Unexpected error. Please try again.';

  @override
  String get genericLoadError => 'Couldn\'t load. Please try again.';

  @override
  String get genericLoadErrorMessage =>
      'Check your internet connection and try again.';

  @override
  String get loginTitle => 'Welcome to Domo';

  @override
  String get loginSubtitle => 'Manage your home with your family.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailRequired => 'Enter your email.';

  @override
  String get emailInvalid => 'Invalid email.';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordRequiredLogin => 'Enter your password.';

  @override
  String get loginButton => 'Sign in';

  @override
  String get orDivider => 'or';

  @override
  String get googleButton => 'Continue with Google';

  @override
  String get noAccountPrompt => 'Don\'t have an account? ';

  @override
  String get createAccountLink => 'Create account';

  @override
  String get loginErrorInvalidCredential => 'Incorrect email or password.';

  @override
  String get loginErrorTooManyRequests => 'Too many attempts. Try again later.';

  @override
  String get loginErrorUserDisabled => 'This account has been disabled.';

  @override
  String get loginErrorGeneric => 'Couldn\'t sign in. Please try again.';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerIntro => 'Fill in the details below\nto get started.';

  @override
  String get passwordRequiredRegister => 'Enter a password.';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters.';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get confirmPasswordRequired => 'Confirm your password.';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match.';

  @override
  String get haveAccountPrompt => 'Already have an account? ';

  @override
  String get registerErrorEmailInUse => 'This email is already in use.';

  @override
  String get registerErrorGeneric =>
      'Couldn\'t create account. Please try again.';

  @override
  String get casaGateTitle => 'Your home awaits!';

  @override
  String get casaGateSubtitle =>
      'Create a new home or join an existing one with the invite code.';

  @override
  String get createHouseButton => 'Create a Home';

  @override
  String get haveInviteCodeButton => 'I have an invite code';

  @override
  String get codeCopied => 'Code copied!';

  @override
  String get leaveHouseTitle => 'Leave home';

  @override
  String get leaveHouseConfirm =>
      'You\'ll lose access to this home. To come back, you\'ll need the invite code.';

  @override
  String get leave => 'Leave';

  @override
  String get deleteHouseTitle => 'Delete home';

  @override
  String get copyCodeTooltip => 'Copy code';

  @override
  String get reorderCategoriesTooltip => 'Reorder categories';

  @override
  String get inviteCode => 'Invite code';

  @override
  String get couldNotLoadHouse => 'Couldn\'t load your home.';

  @override
  String get couldNotLoadMembers => 'Couldn\'t load home members.';

  @override
  String pendingApproval(int count) {
    return 'Awaiting approval ($count)';
  }

  @override
  String membersCount(int count) {
    return 'Members ($count)';
  }

  @override
  String get removeMemberTitle => 'Remove member';

  @override
  String removeMemberConfirm(String name) {
    return 'Remove $name from the home? They\'ll lose access immediately.';
  }

  @override
  String get approveTooltip => 'Approve';

  @override
  String get rejectTooltip => 'Reject';

  @override
  String get pendingChip => 'Pending';

  @override
  String get deleteHouseConfirmBody =>
      'This action is permanent and can\'t be undone. All members will lose access.';

  @override
  String get houseNameLabel => 'Home name';

  @override
  String houseNameHelper(String name) {
    return 'Type exactly: $name';
  }

  @override
  String get yourPasswordLabel => 'Your password';

  @override
  String get wrongPasswordError => 'Wrong password. Check it and try again.';

  @override
  String get categoryOrderTitle => 'Category order';

  @override
  String get categoryOrderInstructions =>
      'Drag to choose the order categories appear in the Pantry and Shopping List.';

  @override
  String get saveOrderFailed => 'Couldn\'t save. Please try again.';

  @override
  String get orderSaved => 'Order saved!';

  @override
  String get saveOrderButton => 'Save order';

  @override
  String get newHouseTitle => 'New Home';

  @override
  String get houseNameQuestion => 'What\'s your home called?';

  @override
  String get houseNameHint => 'e.g. The Smith Family';

  @override
  String get houseNameRequired => 'Enter your home\'s name.';

  @override
  String get houseNameTooShort => 'Name must be at least 3 characters.';

  @override
  String get createHouseSubmit => 'Create Home';

  @override
  String get joinHouseTitle => 'Join a Home';

  @override
  String get joinHouseInstructions =>
      'Enter the 6-character code shared by the home\'s admin.';

  @override
  String get inviteCodeHint => 'ABC123';

  @override
  String get inviteCodeRequired => 'Enter the code.';

  @override
  String get inviteCodeWrongLength => 'Code must be 6 characters.';

  @override
  String get requestJoinButton => 'Request to Join';

  @override
  String get joinRequestSent => 'Request sent! Wait for approval.';

  @override
  String get pantryTitle => 'Pantry';

  @override
  String get couldNotLoadPantry => 'Couldn\'t load your pantry.';

  @override
  String get pantryEmptyTitle => 'Your pantry is empty';

  @override
  String get pantryEmptySubtitle =>
      'Add items to keep track of what you have at home.';

  @override
  String get addItemButton => 'Add item';

  @override
  String get removeItemTitle => 'Remove item';

  @override
  String removeItemConfirm(String name) {
    return 'Remove \"$name\" from the pantry?';
  }

  @override
  String minStockPrefix(int count) {
    return 'min $count';
  }

  @override
  String get editItemTitle => 'Edit item';

  @override
  String get newItemTitle => 'New item';

  @override
  String get itemNameLabel => 'Item name';

  @override
  String get itemNameHint => 'e.g. Whole milk';

  @override
  String get itemNameRequired => 'Enter a name for the item.';

  @override
  String get categoryLabel => 'Category';

  @override
  String get controlQuantitySwitch => 'Track quantity';

  @override
  String get controlQuantityDescription =>
      'Track the quantity and a minimum stock level for this item.';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get minStockLabel => 'Minimum stock';

  @override
  String get quantityValidationError =>
      'Enter quantity and minimum stock (0 or more).';

  @override
  String get saveItemFailed => 'Couldn\'t save. Please try again.';

  @override
  String get shoppingListTitle => 'Shopping List';

  @override
  String get couldNotLoadShoppingList => 'Couldn\'t load your shopping list.';

  @override
  String get inCartLabel => 'In cart';

  @override
  String updatePantryItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Update pantry ($count items)',
      one: 'Update pantry (1 item)',
    );
    return '$_temp0';
  }

  @override
  String get selectItemsToShop => 'Select items to buy';

  @override
  String get shoppingEmptyTitle => 'Nothing to buy';

  @override
  String get shoppingEmptySubtitle =>
      'When a pantry item is \"Missing\", it\'ll show up here for you to add to the list.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get inHouseSection => 'In this home';

  @override
  String get houseNameField => 'Home name';

  @override
  String get roleField => 'Role';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get languageSection => 'Language';

  @override
  String get languageSystemOption => 'System';

  @override
  String get darkTheme => 'Dark';

  @override
  String get accountSection => 'Account';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirmTitle => 'Sign out';

  @override
  String get signOutConfirmBody => 'Are you sure you want to sign out?';

  @override
  String get footerBrand => 'Domo — a Café Labs product';

  @override
  String get navPantry => 'Pantry';

  @override
  String get navMarket => 'Shopping';

  @override
  String get navHouse => 'Home';

  @override
  String get navProfile => 'Profile';

  @override
  String get statusHave => 'Have it';

  @override
  String get statusMissing => 'Missing';

  @override
  String get categoryFrutasVerduras => 'Fruits and Vegetables';

  @override
  String get categoryLaticinios => 'Dairy';

  @override
  String get categoryCarnesPeixes => 'Meat and Fish';

  @override
  String get categoryPadaria => 'Bakery';

  @override
  String get categoryBebidas => 'Beverages';

  @override
  String get categoryLimpeza => 'Cleaning';

  @override
  String get categoryHigieneCuidados => 'Personal Care';

  @override
  String get categoryOutros => 'Other';
}
