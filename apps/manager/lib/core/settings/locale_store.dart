// Where the language choice lives before there is an account to keep it on.
//
// Task 09.1 says the choice is "persisted". It is made on the welcome
// screen, which is by definition before sign-in, so `users.locale` on the
// server cannot hold it yet. This is that gap and only that gap.
//
// Once signed in, the server's `User.locale` is the source of truth --
// it follows the person to a new phone, which is the whole point of keeping
// it server-side. This store is the pre-auth cache and the offline fallback,
// never the authority.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// bn is the default and the source of truth; en is the translation
/// (apps/manager/AGENTS.md). A first launch with no stored value is Bangla,
/// not the device locale: the device of a Bangladeshi mess manager is very
/// often set to English by its vendor, and that is not a language choice.
const Locale defaultLocale = Locale('bn');

class LocaleStore {
  const LocaleStore(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'locale';

  static Future<LocaleStore> open() async =>
      LocaleStore(await SharedPreferences.getInstance());

  Locale read() {
    final code = _prefs.getString(_key);
    return switch (code) {
      'en' => const Locale('en'),
      'bn' => const Locale('bn'),
      // An unrecognised or absent value falls back rather than throwing. A
      // corrupted preference must not be able to stop the app booting.
      _ => defaultLocale,
    };
  }

  Future<void> write(Locale locale) =>
      _prefs.setString(_key, locale.languageCode);
}

/// Holds the active locale for the widget tree and persists every change.
class LocaleController extends ChangeNotifier {
  LocaleController(this._store) : _locale = _store.read();

  final LocaleStore _store;
  Locale _locale;

  Locale get locale => _locale;

  Future<void> set(Locale locale) async {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
    await _store.write(locale);
  }
}
