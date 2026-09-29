import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  static const currencies = {
    'USD': 'US Dollar',
    'LKR': 'Sri Lankan Rupee',
    'INR': 'Indian Rupee',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'AUD': 'Australian Dollar',
    'CAD': 'Canadian Dollar',
    'JPY': 'Japanese Yen',
    'AED': 'UAE Dirham',
  };
  static const _key = 'currencyCode';
  final SharedPreferences _prefs;
  late String _code;

  CurrencyProvider(this._prefs) {
    final saved = _prefs.getString(_key);
    _code = currencies.containsKey(saved) ? saved! : 'USD';
  }

  String get code => _code;
  NumberFormat get formatter => NumberFormat.currency(
        locale: 'en_US',
        name: _code,
        symbol: '$_code ',
      );

  Future<void> select(String code) async {
    if (!currencies.containsKey(code)) {
      throw ArgumentError.value(code, 'code', 'Unsupported currency');
    }
    if (_code == code) return;
    final saved = await _prefs.setString(_key, code);
    if (!saved) throw StateError('Could not save currency preference');
    _code = code;
    notifyListeners();
  }
}
