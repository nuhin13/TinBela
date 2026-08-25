import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('bn'),
    Locale('en'),
  ];

  /// App name shown in the Android task switcher and browser tab.
  ///
  /// In bn, this message translates to:
  /// **'টিনবেলা'**
  String get appTitle;

  /// Bottom nav tab 1 — the daily loop. The product.
  ///
  /// In bn, this message translates to:
  /// **'আজ'**
  String get navToday;

  /// Bottom nav tab 2 — the month grid, the paper khata people already know.
  ///
  /// In bn, this message translates to:
  /// **'খাতা'**
  String get navGrid;

  /// Bottom nav tab 3 — money and balances.
  ///
  /// In bn, this message translates to:
  /// **'হিসাব'**
  String get navAccounts;

  /// Bottom nav tab 4 — members and settings.
  ///
  /// In bn, this message translates to:
  /// **'আরও'**
  String get navMore;

  /// Retry button on an error state. Short — it sits in a 48dp pill.
  ///
  /// In bn, this message translates to:
  /// **'আবার চেষ্টা করুন'**
  String get retry;

  /// Fallback error headline when the server sent no message of its own.
  ///
  /// In bn, this message translates to:
  /// **'কিছু একটা ভুল হয়েছে'**
  String get errorGeneric;

  /// Shown when the request never reached the server. Mess wifi is bad; blame the network, not the user.
  ///
  /// In bn, this message translates to:
  /// **'ইন্টারনেট সংযোগ নেই'**
  String get errorOffline;

  /// Support reference. The user reads this out; it is never translated.
  ///
  /// In bn, this message translates to:
  /// **'সমস্যার কোড: {id}'**
  String errorRequestId(String id);

  /// The empty state that means FINISHED, not blank. A zero-exception day is a success, not an absence.
  ///
  /// In bn, this message translates to:
  /// **'কিছু করার নেই'**
  String get nothingToDo;

  /// Second line of the finished-day state. Product rule: do not soften or remove.
  ///
  /// In bn, this message translates to:
  /// **'বাকি সবাই ডিফল্ট প্যাটার্নে ✓'**
  String get allOnDefault;

  /// Welcome screen tagline, line 1. From prototype frame 1a.
  ///
  /// In bn, this message translates to:
  /// **'তিনবেলার হিসাব, এক অ্যাপে।'**
  String get brandTagline;

  /// Welcome screen tagline, line 2.
  ///
  /// In bn, this message translates to:
  /// **'মেস চালান ঝামেলা ছাড়া — দিনে ১ মিনিট।'**
  String get brandSubtitle;

  /// Primary button on the welcome screen.
  ///
  /// In bn, this message translates to:
  /// **'শুরু করুন'**
  String get getStarted;

  /// Language choice on the welcome screen. bn is the default.
  ///
  /// In bn, this message translates to:
  /// **'বাংলা'**
  String get languageBangla;

  /// Language choice on the welcome screen. Never translated — it names itself.
  ///
  /// In bn, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Explainer card heading. Prototype frame 1c.
  ///
  /// In bn, this message translates to:
  /// **'💡 তিনবেলা যেভাবে কাজ করে'**
  String get howItWorksTitle;

  /// Explainer body. This is the product in three lines; do not shorten.
  ///
  /// In bn, this message translates to:
  /// **'প্রত্যেকের একটা ডিফল্ট প্যাটার্ন থাকে। স্বাভাবিক দিনে কেউ কিছু করে না — শুধু ব্যতিক্রম (অফ / গেস্ট) হলে ১ ট্যাপ। বাকিটা অ্যাপ হিসাব করে।'**
  String get howItWorksBody;

  /// Button that leaves the explainer for mess setup.
  ///
  /// In bn, this message translates to:
  /// **'মেস তৈরি করুন →'**
  String get createMess;

  /// Skips the explainer. Task 09.4 requires it be skippable.
  ///
  /// In bn, this message translates to:
  /// **'এড়িয়ে যান'**
  String get skip;

  /// Headline after a mess is created.
  ///
  /// In bn, this message translates to:
  /// **'মেস তৈরি হয়েছে 🎉'**
  String get messCreated;

  /// Label above the invite link.
  ///
  /// In bn, this message translates to:
  /// **'সদস্যদের এই লিংক পাঠান'**
  String get inviteLinkLabel;

  /// Copies the invite link.
  ///
  /// In bn, this message translates to:
  /// **'কপি'**
  String get copy;

  /// Toast after copying. Confirmation is a toast, never a dialog.
  ///
  /// In bn, this message translates to:
  /// **'লিংক কপি হয়েছে'**
  String get copied;

  /// Share target. A brand name — never translated.
  ///
  /// In bn, this message translates to:
  /// **'WhatsApp'**
  String get shareWhatsApp;

  /// Share target. A brand name — never translated.
  ///
  /// In bn, this message translates to:
  /// **'Messenger'**
  String get shareMessenger;

  /// Demo mess banner heading. Prototype frame 2.
  ///
  /// In bn, this message translates to:
  /// **'👋 এটি একটি ডেমো মেস'**
  String get demoBannerTitle;

  /// Demo banner body. Poke-safe is the promise; keep it.
  ///
  /// In bn, this message translates to:
  /// **'যেকোনো জায়গায় চাপ দিয়ে দেখুন — কিছুই ভাঙবে না। প্রস্তুত হলে নিজের মেস খুলুন।'**
  String get demoBannerBody;

  /// Discards the demo mess and starts a real one.
  ///
  /// In bn, this message translates to:
  /// **'নিজের মেস খুলুন'**
  String get demoBannerAction;

  /// Today tab empty state. A success, not an absence.
  ///
  /// In bn, this message translates to:
  /// **'আজ কোনো পরিবর্তন নেই'**
  String get emptyTodayTitle;

  /// Khata grid empty state.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসে এখনো কিছু নেই'**
  String get emptyGridTitle;

  /// The one action on the empty grid.
  ///
  /// In bn, this message translates to:
  /// **'আজ দেখুন'**
  String get emptyGridAction;

  /// Accounts tab empty state.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো বাজার বা জমা নেই'**
  String get emptyAccountsTitle;

  /// The one action on empty accounts.
  ///
  /// In bn, this message translates to:
  /// **'+ বাজার যোগ করুন'**
  String get emptyAccountsAction;

  /// Members empty state. Solo is a supported way to run a mess, not a failure.
  ///
  /// In bn, this message translates to:
  /// **'আপনি একাই আছেন'**
  String get emptyMembersTitle;

  /// The one action on empty members.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য যোগ করুন'**
  String get emptyMembersAction;
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
