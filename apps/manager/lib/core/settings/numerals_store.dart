// The digit-system preference: ১২৩ (Bangla) or 123 (Latin).
//
// A per-user choice, not a locale consequence (task 13.7): plenty of bn
// readers prefer Latin digits for money. The server owns it on `User`
// (use_bangla_numerals), but there is no UpdateUser RPC in v1.0, so this local
// store is the authority for now — the same shape as LocaleStore, and it moves
// to the server the moment an update RPC exists.
//
// Nothing consumes it visually yet: the Bangla numeral formatter and MoneyText
// (task 08.4 ★) render against it once they land. Persisting the choice now is
// what makes the toggle "instant, no restart" (13.7's Done-when) then.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NumeralsStore {
  const NumeralsStore(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'use_bangla_numerals';

  static Future<NumeralsStore> open() async =>
      NumeralsStore(await SharedPreferences.getInstance());

  /// Bangla digits by default — the app is Bangla-first (apps/manager/AGENTS.md).
  bool read() => _prefs.getBool(_key) ?? true;

  Future<void> write(bool useBangla) => _prefs.setBool(_key, useBangla);
}

/// Holds the active numeral choice for the widget tree and persists changes.
class NumeralsController extends ChangeNotifier {
  NumeralsController(this._store) : _useBangla = _store.read();

  final NumeralsStore _store;
  bool _useBangla;

  /// True = ১২৩, false = 123.
  bool get useBanglaNumerals => _useBangla;

  Future<void> set(bool useBangla) async {
    if (useBangla == _useBangla) return;
    _useBangla = useBangla;
    notifyListeners();
    await _store.write(useBangla);
  }
}
