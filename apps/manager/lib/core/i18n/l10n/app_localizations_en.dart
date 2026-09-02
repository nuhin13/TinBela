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
  String get signInPrompt => 'Sign in to get started';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInReassure => 'One tap — no OTP, no password.';

  @override
  String get signInFailed => 'Sign-in didn\'t complete. Try again.';

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

  @override
  String get membersTitle => 'Members';

  @override
  String get addMember => 'Add member';

  @override
  String get addMemberSend => 'Add and send link';

  @override
  String get memberNameLabel => 'Name';

  @override
  String get memberPhoneOptional => 'Phone (optional)';

  @override
  String get roleManager => 'Manager';

  @override
  String get inviteSent => 'Sent';

  @override
  String get inviteOpened => 'Opened';

  @override
  String get inviteLinked => 'Joined';

  @override
  String get messProfileTitle => 'Mess profile';

  @override
  String get messNameLabel => 'Mess name';

  @override
  String get messKindLabel => 'Kind';

  @override
  String get messKindMess => 'Mess';

  @override
  String get languageTitle => 'Language & numbers';

  @override
  String get languageSectionLabel => 'Language';

  @override
  String get numeralsSectionLabel => 'Numbers';

  @override
  String get numeralsBangla => '১২৩ (Bangla)';

  @override
  String get numeralsLatin => '123 (Latin)';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutDroidBuilder => 'Built by Droid Builder';

  @override
  String get aboutPrivacy => 'Privacy policy';

  @override
  String get aboutTerms => 'Terms';

  @override
  String get dataExportTitle => 'Data export';

  @override
  String get dataExportBody => 'Email us for a copy of all your data.';

  @override
  String get dataExportButton => 'Email to request data';

  @override
  String get dataExportSubject => 'Data export request';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountPending =>
      'Deleting your account is permanent — your mess, accounts and all data go for good. In-app deletion is being finalised; for now, request it on the web.';

  @override
  String get deleteAccountWebButton => 'Delete on the web';
}
