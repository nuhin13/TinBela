// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'টিনবেলা';

  @override
  String get navToday => 'আজ';

  @override
  String get navGrid => 'খাতা';

  @override
  String get navAccounts => 'হিসাব';

  @override
  String get navMore => 'আরও';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get errorGeneric => 'কিছু একটা ভুল হয়েছে';

  @override
  String get errorOffline => 'ইন্টারনেট সংযোগ নেই';

  @override
  String errorRequestId(String id) {
    return 'সমস্যার কোড: $id';
  }

  @override
  String get nothingToDo => 'কিছু করার নেই';

  @override
  String get allOnDefault => 'বাকি সবাই ডিফল্ট প্যাটার্নে ✓';

  @override
  String get brandTagline => 'তিনবেলার হিসাব, এক অ্যাপে।';

  @override
  String get brandSubtitle => 'মেস চালান ঝামেলা ছাড়া — দিনে ১ মিনিট।';

  @override
  String get getStarted => 'শুরু করুন';

  @override
  String get signInPrompt => 'শুরু করতে সাইন ইন করুন';

  @override
  String get signInWithGoogle => 'Google দিয়ে সাইন ইন';

  @override
  String get signInReassure => 'এক ট্যাপে — কোনো ওটিপি বা পাসওয়ার্ড নেই।';

  @override
  String get signInFailed => 'সাইন ইন হয়নি, আবার চেষ্টা করুন';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get languageEnglish => 'English';

  @override
  String get howItWorksTitle => '💡 তিনবেলা যেভাবে কাজ করে';

  @override
  String get howItWorksBody =>
      'প্রত্যেকের একটা ডিফল্ট প্যাটার্ন থাকে। স্বাভাবিক দিনে কেউ কিছু করে না — শুধু ব্যতিক্রম (অফ / গেস্ট) হলে ১ ট্যাপ। বাকিটা অ্যাপ হিসাব করে।';

  @override
  String get createMess => 'মেস তৈরি করুন →';

  @override
  String get skip => 'এড়িয়ে যান';

  @override
  String get messCreated => 'মেস তৈরি হয়েছে 🎉';

  @override
  String get inviteLinkLabel => 'সদস্যদের এই লিংক পাঠান';

  @override
  String get copy => 'কপি';

  @override
  String get copied => 'লিংক কপি হয়েছে';

  @override
  String get shareWhatsApp => 'WhatsApp';

  @override
  String get shareMessenger => 'Messenger';

  @override
  String get demoBannerTitle => '👋 এটি একটি ডেমো মেস';

  @override
  String get demoBannerBody =>
      'যেকোনো জায়গায় চাপ দিয়ে দেখুন — কিছুই ভাঙবে না। প্রস্তুত হলে নিজের মেস খুলুন।';

  @override
  String get demoBannerAction => 'নিজের মেস খুলুন';

  @override
  String get emptyTodayTitle => 'আজ কোনো পরিবর্তন নেই';

  @override
  String get emptyGridTitle => 'এই মাসে এখনো কিছু নেই';

  @override
  String get emptyGridAction => 'আজ দেখুন';

  @override
  String get emptyAccountsTitle => 'এখনো কোনো বাজার বা জমা নেই';

  @override
  String get emptyAccountsAction => '+ বাজার যোগ করুন';

  @override
  String get emptyMembersTitle => 'আপনি একাই আছেন';

  @override
  String get emptyMembersAction => 'সদস্য যোগ করুন';

  @override
  String get membersTitle => 'সদস্য';

  @override
  String get addMember => 'সদস্য যোগ করুন';

  @override
  String get addMemberSend => 'যোগ করে লিংক পাঠান';

  @override
  String get memberNameLabel => 'নাম';

  @override
  String get memberPhoneOptional => 'ফোন (ঐচ্ছিক)';

  @override
  String get roleManager => 'ম্যানেজার';

  @override
  String get inviteSent => 'পাঠানো';

  @override
  String get inviteOpened => 'খুলেছেন';

  @override
  String get inviteLinked => 'যুক্ত';

  @override
  String get messProfileTitle => 'মেস প্রোফাইল';

  @override
  String get messNameLabel => 'মেসের নাম';

  @override
  String get messKindLabel => 'ধরন';

  @override
  String get messKindMess => 'মেস';

  @override
  String get languageTitle => 'ভাষা ও সংখ্যা';

  @override
  String get languageSectionLabel => 'ভাষা';

  @override
  String get numeralsSectionLabel => 'সংখ্যা';

  @override
  String get numeralsBangla => '১২৩ (বাংলা)';

  @override
  String get numeralsLatin => '123 (ইংরেজি)';

  @override
  String get aboutTitle => 'সম্পর্কে';

  @override
  String aboutVersion(String version) {
    return 'সংস্করণ $version';
  }

  @override
  String get aboutDroidBuilder => 'Droid Builder-এর তৈরি';

  @override
  String get aboutPrivacy => 'গোপনীয়তা নীতি';

  @override
  String get aboutTerms => 'শর্তাবলী';

  @override
  String get dataExportTitle => 'ডেটা এক্সপোর্ট';

  @override
  String get dataExportBody => 'আপনার সব তথ্যের একটি কপি চাইলে আমাদের ইমেইল করুন।';

  @override
  String get dataExportButton => 'ডেটা চেয়ে ইমেইল করুন';

  @override
  String get dataExportSubject => 'ডেটা এক্সপোর্টের অনুরোধ';

  @override
  String get deleteAccountTitle => 'অ্যাকাউন্ট মুছুন';

  @override
  String get deleteAccountPending =>
      'অ্যাকাউন্ট মুছে ফেলা স্থায়ী — আপনার মেস, হিসাব ও সব তথ্য চিরতরে চলে যাবে। অ্যাপের ভেতরের মুছে ফেলার ধাপটি এখনো যুক্ত হচ্ছে; এই মুহূর্তে ওয়েবে গিয়ে অনুরোধ করুন।';

  @override
  String get deleteAccountWebButton => 'ওয়েবে মুছে ফেলুন';
}
