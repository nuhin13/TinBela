// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TinBela';

  @override
  String get navToday => 'Today';

  @override
  String get navGrid => 'Khata';

  @override
  String get navAccounts => 'Accounts';

  @override
  String get navMore => 'More';

  @override
  String get retry => 'Try again';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorOffline => 'No internet connection';

  @override
  String errorRequestId(String id) {
    return 'Reference: $id';
  }

  @override
  String get nothingToDo => 'Nothing to do';

  @override
  String get allOnDefault => 'Everyone else is on their default pattern ✓';

  @override
  String get brandTagline => 'Three meals a day, one app.';

  @override
  String get brandSubtitle =>
      'Run your mess without the hassle — one minute a day.';

  @override
  String get getStarted => 'Get started';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get languageEnglish => 'English';

  @override
  String get howItWorksTitle => '💡 How TinBela works';

  @override
  String get howItWorksBody =>
      'Everyone has a default pattern. On a normal day nobody does anything — one tap only for an exception (off / guest). The app does the rest.';

  @override
  String get createMess => 'Create a mess →';

  @override
  String get skip => 'Skip';

  @override
  String get messCreated => 'Mess created 🎉';

  @override
  String get inviteLinkLabel => 'Send members this link';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Link copied';

  @override
  String get shareWhatsApp => 'WhatsApp';

  @override
  String get shareMessenger => 'Messenger';

  @override
  String get demoBannerTitle => '👋 This is a demo mess';

  @override
  String get demoBannerBody =>
      'Tap anywhere — nothing will break. Open your own mess when you are ready.';

  @override
  String get demoBannerAction => 'Open my own mess';

  @override
  String get emptyTodayTitle => 'No changes today';

  @override
  String get emptyGridTitle => 'Nothing this month yet';

  @override
  String get emptyGridAction => 'Go to Today';

  @override
  String get emptyAccountsTitle => 'No bazar or deposits yet';

  @override
  String get emptyAccountsAction => '+ Add bazar';

  @override
  String get emptyMembersTitle => 'It is just you';

  @override
  String get emptyMembersAction => 'Add a member';
}
